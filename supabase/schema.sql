-- ============================================
-- AIDXON 문의 접수 테이블
-- 실행 방법: Supabase 프로젝트 → SQL Editor 에 붙여넣고 Run
-- ============================================

create table if not exists public.contacts (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),

  category text not null check (category in ('문의하기', '도입상담', '프로젝트제안')),
  company text,
  name text not null,
  phone text not null,
  email text,
  message text,

  status text not null default 'new' check (status in ('new', 'contacted', 'closed')),
  notified_at timestamptz,

  user_agent text,
  referrer text
);

create index if not exists contacts_created_at_idx on public.contacts (created_at desc);
create index if not exists contacts_status_idx on public.contacts (status);

-- ============================================
-- Row Level Security
-- 익명(anon) 사용자는 insert 만 허용, select/update/delete 는 차단
-- ============================================

alter table public.contacts enable row level security;

drop policy if exists "anon_can_insert" on public.contacts;
create policy "anon_can_insert"
  on public.contacts
  for insert
  to anon
  with check (true);

-- 관리자(service_role) 는 기본적으로 RLS 를 우회하므로 별도 정책 불필요
