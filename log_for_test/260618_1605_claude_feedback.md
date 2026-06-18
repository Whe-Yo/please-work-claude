# Feedback — 260618_1605 / claude

## 유형
bug, friction

---

## [BUG-1] @import 미전개 — CLAUDE.md 규칙 미로드

### 요약
`~/.claude/CLAUDE.md`의 `@절대경로` import가 Claude Code VSCode 확장 환경에서 해석되지 않음.

### 무슨 일이
- **하려던 것**: `~/.claude/CLAUDE.md` 하단에 `@/workspace/00/please-work-claude/rules/CLAUDE.md` import 추가 → 세션 시작 시 하네스 규칙 자동 로드
- **일어난 것**: 세션 system-reminder에 `~/.claude/CLAUDE.md` 내용이 원문 그대로 출력됨. import된 파일(페르소나, 작업 루프, 검증 규칙 등) 내용이 컨텍스트에 없었음.
- **기대한 것**: `@경로` 라인이 해당 파일 내용으로 인라인 전개되어 로드됨

### 환경
- 에이전트: Claude Code (claude-sonnet-4-6)
- 환경: VSCode 확장 + `/workspace/` 마운트 환경
- CLAUDE.md 위치: `~/.claude/CLAUDE.md` (글로벌)
- import 경로 형식: 절대경로 (`@/workspace/00/...`)

### 재현
1. `~/.claude/CLAUDE.md` 하단에 `@/절대경로/CLAUDE.md` 추가
2. 새 세션 시작
3. system-reminder의 claudeMd 섹션 확인 → import 원문만 보임, 내용 미전개

### 관련 스킬·규칙
- `setup/SKILL.md` 1번 절차: "import 우선 — `@경로` import로 기존 규칙 보존 + 자동 전파"
- `rules/CLAUDE.md` 7절: "세션을 시작하면 가장 먼저 `boost`를 실행"

### 추정 원인
Claude Code가 `@절대경로` import를 처리하지 않거나, VSCode 확장 환경에서 글로벌 CLAUDE.md의 import 해석이 제한될 수 있음. 상대경로나 프로젝트 내 경로로 제한될 가능성.

### 권장 대응
- `setup` 스킬의 import 방식 수정: 절대경로 대신 내용 직접 병합(append)으로 변경
- 또는 프로젝트별 `CLAUDE.md`에 import 추가하는 방식으로 전환
- import 지원 여부 환경별 명세 필요

---

## [FRICTION-1] 소프트 규칙 미준수 — boost·antithesis 자동화 불가

### 요약
"세션 시작 시 boost", "주요 작업 후 antithesis" 규칙이 강제 수단 없어 AI가 건너뜀.

### 무슨 일이
- **하려던 것**: 세션 시작 시 `/boost` → 주요 설계 작업 후 `/antithesis` 자동 실행
- **일어난 것**: 이번 세션에서 boost 미실행, antithesis 미실행. 사용자가 직접 지적하기 전까지 발견 못 함.
- **기대한 것**: 규칙대로 세션 시작 시 boost, 설계 완료 후 antithesis 실행

### 환경
- 에이전트: Claude Code (claude-sonnet-4-6)
- BUG-1과 연관: 규칙 자체가 로드 안 됐을 가능성 있음
- 설령 로드됐어도 강제 층(hook) 없음

### 재현
1. 새 세션 시작 (boost 없이 바로 작업 시작)
2. 주요 설계 작업 수행
3. antithesis 미트리거

### 관련 스킬·규칙
- `rules/CLAUDE.md` 7절: "세션을 시작하면 가장 먼저 `boost`를 실행"
- `rules/CLAUDE.md` 6절: "주요 작업 완료 후 antithesis 실행. 최소 1회."
- `skills/boost/SKILL.md`, `skills/antithesis/SKILL.md`

### 권장 대응
- Claude Code `settings.json` Hook으로 세션 시작 시 boost 강제 실행 검토
  - `PreToolUse` 또는 세션 시작 이벤트 활용
- antithesis는 특성상 자동화 어려움 — 체크리스트 형태로 turn 종료 조건에 포함하는 방안
