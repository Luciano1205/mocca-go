-- ============ Sprint 2: catálogo y ciclo del pedido ============
-- Tablas del modelo de datos (sección 8 de la referencia) que usa el ciclo
-- Pendiente → Aceptado → En camino → Entregado, más Cancelado.
-- Calificación, notificaciones y reclamos llegan en el sprint 3.

-- ---------- Rol de quien hace la petición ----------

-- security definer: lee `usuario` sin pasar por su RLS, así las políticas
-- de otras tablas pueden preguntar el rol sin recursión.
create or replace function public.rol_actual()
returns text language sql stable security definer set search_path = '' as $$
  select rol from public.usuario where id = (select auth.uid())
$$;
revoke execute on function public.rol_actual() from public;
grant execute on function public.rol_actual() to authenticated;

-- ---------- Catálogo ----------

create table public.categoria (
  id     uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  orden  integer not null default 0
);

create table public.producto (
  id              uuid primary key default gen_random_uuid(),
  categoria_id    uuid not null references public.categoria(id),
  nombre          text not null,
  descripcion     text,
  precio          integer not null check (precio > 0),          -- COP
  imagen_path     text,                                         -- bucket `productos`
  disponible      boolean not null default true,                -- switch del domiciliario (sprint 3)
  actualizado_por uuid references public.usuario(id),
  actualizado_en  timestamptz not null default now()
);

create table public.zona (
  id     uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  activa boolean not null default true,
  orden  integer not null default 0
);

create table public.entidad_pago (
  id           uuid primary key default gen_random_uuid(),
  nombre       text not null unique,
  tipo_destino text not null check (tipo_destino in ('celular', 'cuenta', 'llave')),
  dato_destino text not null,
  titular      text not null,
  activa       boolean not null default true
);

-- ---------- Pedido ----------

create table public.pedido (
  id              uuid primary key default gen_random_uuid(),
  numero          integer generated always as identity (start with 1001) unique,
  cliente_id      uuid not null references public.usuario(id),
  domiciliario_id uuid references public.usuario(id),
  zona_id         uuid not null references public.zona(id),
  referencia      text not null check (char_length(trim(referencia)) > 0),
  nota            text,
  estado          text not null default 'pendiente'
                  check (estado in ('pendiente', 'aceptado', 'en_camino', 'entregado', 'cancelado')),
  subtotal        integer not null default 0,
  costo_domicilio integer not null default 0,                   -- 0 = gratis
  total           integer not null default 0,
  creado_en       timestamptz not null default now(),
  constraint pendiente_sin_domiciliario
    check ((estado in ('pendiente', 'cancelado')) = (domiciliario_id is null))
);

create index pedido_estado_idx on public.pedido (estado, creado_en);
create index pedido_cliente_idx on public.pedido (cliente_id, creado_en desc);
create index pedido_domiciliario_idx on public.pedido (domiciliario_id, creado_en desc);

create table public.detalle_pedido (
  id              uuid primary key default gen_random_uuid(),
  pedido_id       uuid not null references public.pedido(id) on delete cascade,
  producto_id     uuid not null references public.producto(id),
  nombre_producto text not null default '',                     -- copia al momento del pedido
  precio_unitario integer not null default 0,                   -- copia al momento del pedido
  cantidad        integer not null check (cantidad between 1 and 20),
  subtotal        integer not null default 0,
  unique (pedido_id, producto_id)
);

create table public.pago (
  id              uuid primary key default gen_random_uuid(),
  pedido_id       uuid not null unique references public.pedido(id) on delete cascade,
  metodo          text not null check (metodo in ('efectivo', 'transferencia')),
  valor_a_pagar   integer not null default 0,
  valor_entregado integer,                                      -- billete; nulo si es exacto
  cambio          integer not null default 0,
  entidad_pago_id uuid references public.entidad_pago(id),      -- solo transferencia
  estado          text not null default 'pendiente' check (estado in ('pendiente', 'confirmado')),
  confirmado_en   timestamptz,
  constraint transferencia_con_entidad
    check ((metodo = 'transferencia') = (entidad_pago_id is not null)),
  constraint efectivo_sin_entidad
    check (metodo = 'efectivo' or valor_entregado is null)
);

