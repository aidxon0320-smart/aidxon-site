# Resend 이메일 알림 설정 가이드 (트리거 방식)

문의가 들어오면 Postgres 트리거가 자동으로 Resend API 를 호출해 `aidxon0320@gmail.com` 으로 이메일을 보냅니다.
**Edge Function, Supabase CLI 설치 모두 불필요** — Supabase 웹 대시보드에서 SQL 실행만으로 완료됩니다.

---

## 1단계: Resend 계정 & API 키 발급

1. https://resend.com 접속 → **Sign up**
2. 로그인 후 왼쪽 메뉴 → **API Keys** → **Create API Key**
   - 이름: `aidxon-production`
   - Permission: **Sending access**
3. 생성된 키(`re_` 로 시작)를 복사 — **한 번만 표시됩니다**

---

## 2단계: 발송 도메인 설정

### 옵션 A: 빠른 테스트 (도메인 검증 없이)
- 발신 주소: `onboarding@resend.dev` (기본값)
- **제약**: Resend 가입 이메일로만 수신 가능 → `aidxon0320@gmail.com` 으로 받으려면 옵션 B 필요

### 옵션 B: 운영용 (aidxon.com 도메인 인증) ← **추천**
1. Resend 대시보드 → **Domains** → **Add Domain** → `aidxon.com` 입력
2. 표시되는 DNS 레코드(SPF, DKIM, DMARC)를 도메인 관리 페이지(가비아/카페24 등)에 추가
3. **Verify** 클릭 → 검증 완료되면 `noreply@aidxon.com` 같은 주소로 발송 가능
4. 검증 시간: 10분~1시간

---

## 3단계: Supabase Vault 에 API 키 저장

1. Supabase 대시보드 접속
2. 왼쪽 메뉴 → **Project Settings** → **Vault** → **New secret**
3. 아래와 같이 입력:
   - **Name**: `resend_api_key`  ← **반드시 이 이름으로**
   - **Secret**: (1단계에서 복사한 `re_...` 키 붙여넣기)
4. **Save** 클릭

> Vault 는 DB 내부 암호화 저장소입니다. 키가 평문으로 노출되지 않습니다.

---

## 4단계: 트리거 SQL 실행

1. Supabase 대시보드 → 왼쪽 메뉴 → **SQL Editor** → **New query**
2. [supabase/trigger-notification.sql](trigger-notification.sql) 파일 내용 전체를 복사해 붙여넣기
3. **Run** 클릭
4. "Success. No rows returned" 뜨면 완료

### 발신 주소를 바꾸려면
옵션 B(도메인 검증)를 적용했다면, SQL 파일 상단의 이 줄을:
```sql
v_notify_from text := 'AIDXON <onboarding@resend.dev>';
```
아래처럼 수정한 뒤 다시 Run:
```sql
v_notify_from text := 'AIDXON <noreply@aidxon.com>';
```

---

## 5단계: 테스트

1. 웹사이트(`www/index.html`)를 브라우저에서 열고 우측 상단 "문의하기" → 폼 작성 → 제출
2. `aidxon0320@gmail.com` 메일함 확인 (몇 초 내 도착)
3. Supabase **Table Editor → contacts** 에서 방금 추가된 행 확인

### 메일이 안 오면

**A. pg_net 요청 로그 확인**

SQL Editor 에서 실행:
```sql
select id, created, url, status_code, content
from net._http_response
order by created desc
limit 5;
```
- `status_code` 가 `200` 이면 Resend 로 정상 전송됨
- `401` 이면 API 키 틀림 → Vault 에서 `resend_api_key` 재확인
- `403` 이면 옵션 A 제약(가입 이메일이 아닌 주소로 발송 시도) → 옵션 B 필요

**B. Postgres 로그 확인**
Supabase 대시보드 → **Logs** → **Postgres Logs** 에서 `notify_new_contact` 관련 메시지 검색

**C. Resend 대시보드 확인**
Resend → **Logs** 에서 실제 발송 이력 확인

---

## 참고: 수신자 바꾸거나 추가하기

SQL Editor 에서:
```sql
-- 한 명만 받을 때
update public.notify_new_contact... -- 아니라 함수를 다시 Run 해야 함
```

정확히는 [supabase/trigger-notification.sql](trigger-notification.sql) 의
```sql
v_notify_to text := 'ad@aidxon.com';
```
을 수정한 뒤 SQL 전체를 다시 Run 하면 됩니다 (`create or replace` 이므로 덮어씌워짐).

여러 명으로 보내려면 함수를 약간 수정해야 합니다. 필요 시 알려주세요.
