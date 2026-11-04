-- Run this once in Supabase → SQL Editor → New query → Run.
-- Creates the bookings table with:
--   * one booking per resource/day/slot (no double booking, enforced by the database)
--   * everyone can see bookings, but never the secret cancel token
--   * only the device that made a booking (holding its token) can cancel it

create table if not exists public.bookings (
  id         uuid primary key default gen_random_uuid(),
  resource   text not null default 'laundry' check (char_length(resource) <= 40),
  day        date not null,
  slot       text not null check (slot ~ '^\d\d:\d\d-\d\d:\d\d$'),
  name       text not null check (char_length(name) between 1 and 40),
  note       text not null default '' check (char_length(note) <= 100),
  token      uuid not null,
  created_at timestamptz not null default now(),
  unique (resource, day, slot)
);

alter table public.bookings enable row level security;

drop policy if exists "anyone can read"  on public.bookings;
drop policy if exists "anyone can book"  on public.bookings;
create policy "anyone can read" on public.bookings for select to anon using (true);
create policy "anyone can book" on public.bookings for insert to anon
  with check (day >= current_date - 1 and day <= current_date + 70);

-- Column-level permissions: the token can be written but never read back.
revoke all on public.bookings from anon, authenticated;
grant select (id, resource, day, slot, name, note, created_at) on public.bookings to anon;
grant insert (resource, day, slot, name, note, token)          on public.bookings to anon;

-- Cancelling goes through this function, which checks the token.
create or replace function public.cancel_booking(p_id uuid, p_token uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  with d as (delete from bookings where id = p_id and token = p_token returning 1)
  select exists (select 1 from d);
$$;

revoke all on function public.cancel_booking(uuid, uuid) from public;
grant execute on function public.cancel_booking(uuid, uuid) to anon;

-- Optional housekeeping: delete bookings older than 60 days (run manually or via pg_cron).
-- delete from public.bookings where day < current_date - 60;
