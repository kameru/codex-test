# GitHub Actions 실행 가이드 (설정 후 실제 사용법)

이 저장소는 AI 기반 `커밋 → PR → 리뷰 → 머지` 자동화를 위한 최소 동작 흐름을 포함합니다.
아래 순서를 그대로 따라 하면, GitHub UI에서 바로 실행/검증할 수 있습니다.

## 1) 현재 포함된 파일과 역할

- `.github/workflows/ci.yml`
  - PR/푸시 시 자동화 필수 파일 존재 여부를 확인하는 기본 CI
- `.github/workflows/ai-implement.yml`
  - `/ai-implement ...` 코멘트 또는 수동 실행으로 요청 파일을 만들고 PR 자동 생성
- `.github/workflows/ai-review.yml`
  - PR에 AI 리뷰 체크리스트 코멘트를 자동 작성
- `.github/workflows/automerge.yml`
  - `automerge` 라벨 + 승인 조건을 만족할 때 auto-merge 활성화
- `.github/PULL_REQUEST_TEMPLATE.md`
  - PR 작성 형식 통일
- `CODEOWNERS`
  - 경로별 기본 리뷰 책임자 지정

## 2) 저장소 최초 설정 (한 번만)

1. **Actions 권한 허용**
   - `Settings → Actions → General`
   - Actions 실행 허용
   - `Workflow permissions`를 `Read and write permissions`로 설정

2. **Auto-merge 허용**
   - `Settings → General → Pull Requests`
   - `Allow auto-merge` 체크

3. **브랜치 보호 규칙(main)**
   - `Settings → Branches → Add rule`
   - `Require a pull request before merging`
   - `Require status checks to pass before merging`
   - 필수 체크에 `CI / Validate repository basics` 등록

4. **CODEOWNERS 실제 팀으로 교체**
   - `CODEOWNERS`의 `@octocat`를 실제 조직 팀 핸들로 바꿉니다.

## 3) 오늘 바로 써보는 실제 사용 순서

### Step 1) 기능 요청 시작

아래 둘 중 하나를 선택합니다.

- 방법 A (권장): 기존 PR 또는 이슈 코멘트에 입력
  - `/ai-implement 로그인 버튼 문구를 한국어로 변경`
- 방법 B: 수동 실행
  - `Actions → AI Implement Assistant → Run workflow`
  - `task`에 작업 지시 입력

### Step 2) 자동 생성 PR 확인

`AI Implement Assistant`가 실행되면:

- `ai-requests/request-<run_id>.md` 파일이 생성되고,
- `ai/request-<run_id>` 브랜치로 자동 PR이 생성됩니다.

이 PR은 “작업 요청 아티팩트” PR입니다. 실제 코드 변경 자동화는 여기에 AI 실행 step을 추가해 확장합니다.

### Step 3) 리뷰 보조 확인

PR이 열리면 `AI Review Assistant`가 자동으로 체크리스트 코멘트를 남깁니다.
팀은 코멘트 체크리스트를 기준으로 리뷰를 진행하면 됩니다.

### Step 4) 머지 정책 적용

자동 머지를 쓰고 싶다면 PR에 `automerge` 라벨을 붙입니다.
다음 조건이 만족되면 squash auto-merge가 활성화됩니다.

- draft PR 아님
- 최소 1개 승인
- `CHANGES_REQUESTED` 상태 없음

## 4) 운영 시 자주 하는 작업

- **팀 변경**: `CODEOWNERS`의 팀 핸들 교체
- **필수 검사 강화**: `ci.yml`에 실제 lint/test/build step 추가
- **실제 AI 코드 변경 연결**: `ai-implement.yml`에 사내 AI runner/API 호출 step 추가
- **리스크 분리**: 인증/결제/인프라 경로는 별도 승인 규칙 강화

## 5) 문제 생겼을 때 체크리스트

1. 워크플로가 아예 실행되지 않음
   - Actions 권한이 꺼져 있거나, 이벤트 조건(`on`, `if`)에 안 맞는 경우가 많습니다.
2. 코멘트로 `/ai-implement` 입력했는데 반응 없음
   - PR/이슈 코멘트 위치가 맞는지, 접두어를 정확히 입력했는지 확인하세요.
3. auto-merge가 안 켜짐
   - `automerge` 라벨 유무, 승인 수, 변경요청 상태, 저장소 `Allow auto-merge` 설정 확인
4. CODEOWNERS 리뷰어가 안 붙음
   - 팀 핸들 오타, 권한 부족, placeholder 미교체 여부 확인

## 6) 다음 단계 (권장)

- 1주차: 현재 구성으로 이벤트/권한/리뷰 흐름 검증
- 2주차: `ci.yml`에 테스트/린트 추가
- 3주차: `ai-implement.yml`에 실제 코드 수정 자동화 연결
- 4주차: 경로별 승인 정책 + 리스크 기반 auto-merge 정책 세분화
