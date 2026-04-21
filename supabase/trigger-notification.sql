-- ============================================
-- AIDXON 문의 접수 시 Resend 이메일 알림
-- 방식: pg_net 확장 + Postgres 트리거 (Edge Function 불필요)
--
-- 실행 전 준비:
-- 1) Resend API 키 발급 (https://resend.com → API Keys)
-- 2) 아래 SQL 실행 전, Supabase → Project Settings → Vault 에서
--    Secret 하나 추가:
--       Name:   resend_api_key
--       Value:  re_... (Resend 에서 발급받은 키)
-- 3) 이 파일 전체를 Supabase SQL Editor 에 붙여넣고 Run
-- ============================================

-- pg_net 확장 활성화 (외부 HTTP 호출용)
create extension if not exists pg_net with schema extensions;

-- ============================================
-- 알림 함수
-- ============================================
create or replace function public.notify_new_contact()
returns trigger
language plpgsql
security definer
set search_path = public, extensions, vault
as $$
declare
  v_api_key text;
  v_label text;
  v_subject text;
  v_html text;
  v_body jsonb;
  v_notify_to text := 'aidxon0320@gmail.com';
  v_notify_from text := 'AIDXON <onboarding@resend.dev>';
  v_request_id bigint;
begin
  -- Vault 에서 API 키 조회
  select decrypted_secret into v_api_key
  from vault.decrypted_secrets
  where name = 'resend_api_key'
  limit 1;

  if v_api_key is null then
    raise log 'notify_new_contact: resend_api_key not found in Vault';
    return new;
  end if;

  -- 분류 라벨
  v_label := case new.category
    when '도입상담' then '도입 상담 신청'
    when '프로젝트제안' then '프로젝트 제안 요청'
    else '문의하기'
  end;

  v_subject := '[AIDXON ' || v_label || '] ' || new.name || ' (' || new.phone || ')';

  -- 이메일 본문 (HTML)
  v_html := format(
    $html$
    <div style="font-family: -apple-system, 'Pretendard', sans-serif; max-width: 560px; padding: 24px; background: #fff; color: #111;">
      <div style="padding: 16px 20px; background: #0b1220; border-radius: 12px; margin-bottom: 20px;">
        <div style="font-size: 12px; color: #00b4d8; letter-spacing: 0.12em; text-transform: uppercase;">NEW INQUIRY</div>
        <div style="font-size: 20px; font-weight: 700; color: #fff; margin-top: 6px;">[%s] %s</div>
      </div>
      <table style="width: 100%%; border-collapse: collapse; font-size: 14px;">
        <tr><td style="padding: 10px 0; color: #666; width: 100px;">분류</td><td style="padding: 10px 0;"><strong>%s</strong></td></tr>
        <tr><td style="padding: 10px 0; color: #666; border-top: 1px solid #eee;">성명</td><td style="padding: 10px 0; border-top: 1px solid #eee;">%s</td></tr>
        <tr><td style="padding: 10px 0; color: #666; border-top: 1px solid #eee;">회사명</td><td style="padding: 10px 0; border-top: 1px solid #eee;">%s</td></tr>
        <tr><td style="padding: 10px 0; color: #666; border-top: 1px solid #eee;">연락처</td><td style="padding: 10px 0; border-top: 1px solid #eee;"><a href="tel:%s" style="color:#00b4d8; text-decoration:none;">%s</a></td></tr>
        <tr><td style="padding: 10px 0; color: #666; border-top: 1px solid #eee;">이메일</td><td style="padding: 10px 0; border-top: 1px solid #eee;">%s</td></tr>
        <tr><td style="padding: 10px 0; color: #666; border-top: 1px solid #eee; vertical-align: top;">문의내용</td><td style="padding: 10px 0; border-top: 1px solid #eee; white-space: pre-wrap;">%s</td></tr>
      </table>
      <div style="margin-top: 24px; padding-top: 16px; border-top: 1px solid #eee; font-size: 12px; color: #999;">
        접수시간: %s<br>
        접수ID: %s
      </div>
    </div>
    $html$,
    v_label, new.name,
    v_label,
    new.name,
    coalesce(new.company, '-'),
    new.phone, new.phone,
    coalesce(new.email, '-'),
    coalesce(new.message, '-'),
    new.created_at,
    new.id
  );

  -- Resend API 요청 Body 조립
  v_body := jsonb_build_object(
    'from', v_notify_from,
    'to', jsonb_build_array(v_notify_to),
    'subject', v_subject,
    'html', v_html
  );

  if new.email is not null and new.email <> '' then
    v_body := v_body || jsonb_build_object('reply_to', new.email);
  end if;

  -- 비동기 HTTP POST (pg_net)
  select net.http_post(
    url := 'https://api.resend.com/emails',
    headers := jsonb_build_object(
      'Authorization', 'Bearer ' || v_api_key,
      'Content-Type', 'application/json'
    ),
    body := v_body
  ) into v_request_id;

  raise log 'notify_new_contact: sent request_id=%, contact_id=%', v_request_id, new.id;
  return new;
exception
  when others then
    raise log 'notify_new_contact error: %', sqlerrm;
    return new;
end;
$$;

-- ============================================
-- 트리거 연결
-- ============================================
drop trigger if exists notify_new_contact_trigger on public.contacts;

create trigger notify_new_contact_trigger
  after insert on public.contacts
  for each row
  execute function public.notify_new_contact();

-- ============================================
-- 알림 전송 후 notified_at 컬럼 업데이트 (선택)
-- pg_net 응답을 확인해서 성공 시에만 기록하려면 아래 함수 사용
-- ============================================
create or replace function public.mark_notified_when_done()
returns void
language plpgsql
security definer
as $$
begin
  update public.contacts c
     set notified_at = now()
    from net._http_response r
   where r.status_code between 200 and 299
     and c.notified_at is null
     and (r.content::jsonb ->> 'id') is not null
     and c.created_at > now() - interval '1 hour';
end;
$$;

-- 이 함수는 수동으로 호출하거나 Supabase → Database → Cron 에서 주기 실행 가능.
-- 필수는 아니며, 단순 알림만 필요하면 이 부분은 생략해도 됩니다.
