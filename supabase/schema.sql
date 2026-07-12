-- Yogis — database schema (draft v1)
-- Run this in the Supabase SQL editor after creating a project.
-- Design mirrors the data currently hardcoded in src/pages/*.astro.

-- ============================================================
-- Reference data (publicly readable)
-- ============================================================

create table if not exists studios (
  id          bigint generated always as identity primary key,
  name        text not null,
  address     text,
  hours       text,
  created_at  timestamptz not null default now()
);

create table if not exists teachers (
  id          bigint generated always as identity primary key,
  name        text not null,
  bio         text,
  created_at  timestamptz not null default now()
);

-- Class "types" (Sunrise Vinyasa, Gentle Hatha, ...)
create table if not exists classes (
  id            bigint generated always as identity primary key,
  name          text not null,
  description   text,
  level         text not null check (level in ('Beginner','All levels','Intermediate','Advanced')),
  duration_min  int  not null default 60,
  created_at    timestamptz not null default now()
);

-- Scheduled instances of a class (what appears on /schedule)
create table if not exists sessions (
  id          bigint generated always as identity primary key,
  class_id    bigint not null references classes(id) on delete cascade,
  teacher_id  bigint references teachers(id) on delete set null,
  studio_id   bigint references studios(id) on delete set null,
  starts_at   timestamptz not null,
  duration_min int not null default 60,
  capacity    int not null default 12,
  created_at  timestamptz not null default now()
);
create index if not exists sessions_starts_at_idx on sessions (starts_at);

-- ============================================================
-- Members (profile row linked to Supabase auth.users)
-- ============================================================

create table if not exists members (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  created_at  timestamptz not null default now()
);

-- Auto-create a member profile when a new auth user signs up
create or replace function handle_new_user()
returns trigger language plpgsql security definer as $$
begin
  insert into public.members (id, full_name)
  values (new.id, new.raw_user_meta_data ->> 'full_name')
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ============================================================
-- Bookings
-- ============================================================

create table if not exists bookings (
  id          bigint generated always as identity primary key,
  member_id   uuid not null references members(id) on delete cascade,
  session_id  bigint not null references sessions(id) on delete cascade,
  status      text not null default 'booked' check (status in ('booked','cancelled')),
  created_at  timestamptz not null default now(),
  unique (member_id, session_id)
);

-- Convenience view: spots remaining per session
create or replace view session_availability as
select
  s.id as session_id,
  s.capacity,
  s.capacity - coalesce(count(b.id) filter (where b.status = 'booked'), 0) as spots_left
from sessions s
left join bookings b on b.session_id = s.id
group by s.id, s.capacity;

-- ============================================================
-- Online courses
-- ============================================================

create table if not exists courses (
  id           bigint generated always as identity primary key,
  title        text not null,
  description  text,
  price_cents  int not null default 0,
  created_at   timestamptz not null default now()
);

create table if not exists lessons (
  id           bigint generated always as identity primary key,
  course_id    bigint not null references courses(id) on delete cascade,
  title        text not null,
  position     int not null default 0,
  video_id     text,          -- Bunny/Cloudflare Stream id
  duration_min int,
  is_preview   boolean not null default false,
  created_at   timestamptz not null default now()
);

create table if not exists purchases (
  id                bigint generated always as identity primary key,
  member_id         uuid not null references members(id) on delete cascade,
  course_id         bigint not null references courses(id) on delete cascade,
  stripe_payment_id text,
  created_at        timestamptz not null default now(),
  unique (member_id, course_id)
);

-- ============================================================
-- Row Level Security
-- ============================================================

alter table studios  enable row level security;
alter table teachers enable row level security;
alter table classes  enable row level security;
alter table sessions enable row level security;
alter table members  enable row level security;
alter table bookings enable row level security;
alter table courses  enable row level security;
alter table lessons  enable row level security;
alter table purchases enable row level security;

-- Public read for reference/catalog data
create policy "public read studios"  on studios  for select using (true);
create policy "public read teachers" on teachers for select using (true);
create policy "public read classes"  on classes  for select using (true);
create policy "public read sessions" on sessions for select using (true);
create policy "public read courses"  on courses  for select using (true);
create policy "public read lessons"  on lessons  for select using (true);

-- Members: a user can see and update only their own profile
create policy "own member row - select" on members for select using (auth.uid() = id);
create policy "own member row - update" on members for update using (auth.uid() = id);

-- Bookings: a member manages only their own
create policy "own bookings - select" on bookings for select using (auth.uid() = member_id);
create policy "own bookings - insert" on bookings for insert with check (auth.uid() = member_id);
create policy "own bookings - update" on bookings for update using (auth.uid() = member_id);

-- Purchases: a member can read their own. Inserts come from the Stripe
-- webhook using the service-role key (which bypasses RLS), so no insert policy here.
create policy "own purchases - select" on purchases for select using (auth.uid() = member_id);
