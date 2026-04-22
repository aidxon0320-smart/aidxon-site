# 윈도우 PC 설치 가이드 — AIDXON 홈페이지 작업 환경

> 윈도우 노트북에서 `aidxon0320-smart` 계정으로 홈페이지를 수정하고 배포하기 위한 전체 설치 가이드입니다.
> 처음부터 끝까지 순서대로 따라하시면 됩니다.

---

## 1단계: 필수 프로그램 4개 설치

### ① Git (코드 올리는 도구) — 필수

1. https://git-scm.com/download/win 접속
2. **"64-bit Git for Windows Setup"** 클릭 → 자동 다운로드
3. 다운받은 파일 실행 → **설치 옵션은 전부 "Next" 기본값**으로 진행
4. 설치 완료

**설치 확인:**
- 시작 메뉴에서 **"Git Bash"** 검색해서 실행
- 아래 명령어 입력:
  ```bash
  git --version
  ```
- `git version 2.xx.x` 같은 게 나오면 성공 ✅

---

### ② GitHub CLI (GitHub 로그인 도구) — 필수

1. https://cli.github.com/ 접속
2. **"Download for Windows"** 클릭 (`.msi` 파일)
3. 다운받은 파일 실행 → **"Next" 기본값**으로 설치
4. 설치 완료

**설치 확인:**
- Git Bash 다시 열고 입력:
  ```bash
  gh --version
  ```
- `gh version 2.xx.x` 나오면 성공 ✅

---

### ③ VS Code (코드 편집기) — 강력 추천

1. https://code.visualstudio.com/ 접속
2. **"Download for Windows"** 클릭
3. 다운받은 파일 실행 → **"Next" 기본값**으로 설치
4. 설치 중 **"Add to PATH"** 체크 옵션은 꼭 체크 ✅

---

### ④ Node.js (Claude Code 실행에 필요) — Claude 쓰려면 필수

1. https://nodejs.org/ 접속
2. **"LTS"** (왼쪽 초록 버튼) 클릭해서 다운로드
3. 설치 파일 실행 → **"Next" 기본값**으로 설치
4. 설치 중 체크박스 나오면 **"Add to PATH" 체크 ✅**
5. 설치 완료 후 **컴퓨터 재시작 권장**

**설치 확인:**
- Git Bash 열고:
  ```bash
  node --version
  npm --version
  ```
- 각각 버전이 나오면 성공 ✅

---

## 2단계: GitHub 로그인 (aidxon0320-smart 계정으로)

Git Bash 열고 아래 순서대로:

### 2-1. GitHub CLI 로그인

```bash
gh auth login
```

물어보는 순서대로 답변:

| 질문 | 답 |
|---|---|
| What account? | **GitHub.com** 선택 |
| Protocol? | **HTTPS** 선택 |
| Authenticate Git with GitHub credentials? | **Y** |
| How to authenticate? | **Login with a web browser** 선택 |

→ 화면에 **8자리 코드**가 뜨고 자동으로 브라우저가 열립니다
→ 브라우저에서 **aidxon0320-smart 계정으로 로그인** 후 코드 입력
→ **Authorize** 클릭 → 완료

### 2-2. Git 사용자 정보 설정

```bash
git config --global user.name "aidxon0320-smart"
git config --global user.email "aidxon0320-smart@users.noreply.github.com"
```

> 💡 이메일은 실제 이메일 대신 GitHub 가 제공하는 noreply 이메일을 쓰면 공개 저장소에서도 이메일이 노출되지 않아요.

---

## 3단계: 프로젝트 내려받기 (clone)

### 3-1. 작업 폴더 만들기

윈도우 탐색기에서 원하는 위치(예: `C:\workspace`)에 폴더 생성.

### 3-2. Git Bash에서 해당 폴더로 이동

```bash
cd /c/workspace
```

### 3-3. 프로젝트 clone

```bash
git clone https://github.com/aidxon0320-smart/aidxon-site.git
cd aidxon-site
```

이제 `C:\workspace\aidxon-site` 폴더에 전체 코드가 다 들어왔습니다.

---

## 4단계: VS Code + Claude Code 설정

### 4-1. VS Code로 프로젝트 열기

```bash
code .
```

→ VS Code 가 자동으로 열립니다.

### 4-2. Claude Code 확장 프로그램 설치

**방법 A: VS Code 마켓플레이스에서 설치 (제일 쉬움)**

1. VS Code 왼쪽 사이드바에서 **네모 4개 아이콘**(Extensions, 확장) 클릭
   - 단축키: **Ctrl + Shift + X**
2. 검색창에 **"Claude Code"** 입력
3. **Anthropic** 이 만든 **"Claude Code"** 찾아서 **Install** 클릭
4. 설치 완료

**방법 B: 명령줄에서 설치**

Git Bash 에서:
```bash
npm install -g @anthropic-ai/claude-code
```

→ 전역 설치 완료. VS Code 에서 확장도 자동 연동됨.

### 4-3. Claude Code 로그인

