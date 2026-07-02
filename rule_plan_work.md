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

전역 설치 후 "일상 작업 안전성" 독립 검토(260626) → guard-git가 일상 루틴(`branch -D`·`checkout/restore .`·`clean -f`·`rebase -i`·`--force-with-lease`)을 과차단, guard-secrets가 `.key`·`.envrc`·`.env.d.ts`를 오차단함을 확인 → **완화**(가드레일을 '치명·비가역'에만 한정: force-push·reset --hard·filter-branch·update-ref -d·reflog expire·.env·자격증명만 차단). SessionStart도 RPW 게이트 추가(무관 프로젝트 미주입). 재검증 33/33, 맥미니 `~/.claude` 재설치 완료.

260629 외부 피드백(jq 미설치 시 guard fail-open 무음 통과 — 다른 환경서 실증) 반영: guard-secrets/guard-git에 jq 부재 시 **fail-closed(exit 2)** 추가(무음 통과 제거), setup 6-2에 **jq 사전점검 + 검증 필수게이트**(통과 못 하면 설치완료 보고 금지) 추가. 정상회귀 + jq-missing 시뮬 검증.

추가 실전 피드백(260629_2349 Windows·260701 Linux) 반영: ① fail-closed의 전-도구 마비를 **jq 절대경로 폴백** 탐색으로 해소(PATH 미포함이어도 찾음) ② guard-git **커밋메시지 거짓양성**을 인용 구간 제거로 차단(`commit -m "...push --force..."` 통과) ③ guard-secrets **`.pub`·`~/.ssh/` 과차단 해소**(개인키만 차단, config/known_hosts/공개키 허용) ④ 마커 정리(7일 TTL)·Windows `bash.exe` 설치 절차. 15케이스 검증·재설치.

**소프트규칙 실전 미실행(260701 B/C) 반영 — 가시성 층 구현:** 원인 = 넛지형(RPW·antithesis·위임)이 에이전트 내부라 '안 보여서' 안 돌고, antithesis Stop 게이트가 RPW존재 조건이라 실전(비-하네스) 프로젝트서 아예 꺼짐. → ① `process-status.sh`(UserPromptSubmit, 매 턴) = [RPW·편집·antithesis·agy위임·조사] 상태 + 조건부 넛지(RPW생성/검토/위임)를 매 턴 노출(사용자에게도 알리도록). ② `track-tools.sh`(PostToolUse) = Task/WebSearch/agy 카운터 갱신, mark-work=편집 카운터. ③ stop-antithesis 게이트를 **RPW존재→편집 3회↑**로 수정(실전서도 발동). 흐름 시뮬 검증·재설치 완료. (④ RPW 자동 스켈레톤·위임 하드트리거는 넛지로 1차 대응, 필요 시 강화.)

**Fable 전면 재감정 + 안티테제 결함 수정(260702, v0.3.0):** 독립 안티테제가 [치명] setup 훅 복사 목록 드리프트(5종 나열 vs settings 7종 참조 — 신규 설치서 가시성층 침묵 사망)를 적발 → 글롭 복사+참조 대조+가시성층 검증 게이트로 수정. 동반 수정: mark-work PostToolUse 이동(성공 편집만 계측), agy 경유 안티테제 ack(거짓 음성), GC 30일, dead `review` 카운터 제거, 문서 부패 3건 정정. `datavault/` 첫 노트 2건으로 실증 개시. README 3종 재작성(`[ 제목 ]` 섹션·담백한 투·한국어+영어 미러 — 사용자 스타일). 훅 배터리 7/7·fanout 실패/성공 경로 실증(bash 3.2 실기 포함)·라이브 재설치 완료. 잔여 알려진 한계: 키워드 ack 거짓 양성(작업완료 마커 재프레임=백로그), 세션 경계 검토부채 소멸(RPW/boost 소관), gemini 재발검증(runaway-retest) 미실행.

**코호트 상시 가동(260702, v0.3.1/0.6.1):** 실사용서 코호트 미사용의 근본 원인 3개 해소 — ① 전역 `~/.claude/CLAUDE.md`에 코호트 절 부재(최대 원인) → 7-2절 주입 ② 넛지 조건 과엄+슬롯 밀림 → 슬롯 밖 독립·최우선 ③ 경로 마찰 → `~/.agents/harnessing_state_clemini.json`. 트리거는 2단 검증(코호트 1차 반론→좀비 적발, 독립 안티테제 2차→편집형 좀비·조사형 자기소거 적발)을 거쳐 **'마지막 하달 이후 편집+조사 증분 ≥2, 방출=하달 자체'**로 확정, 배터리 검증·라이브 반영. clemini `docs/` 개시(agy 지식 제텔카스텐 — 실측>실증>웹, 사이트맵 21페이지 발굴). 원칙 명문화: **결과 미반영이어도 하달이 기본값**.
