-- Melde Planner — initial schema (Phase 1)
--
-- Offline-first sync model:
--   * ids are client-generated UUIDs so rows can be created offline;
--   * updated_at drives last-writer-wins conflict resolution;
--   * deleted_at is a tombstone so deletions sync instead of vanishing.
-- Every table is private to its owner via RLS. There are no shared rows.

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

-- ---------------------------------------------------------------------------
-- Helpers
-- ---------------------------------------------------------------------------

create or replace function private.touch_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Profiles: one row per auth user, created by trigger on sign-up.
-- ---------------------------------------------------------------------------

create table public.profiles (
  user_id        uuid primary key references auth.users (id) on delete cascade,
  display_name   text check (char_length(display_name) <= 80),
  locale         text not null default 'de' check (locale in ('de', 'tr', 'en')),
  theme          text not null default 'system'
                 check (theme in ('system', 'light', 'dark', 'purple', 'blue', 'green', 'orange')),
  -- Bundesland code (e.g. 'NW', 'BY'); grading defaults depend on it.
  state_code     text check (state_code ~ '^[A-Z]{2}$'),
  school_stage   text not null default 'lower'
                 check (school_stage in ('lower', 'upper')),
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (user_id) values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;
revoke execute on function private.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- ---------------------------------------------------------------------------
-- Grading profiles: how a subject combines written and oral grades.
-- Rules differ between states and schools, so everything is configurable.
-- ---------------------------------------------------------------------------

create table public.grading_profiles (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name            text not null check (char_length(name) between 1 and 60),
  scale           text not null check (scale in ('traditional', 'points')),
  written_weight  numeric(6, 3) not null default 1 check (written_weight >= 0),
  oral_weight     numeric(6, 3) not null default 1 check (oral_weight >= 0),
  rounding        text not null default 'half_toward_better'
                  check (rounding in ('half_toward_better', 'half_toward_worse')),
  tendency_step   numeric(3, 2) not null default 0.25 check (tendency_step between 0 and 0.5),
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now(),
  deleted_at      timestamptz,
  check (written_weight + oral_weight > 0)
);

-- ---------------------------------------------------------------------------
-- Subjects
-- ---------------------------------------------------------------------------

create table public.subjects (
  id                  uuid primary key default gen_random_uuid(),
  user_id             uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name                text not null check (char_length(name) between 1 and 60),
  short_name          text check (char_length(short_name) <= 6),
  -- Palette key from the app's design system, not a raw hex value.
  color_key           text not null default 'blue' check (char_length(color_key) <= 20),
  symbol_name         text not null default 'book.closed' check (char_length(symbol_name) <= 60),
  teacher             text check (char_length(teacher) <= 80),
  grading_profile_id  uuid references public.grading_profiles (id) on delete set null,
  -- Weight of this subject in the overall average (e.g. Hauptfach 2).
  overall_weight      numeric(4, 2) not null default 1 check (overall_weight > 0),
  sort_order          integer not null default 0,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),
  deleted_at          timestamptz
);

-- ---------------------------------------------------------------------------
-- Timetable
-- ---------------------------------------------------------------------------

create table public.lessons (
  id            uuid primary key default gen_random_uuid(),
  user_id       uuid not null default auth.uid() references auth.users (id) on delete cascade,
  subject_id    uuid not null references public.subjects (id) on delete cascade,
  weekday       smallint not null check (weekday between 0 and 6), -- 0 = Monday
  start_minute  smallint not null check (start_minute between 0 and 1439),
  end_minute    smallint not null check (end_minute between 1 and 1440),
  week_parity   text not null default 'every' check (week_parity in ('every', 'a', 'b')),
  room          text check (char_length(room) <= 20),
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now(),
  deleted_at    timestamptz,
  check (end_minute > start_minute)
);

create table public.holidays (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null default auth.uid() references auth.users (id) on delete cascade,
  name        text not null check (char_length(name) between 1 and 60),
  first_day   date not null,
  last_day    date not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  deleted_at  timestamptz,
  check (last_day >= first_day)
);

create table public.timetable_changes (
  id                     uuid primary key default gen_random_uuid(),
  user_id                uuid not null default auth.uid() references auth.users (id) on delete cascade,
  lesson_id              uuid not null references public.lessons (id) on delete cascade,
  on_date                date not null,
  kind                   text not null check (kind in ('cancelled', 'substituted')),
  substitute_subject_id  uuid references public.subjects (id) on delete set null,
  substitute_room        text check (char_length(substitute_room) <= 20),
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  deleted_at             timestamptz,
  unique (lesson_id, on_date)
);

-- ---------------------------------------------------------------------------
-- Melde Tracker. Activity counts only; never an oral grade.
-- ---------------------------------------------------------------------------

create table public.participation_entries (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  subject_id   uuid references public.subjects (id) on delete set null,
  lesson_id    uuid references public.lessons (id) on delete set null,
  recorded_at  timestamptz not null,
  -- Local wall-clock date at recording time; statistics group by it.
  local_date   date not null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);

-- ---------------------------------------------------------------------------
-- Assessments (grades). Teacher-assigned values only.
-- ---------------------------------------------------------------------------