create table public.historial_estado (
  id           uuid primary key default gen_random_uuid(),
  pedido_id    uuid not null references public.pedido(id) on delete cascade,
  estado       text not null,
  cambiado_por uuid references public.usuario(id),
  fecha        timestamptz not null default now()
);

create index historial_pedido_idx on public.historial_estado (pedido_id, fecha);

-- ---------- Reglas que vive en la base de datos ----------

-- Detalle: copia nombre y precio del producto, calcula el subtotal y no deja
-- pedir agotados. La app solo manda producto y cantidad.
create or replace function public.preparar_detalle()
returns trigger language plpgsql set search_path = '' as $$
declare
  v_producto public.producto%rowtype;
begin
  select * into v_producto from public.producto where id = new.producto_id;
  if not v_producto.disponible then
    raise exception 'El producto % está agotado', v_producto.nombre;
  end if;
  new.nombre_producto := v_producto.nombre;
  new.precio_unitario := v_producto.precio;
  new.subtotal := v_producto.precio * new.cantidad;
  return new;
end;
$$;

create trigger antes_de_insertar_detalle
  before insert on public.detalle_pedido
  for each row execute function public.preparar_detalle();

-- Recalcula subtotal y total del pedido cuando entran sus detalles.
-- security definer: el cliente no tiene permiso de actualizar estas columnas.
create or replace function public.recalcular_totales()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  update public.pedido p
  set subtotal = t.suma,
      total    = t.suma + p.costo_domicilio
  from (
    select coalesce(sum(subtotal), 0)::integer as suma
    from public.detalle_pedido where pedido_id = new.pedido_id
  ) t
  where p.id = new.pedido_id;
  return null;
end;
$$;

create trigger despues_de_insertar_detalle
  after insert on public.detalle_pedido
  for each row execute function public.recalcular_totales();

-- Pago: toma el total del pedido y calcula el cambio.
create or replace function public.preparar_pago()
returns trigger language plpgsql set search_path = '' as $$
declare
  v_total integer;
begin
  select total into v_total from public.pedido where id = new.pedido_id;
  if v_total is null or v_total = 0 then
    raise exception 'El pedido no tiene productos';
  end if;
  new.valor_a_pagar := v_total;
  new.estado := 'pendiente';
  new.confirmado_en := null;
  if new.valor_entregado is not null then
    if new.valor_entregado < v_total then
      raise exception 'El valor entregado no alcanza para el total';
    end if;
    new.cambio := new.valor_entregado - v_total;
  else
    new.cambio := 0;
  end if;
  return new;
end;
$$;

create trigger antes_de_insertar_pago
  before insert on public.pago
  for each row execute function public.preparar_pago();

-- Transiciones válidas del estado. El domiciliario que toma el pedido queda
-- fijo; la RLS ya decide quién puede actualizar cada fila.
create or replace function public.validar_transicion()
returns trigger language plpgsql set search_path = '' as $$
begin
  if new.estado = old.estado then
    if new.domiciliario_id is distinct from old.domiciliario_id then
      raise exception 'No se puede cambiar el domiciliario';
    end if;
    return new;
  end if;

  if not (
       (old.estado = 'pendiente' and new.estado in ('aceptado', 'cancelado'))
    or (old.estado = 'aceptado'  and new.estado = 'en_camino')
    or (old.estado = 'en_camino' and new.estado = 'entregado')
  ) then
    raise exception 'Cambio de estado no permitido: % → %', old.estado, new.estado;
  end if;

  if old.domiciliario_id is not null
     and new.domiciliario_id is distinct from old.domiciliario_id then
    raise exception 'No se puede cambiar el domiciliario';
  end if;
  return new;
