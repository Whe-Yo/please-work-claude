# Changelog

이 프로젝트의 주요 변경을 기록한다. 형식은 [Keep a Changelog](https://keepachangelog.com/)를 따르고, 버전은 [SemVer](https://semver.org/)를 지향한다. 프로토타입 단계이므로 0.x.

업데이트 확인(`manage`의 일일 점검)은 이 파일과 git 태그를 기준점으로 삼을 수 있다.

## [Unreleased]

## [0.3.3] - 260702
### Fixed
- **`.agy` dead write 제거(260702 안티테제)**: 0.3.2에서 read를 없앤 뒤 카운터를 읽는 곳이 없어져 write-only가 된 `inc agy` 제거 — v0.3.0의 `review` dead write 제거와 같은 기준 적용. 넛지 스냅샷(agy_be/agy_br)은 유지.
- **0.3.2 paper 방출 서술 정정**: "세션 끝까지 고착 해소"는 검토 수행 세션에서만 참 — 원문 정정 및 마커 TTL 백로그 명시.

## [0.3.2] - 260702
최적화 패스 — 실측(자문 최악 380B·36ms, 세션 로드 8.4KB) 후 매 턴/매 편집 경로만 절감. 코호트 3파티션 감사 + Magos 통합(채택 7·기각 5 — 근거는 datavault [[260702_2250_optimization-pass-decisions]]).

### Changed
- **자문 문구 압축**: 매 턴 주입 380→245B(-36%), 의미 보존.
- **GC 이관**: 상태 정리(find, 30일)를 mark-work(매 편집)→session-start-boost(세션 1회)로 — 편집당 I/O 제거.
- **paper 마커 방출 경로**: antithesis ack 시 해제. (정정 260702 안티테제: 검토를 수행하는 세션에서만 방출 — 검토 없는 논문 세션에선 슬롯 규칙(pending≥3 시 verify·antithesis 점유)으로 억제될 뿐 마커는 잔존. 마커 TTL은 백로그.)
### Fixed
- process-status: dead `agy` read 제거, datavault 폴더 존재 게이트(불필요 find 제거).
### Rejected (기록)
- 훅 공용 lib(가드 연쇄 마비 위험) · jq/cat 마이크로 최적화(실측 이득 미미) · README 영문 미러 삭제(사용자 지정 스타일) — 상세는 datavault.

## [0.3.1] - 260702
코호트 상시 가동 — 실사용서 Gemini 하달을 거의 안 쓰던 문제(근본 원인: 전역 규칙·훅에 코호트 부재)의 구조적 해소.

### Added
- **코호트 하달 넛지(공격적)**: `process-status`가 조사(research≥2) 또는 편집(pending≥3) 시 **슬롯 경쟁 밖 독립·최우선**으로 "Cohort에 병렬·백그라운드 하달" 자문을 낸다. "결과가 판단에 반영 안 돼도 던지는 게 기본값"(사용자 지시). `rules/CLAUDE.md` 6-2절 + `rules/skill_activation.md` 기준 갱신. (실사용 전역 규칙 `~/.claude/CLAUDE.md`에도 코호트 절 주입 — 세션 중 코호트 존재를 잊던 최대 원인 해소.)
- **Datavault 노트**: 하네스 자기변경을 코호트 1차 반론에 건 실증(좀비 알림 적발 → 반영).

### Fixed
- **좀비 알림 3결함 제거(코호트 1차 반론 + 독립 안티테제 2차, 260702)**: ① 초안(`work` 합산 미리셋)의 넛지 영구 고착 — 코호트가 적발. ② 분리 트리거 2안의 편집형 좀비(pending이 SIG 하달로만 방출)·조사형 자기소거(research가 WebSearch만 카운트 → agy로 조사할수록 트리거 소멸) — 독립 안티테제가 적발. → 최종 설계 = **'마지막 agy 하달 이후 편집+조사 증분 ≥2'** 단일 트리거, 방출은 하달 자체(track-tools가 스냅샷 `agy_be/agy_br` 갱신). 조사를 어느 경로로 하든, SIG 유무와 무관하게, 하달하면 꺼지고 새 작업이 쌓이면 다시 뜬다. 방출·재점화·경계 배터리 검증.
- **`agy` grep 단어경계(260702 안티테제 C)**: `magyar`·`pagy.txt` 등 부분문자열 오탐이 카운터·스냅샷을 오염하던 것 → `grep -Ew`로 수정.

## [0.3.0] - 260702
강제층 실물화 → 가시성층(하이브리드 자문) → Datavault. "언급할 때만 쓰임" 문제의 구조적 해소 릴리스. (0.2.0 이후 260618~260702 누적분 — CHANGELOG 미기재 방치를 260702 안티테제가 적발, 소급 정리.)

### Added
- **강제층 실물화(260626)**: `.claude/settings.json` + 훅 — `guard-secrets`(.env·자격증명 읽기 차단, jq fail-closed+절대경로 폴백), `guard-git`(force-push·`reset --hard`·history rewrite 차단, 인용구간 제외), `session-start-boost`(세션 시작 boost 환기), `stop-antithesis`(주요 작업 후 antithesis 미실행 시 턴 종료 1회 차단). 독립 안티테제 3라운드(dogfood·일상 안전성·외부 피드백)로 우회·과차단·fail-open 교정.
- **가시성층(260701)**: `mark-work`(편집 카운터)·`track-tools`(조사·하달 카운터, antithesis ack)·`process-status`(매 턴 조건부 **하이브리드 자문** — 물리 조건 충족 시 "툴박스에 지금 쓸 것 있나?" 후보 최대 2개, clean이면 침묵). Stop 게이트를 작업 묶음(baseline/pending) 방식으로 재작성(세션 영구 무력화 버그 제거).
- **`rules/skill_activation.md`**: 기능별 발동 기준표(하드/소프트 자문/판단) — verify·paper 자문 편입, review(중복)·manage(비용>이득) 제외 확정.
- **`rules/datavault.md` + `datavault/` 개시**: RPW(현재 스냅샷)/Datavault(누적 원자노트 그래프)/git(변경사실) 3층 역할 분리. 첫 노트 2건(install-doc-drift 안티패턴, counters-posttooluse 결정)으로 실증 개시.
- **RPW 에피그래프**: "Knowledge is power, guard it well" — 템플릿에 명문화.
- **능동 피드백 규칙**: `rules/CLAUDE.md` 6절 — 하네스 실사용 중 마찰 발견 시 사용자 지시 없이 `log_for_test/`에 즉시 기록. WHY: 다른 세션이 침묵하면 같은 결함이 반복된다.

### Fixed
- **[치명] setup 훅 복사 목록 드리프트(260702 안티테제)**: setup이 훅 5종만 나열해 신규 설치에서 카운터·자문층이 침묵 사망 → **글롭 복사(`*.sh` 전부) + settings.json 참조 대조 + 가시성층 기능 검증 게이트** 추가.
- **mark-work를 PostToolUse로 이동(260702)**: PreToolUse는 거부·실패한 편집도 +1 — 성공한 편집만 계측.
- **agy 경유 안티테제 ack(260702)**: `--deep`(agy Opus) 오프로드 검토가 baseline을 리셋하지 않던 거짓 음성 수정 — clemini '이원 안티테제'와 정합.
- **문서 부패 일괄(260702)**: process-status 우선순위 주석·session-start-boost "Stop 훅과 일관" 구버전 서술·datavault.md "매 턴 노출" 과장 정정. 상태 GC 7→30일(장수 세션 baseline 오삭제 방지). 미사용 `review` 카운터(dead write) 제거.
- **SKILL_INDEX feedback 설명 정정**(피드백 260623_1819 DOC-1): "GitHub 이슈로 보고" → "`log_for_test/`에 md 기록·커밋", 트리거 "피드백 남겨"로 정렬.
- **삭제제한 마운트 대응**(피드백 260623_1819 FRICTION-1): `feedback` 스킬 6절에 잔존 `.git/index.lock` 제거 후 md 출력 폴백 절차 추가.

### Changed
- **README 전면 재작성(260702)**: 스타일 통일 — `[ 제목 ]` 섹션, 담백한 서술, 한국어 본문 + 영어 미러. 내용 최신화 — 훅 5종→7종(가시성층 편입), 하이브리드 자문, 세 겹의 기억(RPW/Datavault/git), skill_activation 참조.

### Removed
- 잘못 보관됐던 clemini 대상 피드백(260618_1605)을 clemini `log_for_test/`로 이전(중복 제거).

## [0.2.0] - 260618
### Changed
- **범용 하네스 → Claude 전용 하네스로 정체성 전환.** 레포 `please-work-harness` → `please-work-claude`. "어디에나 적용 가능"은 시기상조 — 강제 층이 런타임 종속이고 모델별 미끄러짐이 달라 Claude에 집중.
- `rules/AGENTS.md` → `rules/CLAUDE.md`. 적용은 `~/.claude/CLAUDE.md` 주입.
- 2층 구조에서 "에이전트별 어댑터" 추상화 제거 → 강제 층 = Claude Code Hooks·permissions로 직접 명시.
- README·setup·boost·manage에서 에이전트 비종속/AGENTS.md 표준 프레이밍 제거.
- (제미나이용은 please-work-gemini, Claude×Gemini 오케스트레이션은 please-work-clemini로 분리.)

## [0.1.0] - 260617
프로토타입 첫 버전. 핵심 3축(적응형 하네싱 / RPW / N회 안티테제) + 2층 구조 정립.

### Added
- **3축 정체성**: 적응형 하네싱, RPW(현재 상태 스냅샷), N회 안티테제 검토.
- **2층 구조 명문화**: 지시 층(범용·소프트) + 강제 층(런타임 종속·하드). README에 효력 그라데이션 문서화.
- 스킬 11종: `boost`, `worklog`, `plan`, `verify`, `review`, `antithesis`, `peer`, `paper`, `setup`, `manage`, `resource`.
- `resource` 스킬: 무거운 작업 착수 전 호스트 리소스 라이브 조회(저장 없음, 호스트별 분기).
- `setup`의 상태 파일 초기화(`~/.agents/harnessing_state.json`: repoPath·skillsDir).
- `manage`의 일일 업데이트 확인(boost에서 자동 트리거) + skillsDir 기반 경로 조회.
- AGENTS.md 9절 "절대 금지"(치명적·강제 층 대상), 강제 층 예시로 `.env` Read 차단(권한 deny).
- `ROADMAP.md`: 보류 기능(리소스 예약 원장) 설계 기록.

### Changed
- `RULES.md` → `AGENTS.md` 리네임 (2026 업계 표준 대응).
- RPW를 히스토리 로그에서 "현재 상태 스냅샷"(Rule/Plan/Work)으로 단순화. 3-tier(Always/Ask first/Never do) + WHY 병기.
- AGENTS.md signal density 패스: generic 규칙 압축, 각 규칙에 WHY.
- antithesis 적용 범위 확장(코드·문서·조사·설계), 최소 1회 하한.
- 날짜 형식 `YYMMDD_HHMM`로 통일.

### Removed
- 에이전트 종속 설치 스크립트·전용 설정, 에이전트별 적용 가이드(→ `setup` 위임).
- RPW의 Decision Log·Work Log·AntiPatterns 누적 구조(→ git 히스토리/커밋 메시지).