create table public.assessments (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  subject_id   uuid not null references public.subjects (id) on delete cascade,
  title        text check (char_length(title) <= 80),
  category     text not null check (category in ('written', 'oral')),
  -- 1.0–6.0 on the traditional scale or 0–15 points; the app validates against
  -- the subject's grading profile, this check only rejects impossible values.
  value        numeric(4, 2) not null check (value between 0 and 15),
  weight       numeric(5, 2) not null default 1 check (weight > 0),
  assessed_on  date not null,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now(),
  deleted_at   timestamptz
);

-- ---------------------------------------------------------------------------
-- updated_at triggers, indexes for RLS and sync ("changed since" pulls)
-- ---------------------------------------------------------------------------

do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles', 'grading_profiles', 'subjects', 'lessons', 'holidays',
    'timetable_changes', 'participation_entries', 'assessments'
  ] loop
    execute format(
      'create trigger touch_updated_at before update on public.%I
         for each row execute function private.touch_updated_at()', t);
  end loop;

  foreach t in array array[
    'grading_profiles', 'subjects', 'lessons', 'holidays',
    'timetable_changes', 'participation_entries', 'assessments'
  ] loop
    execute format('create index %I on public.%I (user_id, updated_at)', t || '_sync_idx', t);
  end loop;
end;
$$;

-- Foreign keys used in joins and cascades.
create index subjects_grading_profile_idx on public.subjects (grading_profile_id);
create index lessons_subject_idx on public.lessons (subject_id);
create index timetable_changes_lesson_idx on public.timetable_changes (lesson_id);
create index timetable_changes_subject_idx on public.timetable_changes (substitute_subject_id);
create index participation_subject_idx on public.participation_entries (subject_id);
create index participation_lesson_idx on public.participation_entries (lesson_id);
create index participation_user_date_idx on public.participation_entries (user_id, local_date)
  where deleted_at is null;
create index assessments_subject_idx on public.assessments (subject_id);

-- ---------------------------------------------------------------------------
-- Row Level Security: owner-only access on every table.
-- (select auth.uid()) is evaluated once per statement, not per row.
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
create policy "own profile: read" on public.profiles
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "own profile: update" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

do $$
declare
  t text;
begin
  foreach t in array array[
    'grading_profiles', 'subjects', 'lessons', 'holidays',
    'timetable_changes', 'participation_entries', 'assessments'
  ] loop
    execute format('alter table public.%I enable row level security', t);
    execute format(
      'create policy "own rows: read" on public.%I for select to authenticated
         using ((select auth.uid()) = user_id)', t);
    execute format(
      'create policy "own rows: insert" on public.%I for insert to authenticated
         with check ((select auth.uid()) = user_id)', t);
    execute format(
      'create policy "own rows: update" on public.%I for update to authenticated
         using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id)', t);
    execute format(
      'create policy "own rows: delete" on public.%I for delete to authenticated
         using ((select auth.uid()) = user_id)', t);
  end loop;
end;
$$;

-- References must point at the caller's own rows; RLS alone does not check
-- that a foreign key targets a row the user owns.
create or replace function private.assert_same_owner()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  ref_table text := tg_argv[0];
  ref_column text := tg_argv[1];
  ref_id uuid;
  ok boolean;
begin
  execute format('select ($1).%I', ref_column) into ref_id using new;
  if ref_id is null then
    return new;
  end if;
  execute format('select exists (select 1 from public.%I where id = $1 and user_id = $2)', ref_table)
    into ok using ref_id, new.user_id;
  if not ok then
    raise exception 'referenced % row does not belong to the same user', ref_table
      using errcode = '42501';
  end if;
  return new;
end;
$$;
revoke execute on function private.assert_same_owner() from public, anon, authenticated;

create trigger same_owner_grading_profile before insert or update on public.subjects
  for each row execute function private.assert_same_owner('grading_profiles', 'grading_profile_id');
create trigger same_owner_subject before insert or update on public.lessons
  for each row execute function private.assert_same_owner('subjects', 'subject_id');
create trigger same_owner_lesson before insert or update on public.timetable_changes
  for each row execute function private.assert_same_owner('lessons', 'lesson_id');
create trigger same_owner_substitute before insert or update on public.timetable_changes
  for each row execute function private.assert_same_owner('subjects', 'substitute_subject_id');
create trigger same_owner_subject before insert or update on public.participation_entries
  for each row execute function private.assert_same_owner('subjects', 'subject_id');
create trigger same_owner_lesson before insert or update on public.participation_entries
  for each row execute function private.assert_same_owner('lessons', 'lesson_id');
create trigger same_owner_subject before insert or update on public.assessments
  for each row execute function private.assert_same_owner('subjects', 'subject_id');

-- Anonymous users get nothing; authenticated users only what RLS allows.
revoke all on all tables in schema public from anon;

-- ---------------------------------------------------------------------------
-- Storage: private bucket for exam scans and PDFs, one folder per user.
-- Object paths must start with "<user id>/".
-- ---------------------------------------------------------------------------

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('documents', 'documents', false, 52428800, array['application/pdf', 'image/jpeg', 'image/png', 'image/heic'])
on conflict (id) do nothing;

create policy "own documents: read" on storage.objects
  for select to authenticated
  using (bucket_id = 'documents' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "own documents: insert" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'documents' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "own documents: update" on storage.objects
  for update to authenticated
  using (bucket_id = 'documents' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "own documents: delete" on storage.objects
  for delete to authenticated
  using (bucket_id = 'documents' and (storage.foldername(name))[1] = (select auth.uid())::text);
