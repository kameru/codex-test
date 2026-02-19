# AI 기반 Commit → PR → Review → Merge 완전 자동화 가이드

이 문서는 **AI 에이전트가 코드 변경부터 머지까지 자동으로 수행**하도록 파이프라인을 설계하는 방법을 설명합니다.

## 1) 목표 아키텍처

아래 4개 역할을 분리하면 안정성이 높아집니다.

1. **Change Agent**: 이슈를 읽고 코드를 수정, 테스트 실행, 커밋 생성
2. **PR Agent**: PR 본문/체크리스트 생성, 라벨/리뷰어/프로젝트 자동 지정
3. **Review Agent**: 정적 분석 + 테스트 결과 + 정책 위반을 리뷰 코멘트로 남김
4. **Merge Agent**: 머지 조건(필수 체크 통과, 승인 수, 위험도)을 만족하면 자동 머지

권장 구성:

- 개발자는 이슈/요구사항만 입력
- 에이전트는 **임시 브랜치**에서 작업
- CI가 검증
- 정책 엔진이 머지 가능 여부 최종 판정

---

## 2) 최소 구현(MVP) 플로우

### Step A. 트리거

- GitHub Issue 라벨(`ai:implement`) 또는 `/ai-run` 코멘트로 시작

### Step B. 코드 생성 + 커밋

- 에이전트가 저장소 checkout
- 변경 범위 파악 후 코드 수정
- 테스트 실행
- Conventional Commit 메시지로 커밋

예시:

```bash
git checkout -b ai/task-123
# ... code change + test ...
git add .
git commit -m "feat(api): add idempotency key validation"
git push origin ai/task-123
```

### Step C. PR 생성

- 템플릿 기반 PR 본문 자동 작성
- 포함 권장 항목:
  - 변경 요약
  - 테스트 결과
  - 리스크/롤백 계획
  - 보안/개인정보 영향

### Step D. 자동 리뷰

- CodeQL/SAST, lint, unit/integration test
- AI 리뷰어가 diff 기반 코멘트 작성
- 정책 위반(예: 민감정보 하드코딩, 라이선스 위반) 시 `changes_requested`

### Step E. 자동 머지

- 조건 예시:
  - 필수 CI 통과
  - AI 리뷰 + 인간 리뷰 최소 1 승인
  - 배포 위험도 score <= threshold
- 만족 시 squash merge

---

## 3) GitHub Actions 예시 설계

### Workflow 1: `ai-implement.yml`

역할: 이슈/코멘트 트리거 시 에이전트 실행, 브랜치 생성, 커밋/푸시, PR 생성

핵심 포인트:

- `permissions`: `contents: write`, `pull-requests: write`, `issues: read`
- 에이전트 API 키는 `secrets`로 주입
- 브랜치 보호를 위해 기본 브랜치 직접 push 금지

### Workflow 2: `pr-quality-gate.yml`

역할: PR마다 품질 게이트 실행

체크 예시:

- build/lint/test
- dependency audit
- secret scanning
- 코드 오너 규칙

### Workflow 3: `auto-merge.yml`

역할: 조건 만족 PR 자동 머지

체크 예시:

- required checks all green
- approved review count
- labels include `automerge`

---

## 4) 정책(Policy as Code) 필수

완전 자동화에서 핵심은 "AI 성능"보다 **정책 강제력**입니다.

- 브랜치 보호 규칙 활성화
- CODEOWNERS 설정
- OPA/Conftest 또는 커스텀 정책 스크립트로 머지 조건 명시
- 고위험 영역(결제, 인증, 개인정보)은 인간 승인 필수

권장 정책 예시:

- `risk:high` 라벨이면 자동 머지 금지
- 마이그레이션 파일 포함 시 DBA 승인 필수
- 보안 관련 파일 변경 시 AppSec 승인 필수

---

## 5) 운영 체크리스트

1. **감사 로그**: 누가(어떤 에이전트가) 어떤 근거로 변경했는지 저장
2. **재현성**: 에이전트 입력 프롬프트/도구 버전 고정
3. **비용 관리**: 토큰/실행시간 상한
4. **실패 전략**: 실패 시 자동 재시도 + 인간 에스컬레이션
5. **점진 도입**: 읽기 전용 리뷰 자동화 → 낮은 위험 코드부터 자동 머지

---

## 6) 추천 도입 순서(현실적)

1. PR 본문 자동 생성
2. AI 리뷰어 도입(머지 권한 없음)
3. 낮은 위험 라벨(`docs`, `test`)에 한해 자동 머지
4. 정책 고도화 후 서비스 코드로 확대

---

## 7) 빠른 시작 템플릿

```yaml
name: AI Implement
on:
  issue_comment:
    types: [created]
permissions:
  contents: write
  pull-requests: write
  issues: read
jobs:
  run-agent:
    if: contains(github.event.comment.body, '/ai-run')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: |
          echo "replace with project test commands"
      - name: Commit
        run: |
          git config user.name "ai-bot"
          git config user.email "ai-bot@users.noreply.github.com"
          git checkout -b ai/${{ github.event.issue.number }}
          git add .
          git commit -m "chore: ai automated update" || echo "No changes"
      - name: Create PR
        run: |
          echo "Use gh pr create or API"
```

> 위 템플릿은 개념 예시입니다. 실제 운영에서는 테스트/정책/보안 스텝을 프로젝트 맞춤으로 구체화해야 합니다.

## 8) 결론

"완전 자동화"는 한 번에 달성하기보다, **자동 생성 → 자동 검증 → 제한적 자동 머지** 순서로 확장해야 안전합니다.

핵심 성공 조건은 아래 3가지입니다.

- 자동화 범위를 위험도 기반으로 단계적 확대
- 정책 코드로 머지 기준을 강제
- 인간 승인 게이트를 고위험 영역에 유지
