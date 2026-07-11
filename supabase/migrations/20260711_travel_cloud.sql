-- 亿蛋大帝旅游宝：用户资料、收藏城市与云端行程
-- 在 Supabase Dashboard > SQL Editor 中完整运行一次。

create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '旅行家' check (char_length(display_name) between 1 and 40),
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.saved_cities (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  city_key text not null,
  city_data jsonb not null,
  created_at timestamptz not null default now(),
  unique (user_id, city_key)
);

create table if not exists public.saved_trips (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null check (char_length(title) between 1 and 100),
  city_data jsonb not null,
  travel_date date not null,
  days smallint not null check (days between 1 and 30),
  budget integer not null check (budget >= 0),
  itinerary jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists saved_cities_user_created_idx on public.saved_cities (user_id, created_at desc);
create index if not exists saved_trips_user_updated_idx on public.saved_trips (user_id, updated_at desc);

alter table public.profiles enable row level security;
alter table public.saved_cities enable row level security;
alter table public.saved_trips enable row level security;

drop policy if exists "profiles_select_own" on public.profiles;
create policy "profiles_select_own" on public.profiles for select to authenticated
  using ((select auth.uid()) = id);
drop policy if exists "profiles_insert_own" on public.profiles;
create policy "profiles_insert_own" on public.profiles for insert to authenticated
  with check ((select auth.uid()) = id);
drop policy if exists "profiles_update_own" on public.profiles;
create policy "profiles_update_own" on public.profiles for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

drop policy if exists "saved_cities_select_own" on public.saved_cities;
create policy "saved_cities_select_own" on public.saved_cities for select to authenticated
  using ((select auth.uid()) = user_id);
drop policy if exists "saved_cities_insert_own" on public.saved_cities;
create policy "saved_cities_insert_own" on public.saved_cities for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists "saved_cities_update_own" on public.saved_cities;
create policy "saved_cities_update_own" on public.saved_cities for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
drop policy if exists "saved_cities_delete_own" on public.saved_cities;
create policy "saved_cities_delete_own" on public.saved_cities for delete to authenticated
  using ((select auth.uid()) = user_id);

drop policy if exists "saved_trips_select_own" on public.saved_trips;
create policy "saved_trips_select_own" on public.saved_trips for select to authenticated
  using ((select auth.uid()) = user_id);
drop policy if exists "saved_trips_insert_own" on public.saved_trips;
create policy "saved_trips_insert_own" on public.saved_trips for insert to authenticated
  with check ((select auth.uid()) = user_id);
drop policy if exists "saved_trips_update_own" on public.saved_trips;
create policy "saved_trips_update_own" on public.saved_trips for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
drop policy if exists "saved_trips_delete_own" on public.saved_trips;
create policy "saved_trips_delete_own" on public.saved_trips for delete to authenticated
  using ((select auth.uid()) = user_id);

grant select, insert, update on public.profiles to authenticated;
grant select, insert, update, delete on public.saved_cities to authenticated;
grant select, insert, update, delete on public.saved_trips to authenticated;

create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at before update on public.profiles
for each row execute function public.set_updated_at();
drop trigger if exists saved_trips_set_updated_at on public.saved_trips;
create trigger saved_trips_set_updated_at before update on public.saved_trips
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, display_name)
  values (new.id, coalesce(nullif(new.raw_user_meta_data ->> 'display_name', ''), split_part(new.email, '@', 1), '旅行家'))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

insert into public.profiles (id, display_name)
select id, coalesce(nullif(raw_user_meta_data ->> 'display_name', ''), split_part(email, '@', 1), '旅行家')
from auth.users
on conflict (id) do nothing;
