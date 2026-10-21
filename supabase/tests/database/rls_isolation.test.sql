-- pgTAP: one student can never see or reference another student's data.
-- Run with `supabase test db` (needs the local Docker stack; runs in CI).
begin;
create extension if not exists pgtap with schema extensions;
select plan(9);

-- Two users; the sign-up trigger creates their profiles.
insert into auth.users (id, email) values
  ('11111111-1111-1111-1111-111111111111', 'anna@example.test'),
  ('22222222-2222-2222-2222-222222222222', 'ben@example.test');

select is((select count(*)::int from public.profiles), 2, 'sign-up trigger creates profiles');

-- Anna creates a subject and a Meldung.
set local role authenticated;
set local request.jwt.claims = '{"sub": "11111111-1111-1111-1111-111111111111", "role": "authenticated"}';

insert into public.subjects (id, name) values ('aaaaaaaa-0000-0000-0000-000000000001', 'Mathe');
insert into public.participation_entries (subject_id, recorded_at, local_date)
  values ('aaaaaaaa-0000-0000-0000-000000000001', now(), current_date);

select is((select count(*)::int from public.subjects), 1, 'Anna sees her subject');
select is((select user_id from public.subjects limit 1),
  '11111111-1111-1111-1111-111111111111'::uuid, 'user_id defaults to the caller');

-- Ben sees nothing of Anna's.
set local request.jwt.claims = '{"sub": "22222222-2222-2222-2222-222222222222", "role": "authenticated"}';

select is((select count(*)::int from public.subjects), 0, 'Ben cannot read Anna''s subjects');
select is((select count(*)::int from public.participation_entries), 0, 'Ben cannot read Anna''s Meldungen');
select is((select count(*)::int from public.profiles), 1, 'Ben only sees his own profile');

select throws_ok(
  $$ insert into public.subjects (name, user_id) values ('Fake', '11111111-1111-1111-1111-111111111111') $$,
  '42501', null, 'Ben cannot insert rows owned by Anna');

select throws_ok(
  $$ insert into public.lessons (subject_id, weekday, start_minute, end_minute)
     values ('aaaaaaaa-0000-0000-0000-000000000001', 0, 480, 525) $$,
  '42501', null, 'Ben cannot attach a lesson to Anna''s subject');

update public.subjects set name = 'Hacked' where id = 'aaaaaaaa-0000-0000-0000-000000000001';
set local request.jwt.claims = '{"sub": "11111111-1111-1111-1111-111111111111", "role": "authenticated"}';
select is((select name from public.subjects where id = 'aaaaaaaa-0000-0000-0000-000000000001'),
  'Mathe', 'Ben''s update did not touch Anna''s subject');

select * from finish();
rollback;