end;
$$;

create trigger antes_de_actualizar_pedido
  before update on public.pedido
  for each row execute function public.validar_transicion();

-- Historial: una fila al crear el pedido y otra en cada cambio de estado.
-- Al entregar se confirma el cobro.
create or replace function public.registrar_estado()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' or new.estado is distinct from old.estado then
    insert into public.historial_estado (pedido_id, estado, cambiado_por)
    values (new.id, new.estado, (select auth.uid()));
  end if;
  if tg_op = 'UPDATE' and new.estado = 'entregado' and old.estado <> 'entregado' then
    update public.pago set estado = 'confirmado', confirmado_en = now()
    where pedido_id = new.id;
  end if;
  return null;
end;
$$;

create trigger despues_de_guardar_pedido
  after insert or update on public.pedido
  for each row execute function public.registrar_estado();

-- ---------- Seguridad ----------

alter table public.categoria        enable row level security;
alter table public.producto         enable row level security;
alter table public.zona             enable row level security;
alter table public.entidad_pago     enable row level security;
alter table public.pedido           enable row level security;
alter table public.detalle_pedido   enable row level security;
alter table public.pago             enable row level security;
alter table public.historial_estado enable row level security;

-- Catálogo: lo lee cualquiera con sesión.
grant select on public.categoria, public.producto, public.zona, public.entidad_pago
  to authenticated;

create policy "catalogo_categorias" on public.categoria
  for select to authenticated using (true);
create policy "catalogo_productos" on public.producto
  for select to authenticated using (true);
create policy "catalogo_zonas" on public.zona
  for select to authenticated using (activa);
create policy "catalogo_entidades" on public.entidad_pago
  for select to authenticated using (activa);

-- Pedido: la app solo escribe estas columnas; el resto lo calcula la base.
grant select on public.pedido, public.detalle_pedido, public.pago, public.historial_estado
  to authenticated;
grant insert (cliente_id, zona_id, referencia, nota) on public.pedido to authenticated;
grant update (estado, domiciliario_id) on public.pedido to authenticated;
grant delete on public.pedido to authenticated;
grant insert (pedido_id, producto_id, cantidad) on public.detalle_pedido to authenticated;
grant insert (pedido_id, metodo, valor_entregado, entidad_pago_id) on public.pago to authenticated;

-- El cliente ve los suyos; el domiciliario, los pendientes y los que tomó.
create policy "pedido_visible" on public.pedido
  for select to authenticated using (
    cliente_id = (select auth.uid())
    or (
      (select public.rol_actual()) = 'proveedor'
      and (estado = 'pendiente' or domiciliario_id = (select auth.uid()))
    )
  );

create policy "cliente_crea_pedido" on public.pedido
  for insert to authenticated with check (
    cliente_id = (select auth.uid())
    and (select public.rol_actual()) = 'cliente'
  );

-- El cliente solo cancela, y solo mientras está pendiente.
create policy "cliente_cancela_pedido" on public.pedido
  for update to authenticated
  using (cliente_id = (select auth.uid()) and estado = 'pendiente')
  with check (cliente_id = (select auth.uid()) and estado = 'cancelado');

-- El domiciliario toma un pendiente o avanza uno suyo.
create policy "domiciliario_atiende_pedido" on public.pedido
  for update to authenticated
  using (
    (select public.rol_actual()) = 'proveedor'
    and (estado = 'pendiente' or domiciliario_id = (select auth.uid()))
  )
  with check (domiciliario_id = (select auth.uid()));

-- security definer para no pasar por la RLS de `pago`, que a su vez
-- consulta `pedido` (sería recursión infinita).
create or replace function public.pedido_tiene_pago(p_pedido_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.pago where pedido_id = p_pedido_id)
$$;
revoke execute on function public.pedido_tiene_pago(uuid) from public;
grant execute on function public.pedido_tiene_pago(uuid) to authenticated;

