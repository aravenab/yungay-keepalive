-- =============================================================
--  SETUP EN SUPABASE  (correr UNA sola vez)
--  Donde: Supabase -> SQL Editor -> New query -> pegar todo -> Run
-- =============================================================

-- 1. Una tabla minima, existe solo para el keep-alive.
create table if not exists public.keep_alive (
  id smallint primary key,
  last_ping timestamptz default now()
);

-- 2. Metemos la unica fila que vamos a actualizar.
insert into public.keep_alive (id, last_ping) values (1, now())
on conflict (id) do nothing;

-- 3. Activamos RLS (Row Level Security) para que nadie pueda leer ni
--    escribir esta tabla directamente desde la API publica.
alter table public.keep_alive enable row level security;
-- Ojo: NO creamos ninguna politica. Sin politicas + RLS activado =
-- la tabla queda blindada contra acceso directo por la llave publica.

-- 4. Creamos una funcion que actualiza la fecha del ping.
--    "security definer" hace que la funcion corra con permisos del dueno,
--    asi puede tocar la tabla aunque RLS este activo.
create or replace function public.ping_keep_alive()
returns timestamptz
language sql
security definer
set search_path = public
as $$
  update public.keep_alive set last_ping = now() where id = 1
  returning last_ping;
$$;

-- 5. Le damos permiso al rol "anon" (el de tu llave publica) para ejecutar
--    SOLO esa funcion. No puede hacer nada mas con esa llave.
grant execute on function public.ping_keep_alive() to anon;

-- =============================================================
--  VERIFICACION (opcional, corre esto despues del keep-alive
--  para confirmar que la fecha se actualizo):
--
--  select * from keep_alive;
-- =============================================================
