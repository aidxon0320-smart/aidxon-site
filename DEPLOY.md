# GitHub + Vercel 배포 가이드

정적 사이트를 GitHub에 올리고 Vercel에 연결하면, 앞으로 코드를 수정할 때마다 **GitHub에 push 하는 것만으로 자동 배포**됩니다.

---

## 0단계: 사전 확인

- ✅ `www/` 폴더에 `index.html` 과 `assets/` 가 들어있는지
- ✅ `www/assets/js/supabase-config.js` 에 Supabase URL/anon key 가 채워져 있는지
- ✅ Supabase 에 `contacts` 테이블이 생성되어 있는지 ([supabase/schema.sql](supabase/schema.sql) 실행 완료)

### Supabase anon key 를 GitHub 에 올려도 되나요?
**네, 안전합니다.**
anon key 는 Supabase 가 "브라우저에 노출되는 것을 전제로" 설계한 공개 키입니다.
데이터는 `contacts` 테이블에 걸려있는 **RLS (Row Level Security)** 정책이 보호합니다 — 익명 사용자는 `insert` 만 가능하고 `select/update/delete` 는 차단됩니다.

반면 **service_role 키는 절대 업로드 금지** — 모든 권한 우회 가능.

---

## 1단계: Git 초기화 & GitHub 저장소 생성

### 1-1. 로컬 Git 초기화

터미널에서 프로젝트 폴더로 이동 후:

```bash
cd "/Users/laehoonkang/Library/CloudStorage/Dropbox/workspace/aidxon"
git init -b main
git add .
git commit -m "initial commit: AIDXON website"
```

### 1-2. GitHub 에 빈 저장소 만들기

1. https://github.com 로그인
2. 우측 상단 **+** → **New repository**
3. 아래와 같이 입력:
   - **Repository name**: `aidxon-site` (원하시는 이름)
   - **Visibility**: **Private** 추천 (Public 도 무방 — anon key 는 노출되어도 OK)
   - **Initialize this repository** 항목은 **모두 체크 해제** (README, gitignore, license 전부 X)
4. **Create repository** 클릭

### 1-3. 로컬 → GitHub 연결 & 푸시

GitHub 에서 표시되는 안내 중 **"…or push an existing repository from the command line"** 영역의 명령어를 복사해 실행합니다. 대략 이런 형태:

```bash
git remote add origin https://github.com/본인계정/aidxon-site.git
git push -u origin main
```

처음 푸시할 때 GitHub 로그인(토큰/브라우저 인증)이 뜰 수 있습니다.

---

## 2단계: Vercel 에 연결

### 2-1. Vercel 계정

1. https://vercel.com 접속 → **Sign Up** → **Continue with GitHub** 로 가입/로그인
2. GitHub 저장소 접근 권한을 요청하면 **Authorize** 클릭

### 2-2. 새 프로젝트 Import

1. Vercel 대시보드 → **Add New...** → **Project**
2. 방금 만든 `aidxon-site` 저장소 옆 **Import** 클릭
3. **Configure Project** 화면에서:
   - **Project Name**: 자동 입력된 값 유지 또는 수정
   - **Framework Preset**: **Other** (자동 감지됨)
   - **Root Directory**: ⚠️ **`www`** 로 설정 (중요!)
     - "Edit" 클릭 → `www` 선택 → **Continue**
   - **Build and Output Settings**: 모두 기본값 유지 (빌드 명령 없음)
   - **Environment Variables**: 입력 불필요
4. **Deploy** 클릭

### 2-3. 배포 완료

1~2분 뒤 🎉 화면이 뜨면 배포 완료.
Vercel 이 자동으로 URL 을 발급합니다:
```
https://aidxon-site.vercel.app
```

---

## 3단계: 커스텀 도메인 연결 (선택)

회사 도메인(`aidxon.com`)을 쓰려면:

1. Vercel 프로젝트 → **Settings** → **Domains** → **Add**
2. `aidxon.com` 또는 `www.aidxon.com` 입력 → **Add**
3. Vercel 이 요구하는 DNS 레코드를 도메인 관리 페이지(가비아/카페24 등) 에 추가:
   - **A 레코드**: `76.76.21.21`
   - **CNAME 레코드**: `cname.vercel-dns.com`
4. 자동으로 SSL 인증서(HTTPS) 발급 — 보통 5~10분

---

## 4단계: 이후 수정 사항 배포

코드 수정 후:

```bash
git add .
git commit -m "수정 내용 설명"
git push
```

Vercel 이 push 를 감지해서 **자동으로 재배포** 합니다 (약 30초~1분).

---

## 문제 해결

### 배포 후 페이지가 404 로 뜹니다
→ Vercel 프로젝트 → **Settings** → **General** → **Root Directory** 가 `www` 로 되어 있는지 확인

### 문의 폼 제출이 안 됩니다
→ 브라우저 콘솔(F12) 에서 에러 확인
→ 대부분 `supabase-config.js` 의 키가 비어있거나 잘못된 경우
→ 수정 후 push 하면 자동 재배포됨

### Resend 메일이 안 옵니다
→ 이 기능은 Supabase 쪽에서 작동 ([supabase/RESEND_SETUP.md](supabase/RESEND_SETUP.md) 참고)
→ Vercel 배포 여부와 무관

---

## 배포되지 않는 파일

[.vercelignore](.vercelignore) 에 아래 파일들을 제외하도록 설정했습니다:

- `.env` / `.env.example` — 로컬 환경변수
- `CLAUDE.md` / `*.txt` — 문서
- `supabase/` — DB 스키마, 트리거 SQL (서버측 설정)
- 로고 원본 이미지

필요한 경우 [.vercelignore](.vercelignore) 에서 조정 가능합니다.
