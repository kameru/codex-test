# 실제 동작 파이프라인 설정 방법

추가된 워크플로우:

- `.github/workflows/ai-implement.yml`
- `.github/workflows/pr-quality-gate.yml`
- `.github/workflows/ai-review.yml`
- `.github/workflows/auto-merge.yml`

## 1) 저장소 선행 설정

1. **Actions 권한**: Repository settings → Actions → Workflow permissions = `Read and write permissions`
2. **Branch protection**(기본 브랜치):
   - Require a pull request before merging
   - Require status checks to pass before merging
   - Required checks에 `pr-quality-gate / quality-gate` 추가
3. **Auto-merge 활성화**: Repository settings → Pull Requests → Allow auto-merge 체크
4. 라벨 생성:
   - `automerge`
   - `risk:high`

## 2) 실행 방법

1. 이슈에 아래처럼 코멘트:
   - `/ai-run 로그인 API 에러 응답 포맷 통일`
2. `ai-implement`가 새 브랜치 생성 + 변경 커밋 + PR 자동 생성
3. `pr-quality-gate`가 기본 품질 검증 수행
4. `ai-review`가 변경 파일 요약 코멘트 생성
5. 승인 1개 이상 + `automerge` 라벨 + `risk:high` 아님 + 필수 체크 통과 시 자동 머지

## 3) 현재 동작 범위

- 이 저장소는 샘플이므로 `ai-implement`는 우선 `ai-runs/issue-<n>.md` 산출물을 생성합니다.
- 실제 코드 수정 자동화를 하려면 `ai-implement.yml`의 "Create branch and implementation artifact" 단계에서
  프로젝트 빌드/테스트 + LLM 호출 + 코드 변경 로직을 연결하세요.

## 4) 운영 권장사항

- 고위험 폴더(예: `auth/`, `payment/`) 변경 시 `risk:high` 라벨을 자동 부여해 인간 승인 강제
- PR 본문 템플릿 필수 섹션 유지
- 실패 시 워크플로우 재시도보다는 원인(권한/보호규칙/리뷰조건)을 우선 확인

## 5) PR 생성 운영 규칙(권장)

- PR 제목: Conventional Commit 형식 사용 (`feat:`, `fix:`, `chore:` 등)
- PR 본문: `Summary`, `Requested instruction`, `Traceability`, `Risk & Rollback` 섹션 필수
- 자동 머지 대상 PR은 `automerge` 라벨을 붙이고, 고위험 변경이면 `risk:high`를 추가해 자동 머지 차단
