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
- [x] **강제 층 실물화(260626)**: `.claude/settings.json` + hooks(guard-secrets·guard-git·session-start-boost) 동봉·검증(차단/허용 배터리 통과). setup이 설치 절차 포함.
- [x] **antithesis 자동화(260626)**: Stop 훅(mark-work + stop-antithesis)으로 주요 작업 후 antithesis 미실행 시 턴 종료를 막고 환기(작업당 1회·루프차단). 흐름 8/8 검증. 룰에 "antithesis 자동 소환=허가된 spawn(묻지 말고 실행)" 명문화.
- [ ] 성역 쓰기 차단 훅(guard-sanctuary) — 하네스 dev 세션 오탐 방지용 override 설계 후 2차
- [ ] 잔여 스킬의 "환경별 분기" 예시는 Claude Code 구체화로 점진 정리(선택)

---

## Work

"포괄적 범용 하네스는 시기상조" 판단으로 Claude 전용으로 전환. 레포 please-work-claude로 리네임, 룰 파일 CLAUDE.md로, 적용 방법을 `~/.claude/CLAUDE.md` 주입 + setup으로 단순화. 강제 층은 Claude Code Hooks·permissions로 명확화(어댑터 추상화 제거). 가족: please-work-claude(Claude) / please-work-gemini(제미나이) / please-work-clemini(오케스트레이션).

지시만이던 9절 강제 층을 `.claude/` 훅으로 **실물화(260626)** — `.env`·자격증명 읽기와 force-push·`reset --hard`·history rewrite를 PreToolUse가 exit 2로 하드 차단, SessionStart로 boost 환기. 차단/허용 배터리 검증 통과. 성역(log_for_test 외) 쓰기 차단은 dev 오탐 방지 override 설계 후 2차.

§6 antithesis도 Stop 훅으로 자동 환기(260626) — mark-work(편집 추적) + stop-antithesis(주요 작업 후 미실행 시 턴 종료 1회 차단·작업당 1회·`stop_hook_active`로 루프 방지·RPW 있는 프로젝트만). 룰에 "antithesis 자동 소환=허가된 spawn(묻지 말고 실행)" 명문화. 코호트 자동 위임은 판단 휴리스틱이라 별도 보류.

독립 antithesis 1회로 강제층 자가검증(dogfood, 260626) — "불가" 판정에서 핵심 결함 3개 잡힘: Stop "작업당 1회"가 거짓(매 턴 재차단)·guard-secrets가 cat 외 awk/sed/python 우회 가능·guard-git이 rebase -i/clean -f 등 미탐. → 세션당 1회·READ_VERB 확장·파괴적 패턴 추가로 수정·재검증(37케이스 통과). 잔여(변수간접 우회·fail-open·글로벌 병합 시 경로 고정)는 셸훅 가드레일의 본질적 한계로 인정·문서화(README "위반 불가"→"가드레일"로 정정). 완전 차단이 필요한 항목은 Claude Code permission deny로 보강 권장(백로그).