-- Solo para deshacer un pedido que no terminó de guardarse (sin detalles o sin pago).
create policy "cliente_borra_pedido_incompleto" on public.pedido
  for delete to authenticated using (
    cliente_id = (select auth.uid())
    and estado = 'pendiente'
    and not public.pedido_tiene_pago(id)
  );

-- Detalles, pago e historial siguen la visibilidad del pedido.
create policy "detalle_visible" on public.detalle_pedido
  for select to authenticated using (
    exists (select 1 from public.pedido p where p.id = pedido_id)
  );
create policy "cliente_agrega_detalle" on public.detalle_pedido
  for insert to authenticated with check (
    exists (
      select 1 from public.pedido p
      where p.id = pedido_id and p.cliente_id = (select auth.uid()) and p.estado = 'pendiente'
    )
    and not public.pedido_tiene_pago(pedido_id)
  );

create policy "pago_visible" on public.pago
  for select to authenticated using (
    exists (select 1 from public.pedido p where p.id = pedido_id)
  );
create policy "cliente_registra_pago" on public.pago
  for insert to authenticated with check (
    exists (
      select 1 from public.pedido p
      where p.id = pedido_id and p.cliente_id = (select auth.uid()) and p.estado = 'pendiente'
    )
  );

create policy "historial_visible" on public.historial_estado
  for select to authenticated using (
    exists (select 1 from public.pedido p where p.id = pedido_id)
  );

-- Usuario: además del propio perfil, se ve el de la contraparte de un pedido
-- visible (el cliente ve a su domiciliario y el domiciliario a sus clientes).
create policy "usuario_ve_contraparte" on public.usuario
  for select to authenticated using (
    exists (
      select 1 from public.pedido p
      where p.cliente_id = usuario.id or p.domiciliario_id = usuario.id
    )
  );

-- ---------- Datos iniciales ----------

insert into public.categoria (nombre, orden) values
  ('Cafés', 1), ('Bebidas frías', 2), ('Snacks', 3);

insert into public.producto (categoria_id, nombre, descripcion, precio, imagen_path, disponible)
select c.id, p.nombre, p.descripcion, p.precio, p.imagen_path, p.disponible
from (values
  ('Cafés',         'Americano',   'Café de origen del Valle',       4000, 'americano.jpg',   true),
  ('Cafés',         'Capuchino',   'Espresso con leche espumada',    6500, 'capuchino.jpg',   true),
  ('Cafés',         'Mocca',       'Espresso, chocolate y leche',    7500, 'mocca.jpg',       true),
  ('Bebidas frías', 'Café helado', 'Espresso, leche y hielo',        6000, 'cafe-helado.jpg', true),
  ('Snacks',        'Pandebono',   'Recién horneado, con queso',     3000, 'pandebono.jpg',   true),
  ('Snacks',        'Croissant',   'Hojaldre de mantequilla',        4500, 'croissant.jpg',   false)
) as p(categoria, nombre, descripcion, precio, imagen_path, disponible)
join public.categoria c on c.nombre = p.categoria;

insert into public.zona (nombre, orden) values
  ('Biblioteca · Edificio L', 1),
  ('Edificio D · Salones', 2),
  ('Laboratorios · Edificio M', 3),
  ('Cafetería central', 4),
  ('Bloque A · Administración', 5),
  ('Coliseo y canchas', 6);

insert into public.entidad_pago (nombre, tipo_destino, dato_destino, titular) values
  ('Nequi',       'celular', '300 123 4567',          'Mocca Go!'),
  ('Bancolombia', 'cuenta',  'Ahorros 123-456789-01', 'Mocca Go!'),
  ('Bre-B',       'llave',   '@moccago',              'Mocca Go!');

-- ---------- Tiempo real (se usa en el sprint 3) ----------
-- Se deja listo: la app empieza a escuchar con stream() cuando el curso
-- llegue a la sección Realtime.
alter publication supabase_realtime add table public.pedido;
