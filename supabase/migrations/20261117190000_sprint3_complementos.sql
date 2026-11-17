-- ============ Sprint 3: complementos ============
-- Calificaciones en ambos sentidos, disponibilidad de productos, reclamos
-- (versión corta: el bot registra el reclamo y el equipo contacta después)
-- y lo que necesita el tiempo real para las notificaciones locales.

-- ---------- Visibilidad del domiciliario ----------

-- Antes el domiciliario solo veía los pendientes y los suyos. Con tiempo real
-- eso no alcanza: cuando otro toma un pedido, la fila deja de ser visible y
-- Supabase ya no le envía el cambio, así que el pedido se quedaría en su feed.
-- Los domiciliarios son del equipo de Mocca Go!, así que leen todos los
-- pedidos; modificar sigue limitado a los que toman (RNF04). Las consultas de
-- la app ya filtran por estado y por domiciliario_id.
drop policy "pedido_visible" on public.pedido;

create policy "pedido_visible" on public.pedido
  for select to authenticated using (
    cliente_id = (select auth.uid())
    or (select public.rol_actual()) = 'proveedor'
  );

-- ---------- Disponibilidad de productos (RF24) ----------

grant update (disponible) on public.producto to authenticated;

create policy "domiciliario_cambia_disponibilidad" on public.producto
  for update to authenticated
  using ((select public.rol_actual()) = 'proveedor')
  with check ((select public.rol_actual()) = 'proveedor');

-- Quién y cuándo lo cambió lo pone la base, no la app.
create or replace function public.marcar_actualizacion_producto()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.actualizado_por := (select auth.uid());
  new.actualizado_en := now();
  return new;
end;
$$;

create trigger antes_de_actualizar_producto
  before update on public.producto
  for each row execute function public.marcar_actualizacion_producto();

-- ---------- Calificaciones (RF19, RF20, RF21) ----------

create table public.calificacion (
  id            uuid primary key default gen_random_uuid(),
  pedido_id     uuid not null references public.pedido(id) on delete cascade,
  autor_id      uuid not null default auth.uid() references public.usuario(id),
  calificado_id uuid references public.usuario(id),
  valor         integer not null check (valor between 1 and 5),
  creado_en     timestamptz not null default now(),
  unique (pedido_id, autor_id)                                   -- una vez por pedido
);

-- La app solo manda pedido y valor. La base revisa que el pedido esté
-- entregado y que el autor sea su cliente o su domiciliario, y califica
-- a la otra parte.
create or replace function public.preparar_calificacion()
returns trigger language plpgsql security definer set search_path = '' as $$
declare
  v_pedido public.pedido%rowtype;
begin
  select * into v_pedido from public.pedido where id = new.pedido_id;
  if v_pedido.id is null or v_pedido.estado <> 'entregado' then
    raise exception 'Solo se califican pedidos entregados';
  end if;

  new.autor_id := (select auth.uid());
  if new.autor_id = v_pedido.cliente_id then
    new.calificado_id := v_pedido.domiciliario_id;
  elsif new.autor_id = v_pedido.domiciliario_id then
    new.calificado_id := v_pedido.cliente_id;
  else
    raise exception 'No participaste en este pedido';
  end if;
  return new;
end;
$$;

create trigger antes_de_insertar_calificacion
  before insert on public.calificacion
  for each row execute function public.preparar_calificacion();

-- Recalcula el promedio de quien recibió la calificación (RF21).
-- security definer: la app no puede escribir esas columnas de `usuario`.
create or replace function public.recalcular_promedio()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  update public.usuario u
  set calificacion_promedio = t.promedio,
      total_calificaciones  = t.total
  from (
    select round(avg(valor), 2) as promedio, count(*)::integer as total
    from public.calificacion where calificado_id = new.calificado_id
  ) t
  where u.id = new.calificado_id;
  return null;
end;
$$;

create trigger despues_de_insertar_calificacion
  after insert on public.calificacion
  for each row execute function public.recalcular_promedio();

alter table public.calificacion enable row level security;

grant select on public.calificacion to authenticated;
grant insert (pedido_id, valor) on public.calificacion to authenticated;

-- Cada quien ve las que dio (para saber si ya calificó) y las que recibió.
create policy "calificacion_visible" on public.calificacion
  for select to authenticated using (
    autor_id = (select auth.uid()) or calificado_id = (select auth.uid())
  );

create policy "participante_califica" on public.calificacion
  for insert to authenticated with check (autor_id = (select auth.uid()));

-- ---------- Reclamos (RF25, versión corta) ----------

create table public.motivo_reclamo (
  id            uuid primary key default gen_random_uuid(),
  texto         text not null,
  aplica_a      text not null check (aplica_a in ('en_curso', 'entregado')),
  pide_producto boolean not null default false,                -- pregunta qué producto
  pide_solucion boolean not null default false,                -- pregunta cómo resolverlo
  orden         integer not null default 0,
  unique (aplica_a, texto)
);

create table public.reclamo (
  id         uuid primary key default gen_random_uuid(),
  numero     integer generated always as identity (start with 101) unique,  -- "R-101"
  pedido_id  uuid not null references public.pedido(id) on delete cascade,
  cliente_id uuid not null default auth.uid() references public.usuario(id),
  motivo_id  uuid not null references public.motivo_reclamo(id),
  solucion   text check (solucion in ('reenviar', 'devolver', 'hablar_equipo')),
  estado     text not null default 'abierto'
             check (estado in ('abierto', 'en_atencion', 'cerrado')),
  creado_en  timestamptz not null default now(),
  cerrado_en timestamptz
);

