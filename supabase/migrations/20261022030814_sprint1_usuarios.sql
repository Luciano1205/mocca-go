-- ============ Sprint 1: usuarios y códigos de acceso ============

create table public.codigo_acceso (
  id          uuid primary key default gen_random_uuid(),
  codigo_hash text not null unique,
  activo      boolean not null default true,
  creado_en   timestamptz not null default now()
);

create table public.usuario (
  id                    uuid primary key references auth.users(id) on delete cascade,
  nombre                text not null,
  correo                text not null unique,
  rol                   text not null default 'cliente'
                        check (rol in ('cliente', 'proveedor', 'soporte')),
  descripcion           text,
  calificacion_promedio numeric(3,2) not null default 0
                        check (calificacion_promedio between 0 and 5),
  total_calificaciones  integer not null default 0,
  codigo_acceso_id      uuid references public.codigo_acceso(id),
  token_notificacion    text,
  activo                boolean not null default true,
  creado_en             timestamptz not null default now(),
  constraint proveedor_con_codigo
    check (rol <> 'proveedor' or codigo_acceso_id is not null)
);

-- Hash del código (mayúsculas y sin espacios)
create or replace function public.hash_codigo(p_codigo text)
returns text language sql immutable set search_path = '' as $$
  select encode(sha256(convert_to(upper(trim(p_codigo)), 'UTF8')), 'hex')
$$;

insert into public.codigo_acceso (codigo_hash)
values (public.hash_codigo('MOCCA-2026'));

-- La app valida el código antes de registrar (pantalla 05b)
create or replace function public.validar_codigo_acceso(p_codigo text)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.codigo_acceso
    where codigo_hash = public.hash_codigo(p_codigo) and activo
  )
$$;
revoke execute on function public.validar_codigo_acceso(text) from public;
grant execute on function public.validar_codigo_acceso(text) to anon, authenticated;

-- Crea el perfil al registrarse y asigna el rol según el código
create or replace function public.crear_usuario()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_meta      jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
  v_codigo    text  := nullif(trim(v_meta->>'codigo_acceso'), '');
  v_codigo_id uuid;
  v_rol       text  := 'cliente';
begin
  if v_codigo is not null then
    select id into v_codigo_id from public.codigo_acceso
    where codigo_hash = public.hash_codigo(v_codigo) and activo;
    if v_codigo_id is null then
      raise exception 'Código de acceso inválido';
    end if;
    v_rol := 'proveedor';
  end if;

  insert into public.usuario (id, nombre, correo, rol, descripcion, codigo_acceso_id)
  values (
    new.id,
    coalesce(nullif(trim(v_meta->>'nombre'), ''), 'Sin nombre'),
    new.email,
    v_rol,
    nullif(trim(v_meta->>'descripcion'), ''),
    v_codigo_id
  );
  return new;
end;
$$;

create trigger al_crear_usuario
  after insert on auth.users
  for each row execute function public.crear_usuario();

-- Seguridad
alter table public.usuario enable row level security;
alter table public.codigo_acceso enable row level security;

grant select on public.usuario to authenticated;
grant update (nombre, descripcion, token_notificacion) on public.usuario to authenticated;

create policy "usuario_ve_su_perfil" on public.usuario
  for select to authenticated using (id = (select auth.uid()));

create policy "usuario_edita_su_perfil" on public.usuario
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));
