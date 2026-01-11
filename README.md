# qr_wali_santri

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

saya Akan menulis sql supabase disini aja :

-- =========================================
-- DROP TABLE (RESET JIKA ADA)
-- =========================================
drop table if exists public.attendances cascade;
drop table if exists public.guardians cascade;

-- =========================================
-- TABLE: GUARDIANS
-- =========================================
create table public.guardians (
  id_wali       int4 primary key,
  nama_wali     text not null,
  desa          text not null,
  kecamatan     text not null,
  kabupaten     text not null,
  nama_murid    text not null,
  kelas_murid   text not null,
  created_at    timestamptz not null default now()
);

-- =========================================
-- TABLE: ATTENDANCES
-- =========================================
create table public.attendances (
  id           int4 generated always as identity primary key,
  guardian_id  int4 not null
    references public.guardians(id_wali)
    on delete cascade,
  event_name   text not null,
  scanned_at   timestamptz not null default now()
);

-- =========================================
-- UNIQUE: 1 ORANG 1 KALI PER HARI PER EVENT
-- =========================================
create unique index unique_attendance_per_day
on public.attendances (
  guardian_id,
  date(scanned_at),
  event_name
);

-- =========================================
-- ENABLE ROW LEVEL SECURITY
-- =========================================
alter table public.guardians enable row level security;
alter table public.attendances enable row level security;

-- =========================================
-- BERSIHKAN POLICY LAMA (AMAN)
-- =========================================
drop policy if exists "Anon read guardians" on public.guardians;
drop policy if exists "Auth read guardians" on public.guardians;

drop policy if exists "Anon read attendances" on public.attendances;
drop policy if exists "Auth read attendances" on public.attendances;

drop policy if exists "Anon insert attendances" on public.attendances;
drop policy if exists "Auth insert attendances" on public.attendances;

-- =========================================
-- POLICY: ANON
-- =========================================
create policy "Anon read guardians"
  on public.guardians
  for select
  to anon
  using (true);

create policy "Anon read attendances"
  on public.attendances
  for select
  to anon
  using (true);

create policy "Anon insert attendances"
  on public.attendances
  for insert
  to anon
  with check (true);

-- =========================================
-- POLICY: AUTHENTICATED
-- =========================================
create policy "Auth read guardians"
  on public.guardians
  for select
  to authenticated
  using (true);

create policy "Auth read attendances"
  on public.attendances
  for select
  to authenticated
  using (true);

create policy "Auth insert attendances"
  on public.attendances
  for insert
  to authenticated
  with check (true);