create index reclamo_pedido_idx on public.reclamo (pedido_id);

-- Productos afectados: uno o varios, siempre del mismo pedido.
create table public.reclamo_detalle (
  id                uuid primary key default gen_random_uuid(),
  reclamo_id        uuid not null references public.reclamo(id) on delete cascade,
  detalle_pedido_id uuid not null references public.detalle_pedido(id),
  unique (reclamo_id, detalle_pedido_id)
);

-- El motivo debe corresponder al estado del pedido: en curso (pendiente,
-- aceptado, en camino) o entregado. Los cancelados no tienen reclamo.
create or replace function public.preparar_reclamo()
returns trigger language plpgsql set search_path = '' as $$
declare
  v_estado   text;
  v_aplica_a text;
begin
  select estado into v_estado from public.pedido where id = new.pedido_id;
  select aplica_a into v_aplica_a from public.motivo_reclamo where id = new.motivo_id;

  if v_estado is null or v_estado = 'cancelado' then
    raise exception 'Este pedido no admite reclamos';
  end if;
  if v_aplica_a <> (case when v_estado = 'entregado' then 'entregado' else 'en_curso' end) then
    raise exception 'El motivo no corresponde al estado del pedido';
  end if;

  new.cliente_id := (select auth.uid());
  new.estado := 'abierto';
  new.cerrado_en := null;
  return new;
end;
$$;

create trigger antes_de_insertar_reclamo
  before insert on public.reclamo
  for each row execute function public.preparar_reclamo();

create or replace function public.validar_reclamo_detalle()
returns trigger language plpgsql set search_path = '' as $$
begin
  if not exists (
    select 1
    from public.reclamo r
    join public.detalle_pedido d on d.pedido_id = r.pedido_id
    where r.id = new.reclamo_id and d.id = new.detalle_pedido_id
  ) then
    raise exception 'El producto no es de este pedido';
  end if;
  return new;
end;
$$;

create trigger antes_de_insertar_reclamo_detalle
  before insert on public.reclamo_detalle
  for each row execute function public.validar_reclamo_detalle();

alter table public.motivo_reclamo  enable row level security;
alter table public.reclamo         enable row level security;
alter table public.reclamo_detalle enable row level security;

grant select on public.motivo_reclamo, public.reclamo, public.reclamo_detalle to authenticated;
grant insert (pedido_id, motivo_id, solucion) on public.reclamo to authenticated;
grant insert (reclamo_id, detalle_pedido_id) on public.reclamo_detalle to authenticated;

create policy "motivos_visibles" on public.motivo_reclamo
  for select to authenticated using (true);

-- El cliente ve y abre reclamos solo de sus pedidos; soporte los ve todos.
create policy "reclamo_visible" on public.reclamo
  for select to authenticated using (
    cliente_id = (select auth.uid())
    or (select public.rol_actual()) = 'soporte'
  );

create policy "cliente_abre_reclamo" on public.reclamo
  for insert to authenticated with check (
    cliente_id = (select auth.uid())
    and exists (
      select 1 from public.pedido p
      where p.id = pedido_id and p.cliente_id = (select auth.uid())
    )
  );

create policy "reclamo_detalle_visible" on public.reclamo_detalle
  for select to authenticated using (
    exists (select 1 from public.reclamo r where r.id = reclamo_id)
  );

create policy "cliente_marca_productos" on public.reclamo_detalle
  for insert to authenticated with check (
    exists (
      select 1 from public.reclamo r
      where r.id = reclamo_id and r.cliente_id = (select auth.uid())
    )
  );

-- Motivos del prototipo (pantallas 21 y 22).
insert into public.motivo_reclamo (texto, aplica_a, pide_producto, pide_solucion, orden) values
  ('Mi pedido no ha llegado',     'en_curso',  false, false, 1),
  ('Se está demorando mucho',     'en_curso',  false, false, 2),
  ('Quiero cambiar la dirección', 'en_curso',  false, false, 3),
  ('Faltó un producto',           'entregado', true,  true,  1),
  ('Llegó en mal estado',         'entregado', true,  true,  2),
  ('Demoró mucho',                'entregado', false, false, 3),
  ('Cobro incorrecto',            'entregado', false, true,  4),
  ('Otro problema',               'entregado', false, false, 5);

-- ---------- Tiempo real ----------
-- `pedido` ya está publicada desde el sprint 2. El pago es lo último que se
-- guarda al crear un pedido, pero el stream de `pedido` no se entera de él.
-- Por eso el pago toca `pedido.actualizado_en`: ese UPDATE le avisa al feed
-- que el pedido ya está completo (con pago) y puede aparecer con su notificación.
alter table public.pedido add column actualizado_en timestamptz not null default now();

create or replace function public.avisar_pago_registrado()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  update public.pedido set actualizado_en = now() where id = new.pedido_id;
  return null;
end;
$$;

create trigger despues_de_insertar_pago
  after insert on public.pago
  for each row execute function public.avisar_pago_registrado();

-- `producto` se publica para que el menú refleje los agotados al instante.
alter publication supabase_realtime add table public.producto;
