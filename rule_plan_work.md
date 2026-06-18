# RPW — please-work-claude

## Rule

### Always do
- 작업 유형에 맞게 페르소나를 조정한다 (코드·구현 → 아키텍트, 조사·분석 → 분석가, 논문·편집 → 학술 편집자)
- 세션 시작 시 가장 먼저 boost로 RPW·상태를 로드한다
- 이해 > 계획 > 실행 > 검증 > 보고 순서로 작업한다
- 단순 답변이 아닌 주요 작업 완료 후 antithesis를 실행한다
- 모든 소통은 한국어로, 첫 문장은 결과로 시작한다
- 날짜는 YYMMDD_HHMM 형식으로 표기한다

### Ask first
- 스킬 파일 삭제·전면 교체 전
- 아키텍처 범위 밖 변경 시
- 파괴적 git 명령 실행 전 (force push, reset --hard 등)

### Never do
- 검증 안 된 결과를 완료로 보고
- antithesis 검토 프롬프트에 이전 대화 컨텍스트 포함
- 채팅창에 YAML·JSON 등 구조화 데이터 출력

---

## Plan

목표: 범용 하네스 → **Claude 전용 하네스**로 정체성 전환

- [x] 레포·디렉토리 리네임 (please-work-harness → please-work-claude)
- [x] README 전면 재작성 (Claude 전용, 2층 = CLAUDE.md/스킬 + Claude Code Hooks·permissions)
- [x] `rules/AGENTS.md` → `rules/CLAUDE.md`, 헤더·9절 Claude 한정
- [x] boost·setup·manage의 "범용·에이전트 비종속·AGENTS.md 표준" 프레이밍을 Claude로 좁힘
- [ ] 잔여 스킬의 "환경별 분기" 예시는 Claude Code 구체화로 점진 정리(선택)

---

## Work

"포괄적 범용 하네스는 시기상조" 판단으로 Claude 전용으로 전환. 레포 please-work-claude로 리네임, 룰 파일 CLAUDE.md로, 적용 방법을 `~/.claude/CLAUDE.md` 주입 + setup으로 단순화. 강제 층은 Claude Code Hooks·permissions로 명확화(어댑터 추상화 제거). 가족: please-work-claude(Claude) / please-work-gemini(제미나이) / please-work-clemini(오케스트레이션).