1. VS Code 에서 **Ctrl + Shift + P** → 명령 팔레트 열림
2. **"Claude Code: Sign In"** 입력 후 선택
3. 브라우저가 열리면서 Anthropic 로그인 화면
4. **사장님의 Claude 계정으로 로그인** (구독 중인 계정)
5. **Authorize** 클릭 → VS Code 로 자동 복귀
6. 왼쪽 사이드바에 **Claude 아이콘**이 생기면 성공 ✅

### 4-4. Claude 창 열기

- **Ctrl + Esc** (윈도우) 또는 왼쪽 Claude 아이콘 클릭
- 오른쪽에 채팅창이 열림
- 아래 채팅창에 **"상세페이지 만들어줘"** 처럼 한국어로 대화 가능

### 4-5. 첫 실행 확인

Claude 채팅창에 이렇게 입력:
```
CLAUDE.md 읽고 요약해줘
```

→ Claude 가 프로젝트 업무 지시서를 읽고 요약해주면 성공 ✅
→ 이제 맥북과 동일하게 AI 직원으로 쓸 수 있습니다.

---

## 5단계: 파일 수정

- `www/index.html` — 홈페이지 본문
- `www/assets/` — 이미지, CSS, JS 파일들

수정하고 **Ctrl + S** 로 저장.

> 💡 Claude 에게 "이 부분을 이렇게 바꿔줘" 라고 말하면 알아서 수정해줍니다.

---

## 6단계: 온라인에 배포 (push)

Git Bash 또는 VS Code 터미널 (**Ctrl + `**) 에서:

```bash
git add .
git commit -m "수정 내용 설명"
git push
```

→ **30초~1분 뒤 [aidxon.com](https://aidxon.com) 에 자동 반영** ✅

> 💡 Claude 에게 "수정한 거 올려줘" 라고 하면 위 3줄을 알아서 실행해줍니다.

---

## 7단계: 처음 push 할 때만 — 권한 확인

만약 `git push` 할 때 **"Permission denied"** 가 뜨면:

1. aidxon0320-smart 계정이 이 저장소의 **소유자**인지 확인
2. 맞다면 자동으로 push 가능
3. 만약 협업자 계정이라면 소유자에게 **Collaborator 초대** 받아야 함

현재 저장소는 `aidxon0320-smart` 소유이므로 이 계정으로 로그인했다면 자동으로 됩니다.

---

## 체크리스트 요약

- [ ] Git 설치 → `git --version` 확인
- [ ] GitHub CLI 설치 → `gh --version` 확인
- [ ] VS Code 설치
- [ ] Node.js 설치 → `node --version` 확인
- [ ] `gh auth login` 으로 aidxon0320-smart 로그인
- [ ] `git config --global` 로 사용자 이름/이메일 설정
- [ ] `git clone` 으로 프로젝트 내려받기
- [ ] VS Code 에 **Claude Code 확장** 설치
- [ ] Claude Code 로그인 → 채팅창 정상 작동 확인
- [ ] 수정 후 `git add . / commit / push` 3줄로 배포

---

## 추천 VS Code 확장 (선택사항)

Claude 말고도 아래 확장을 추가하면 편합니다 (Extensions 에서 검색):

| 확장 이름 | 용도 |
|---|---|
| **Korean Language Pack for Visual Studio Code** | VS Code 메뉴 한글화 |
| **Live Server** | HTML 파일 미리보기 (우클릭 → Open with Live Server) |
| **Prettier** | 코드 자동 정렬 |
| **GitLens** | Git 이력 시각화 |

---

## 자주 하는 실수

❌ **Dropbox 같은 동기화 폴더 안에 clone 하기** → 충돌 가능 → `C:\workspace` 같은 일반 폴더 권장

❌ **맥에서 작업 중인데 윈도우에서도 동시에 수정** → 충돌 발생 → 한 쪽에서 `git push` → 다른 쪽에서 `git pull` 받은 후 작업

❌ **GitHub 계정 두 개 섞여 로그인** → `gh auth status` 로 현재 로그인 계정 확인 가능

❌ **Claude Code 구독 없이 로그인 시도** → claude.ai 유료 플랜(Pro/Max) 또는 Anthropic API 크레딧 필요

---

## 윈도우에서 작업 시작할 때 매번 할 일

다른 컴퓨터(맥)에서 수정했을 수 있으니, **작업 시작 전에 항상:**

```bash
cd /c/workspace/aidxon-site
git pull
```

→ 최신 버전으로 동기화한 후 작업 시작하세요.

---

## 문제 해결

### `gh auth login` 에서 브라우저가 안 열려요
→ 화면에 표시되는 URL 을 직접 복사해서 브라우저 주소창에 붙여넣으세요.

### `git push` 할 때 비밀번호를 물어봐요
→ `gh auth login` 을 다시 실행해서 GitHub CLI 로 재인증하세요.
→ GitHub 은 2021년부터 비밀번호 인증이 막혔습니다. 토큰 기반 인증만 가능.

### Claude Code 아이콘이 안 보여요
→ VS Code 를 완전히 종료 후 재실행하세요.
→ Extensions 탭에서 Claude Code 가 **Enabled** 상태인지 확인.

### `npm install -g` 가 권한 에러로 실패해요
→ Git Bash 를 **관리자 권한으로 실행** 후 다시 시도하세요.

---

막히는 부분 있으면 "○○단계에서 이런 에러 나와요" 하고 물어봐주세요!
