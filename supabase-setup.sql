-- ===========================================================
-- CINEPHILE'S LEDGER — Supabase setup
-- Run this in Supabase Dashboard → SQL Editor → New Query → Run
-- ===========================================================

-- =========================
-- 1) The shared Top 100
-- =========================
create table if not exists public.canon (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  year        integer,
  poster      text,
  rank        integer not null,
  type        text not null default 'movie' check (type in ('movie','series')),
  added_by    text,
  created_at  timestamptz not null default now()
);
create index if not exists canon_rank_idx on public.canon (rank);

-- =========================
-- 2) Personal Top 20s (one row per movie, scoped to an owner)
-- =========================
create table if not exists public.personal_lists (
  id          uuid primary key default gen_random_uuid(),
  owner       text not null,                  -- the person whose list this is
  title       text not null,
  year        integer,
  poster      text,
  rank        integer not null,
  type        text not null default 'movie' check (type in ('movie','series')),
  created_at  timestamptz not null default now()
);
create index if not exists personal_owner_rank_idx on public.personal_lists (owner, rank);

-- =========================
-- 3) Curators table (so we know who's allowed and what to show in the toggle)
-- =========================
create table if not exists public.curators (
  name        text primary key,
  joined_at   timestamptz not null default now()
);

-- =========================
-- 4) Row-Level Security
--    These policies are wide-open by design — for a small private family app
--    where you're sharing the URL among yourselves. If you want to lock down
--    so each person can only edit their own Top 20, see the README.
-- =========================
alter table public.canon          enable row level security;
alter table public.personal_lists enable row level security;
alter table public.curators       enable row level security;

drop policy if exists "canon_read"          on public.canon;
drop policy if exists "canon_write"         on public.canon;
drop policy if exists "personal_read"       on public.personal_lists;
drop policy if exists "personal_write"      on public.personal_lists;
drop policy if exists "curators_read"       on public.curators;
drop policy if exists "curators_write"      on public.curators;

create policy "canon_read"     on public.canon          for select using (true);
create policy "canon_write"    on public.canon          for all    using (true) with check (true);
create policy "personal_read"  on public.personal_lists for select using (true);
create policy "personal_write" on public.personal_lists for all    using (true) with check (true);
create policy "curators_read"  on public.curators       for select using (true);
create policy "curators_write" on public.curators       for all    using (true) with check (true);

-- =========================
-- 5) Realtime — broadcast row changes to all browsers
-- =========================
do $$
begin
  begin
    alter publication supabase_realtime add table public.canon;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.personal_lists;
  exception when duplicate_object then null;
  end;
  begin
    alter publication supabase_realtime add table public.curators;
  exception when duplicate_object then null;
  end;
end $$;
