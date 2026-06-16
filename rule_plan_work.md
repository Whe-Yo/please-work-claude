# Rule, Plan & Work Log

> [!IMPORTANT]
> 본 문서는 Harnessing_Agent 프로젝트의 규칙(Rules), 진행 계획(Plans), 그리고 작업 로그(Work Log)를 중앙 관리하는 핵심 문서입니다.

---

## Rules

### Always do
- 작업 유형에 맞게 페르소나를 조정한다 (코드·구현 → 소프트웨어 아키텍트, 조사·분석 → 분석가, 논문·편집 → 학술 편집자, 설계·기획 → 시스템 설계 전문가)
- 이해 > 계획 > 실행 > 검증 > 보고 순서로 작업한다
- 단순 답변이 아닌 모든 주요 작업 완료 후 antithesis 검토를 실행한다
- 모든 소통은 한국어로, 첫 문장은 결과로 시작한다
- 날짜는 YYMMDD_HHMM 형식으로 표기한다
- 성역 원칙: 이 저장소에서 직접 작업하지 않는다 (예외: 하네싱 개선 세션 — 사용자 명시적 승인 필요)

### Ask first
- 스킬 파일 삭제·전면 교체 전
- 아키텍처 범위 밖 변경 시
- 파괴적 git 명령 실행 전 (force push, reset --hard 등)

### Never do
- 검증 안 된 결과를 완료로 보고
- antithesis 검토 프롬프트에 이전 대화 컨텍스트 포함
- 채팅창에 YAML·JSON 등 구조화 데이터 출력

### Decision Log
* **WHAT**: 난이도 기반 가변 검증(n회 조정) 등 과도하게 복잡한 규칙 설계를 전면 배제하고, "실시간 RPW 운용" 및 "이전 컨텍스트가 격리된 독립 안티테제 검토자 2회 검토"라는 두 가지 핵심 기능 실증(PoC)으로 아키텍처 스펙을 단순화함.
* **WHY**: 규칙과 검증 절차가 지나치게 복잡하면 토큰 낭비 및 레이턴시 증가로 실증이 어려움. 핵심 가치인 '컨텍스트 배제 후 비판적 3자 검토'와 '실시간 작업 로그 관리'의 실효성을 먼저 입증하는 데 집중하기 위함.
* **REJECTED**: 작업 난이도(상/중/하)에 따라 검증 횟수(n)를 동적으로 증가/감소시키는 규칙안 (복잡도가 과하여 실증 단계에서는 오버헤드가 크므로 기각).
* **WHAT**: 특정 에이전트 경로에 종속적인 설치 자동화 스크립트 및 전용 환경 설정 파일들을 영구 삭제하고, 모든 에이전트 환경에 범용 적용 가능한 프롬프트 규칙, 스킬, MCP 명세의 "재료 제공" 형태로 저장소 정체성 전환.
* **WHY**: "어디에나 적용 가능해야 하며 특정 에이전트에 종속되지 않는다"는 제1원칙 준수.
* **REJECTED**: 기존 설치 스크립트에 분기 처리를 고도화하는 안 (에이전트별 전용 API나 파일 경로의 유지보수 파편화가 급증하므로 기각).

---

## Plans

### [x] Task 3: 에이전트 종속 파일 삭제 및 구조 간소화
- [x] Subtask 3.1: `scripts/` 디렉토리 하위의 `install.sh` 및 `install_node22.sh` 물리적 제거
- [x] Subtask 3.2: `gemini-cli/` 디렉토리 및 `gemini/GEMINI.md` 물리적 제거

### [x] Task 4: 범용 지능/도구 재료 자산화 및 문서화
- [x] Subtask 4.1: `rules/RULES.md` 신설
- [x] Subtask 4.2: `mcp/mcp_config.json`을 범용 템플릿인 `mcp/mcp_template.json`으로 구조 개편
- [x] Subtask 4.3: `README.md` 가이드 전면 개편
- [x] Subtask 4.4: 안티테제 교차 검증을 통해 새로운 범용화 자산들과 규칙서 간의 정합성 검증

### [x] Task 5: 깃허브 배포 및 동기화
- [x] Subtask 5.1: 변경사항을 단일 초기 커밋에 병합하여 원격 `Harnessing_Agent`에 force push 완료

### [x] Task 6: PoC 실증을 위한 스펙 단순화
- [x] Subtask 6.1: 복잡한 가변 검증 및 사전 분석 프레임워크 계획 기각 반영
- [x] Subtask 6.2: 안티테제 검토자 규칙을 단순화하여 `rules/RULES.md` 업데이트 완료
- [x] Subtask 6.3: 디폴트 템플릿 파일인 `rules/rule_plan_work_template.md` 생성 완료

### [x] Task 7: 적응형 하네싱 재정립
- [x] Subtask 7.1: 신규 스킬 추가 (antithesis, setup, manage, SKILL_INDEX.md)
- [x] Subtask 7.2: 에이전트 종속 참조 제거 (claude-peer -> peer, gemini_script, conda base 등)
- [x] Subtask 7.3: README 프로젝트 의의 3축 명문화 (적응형 하네싱 / RPW / n회 안티테제)
- [x] Subtask 7.4: 도구 자율 선택 원칙 적용 및 예시 병기

### [x] Task 8: 하네싱 프로젝트 추가 개선
- [x] Subtask 8.1: 페르소나 작업별 유동 조정 (코드→아키텍트, 논문→학술편집자, 데이터→분석가)
- [x] Subtask 8.2: 날짜 형식 YYMMDD_HHMM으로 통일 (RULES.md, worklog, 템플릿)
- [x] Subtask 8.3: antithesis n회 에이전트 자율 결정으로 변경, setup에서 사용자에게 n 선호 질문
- [x] Subtask 8.4: git 커밋 co-author 제거 (includeCoAuthoredBy: false)
- [x] Subtask 8.5: 일일 업데이트 확인 기능 추가 (boost step 5 + manage 업데이트 절차)

---

## Work Log (2026-06-16)

* **환경 설정**:
  * `trustedFolders.json` 파일에 `/Volumes/Wheyo/0_RESEARCH` 디렉토리를 `TRUST_PARENT`로 추가하여 `untrusted folder` 경고 및 MCP 서버/스킬 비활성화 문제 해결.
* **규칙 및 하네스 기능 보강**:
  * `GEMINI.md`에 다중 검토자 페르소나 규칙 추가 및 글로벌/로컬 설정에 완전 반영.
  * 안티테제 검토자 규칙을 단순화하고 `antithesis` 스킬로 절차 위임.
* **적응형 하네싱 재정립**:
  * 신규 스킬 3종 추가: `antithesis`, `setup`, `manage`.
  * `SKILL_INDEX.md` 신설 — 전체 스킬 메뉴판, 에이전트 자가 선택 기준 문서.
  * `claude-peer` 폴더를 `peer`로 변경, 에이전트 종속 CLI 명령 제거 및 범용화.
  * `boost`, `verify`, `worklog`, `review`, `RULES.md` 에서 에이전트 종속 참조 제거 및 도구 자율 선택 원칙 적용.
  * `mcp_template.json` 내 `~/.gemini/memory.jsonl` 경로를 `~/.agents/memory.jsonl`로 일반화.
  * `README.md` 프로젝트 의의 3축 명문화.
  * RPW 문서 전체 이모티콘 제거.
* **Git 관리**:
  * 깃허브 원격 저장소 force push 완료 (GITHUB_PAT 사용).

* **260616_1637 추가 개선**:
  * 페르소나 작업별 유동 조정, 날짜 형식 YYMMDD_HHMM 통일.
  * antithesis n회 에이전트 자율 결정, setup에서 사용자 n 선호 질문 추가.
  * git 커밋 co-author 제거 (includeCoAuthoredBy: false).
  * boost step 5 + manage 일일 업데이트 확인 절차 추가.
  * antithesis 실증 1회 실행 — 7개 문제 발견, 5개 채택. log_for_test/260616_1637_claude.md 기록.
  * antithesis 적용 범위 확장: 코드·조사·설계 모두 포함, 단순 답변만 제외.
  * RULES.md → AGENTS.md 리네임 (2026 업계 표준 대응).
  * RPW Rules 섹션 3-tier 구조로 개편 (Always do / Ask first / Never do).
  * 벤치마킹 결과: 설계 방향 확인, semantic memory / observability / AGENTS.md 3-tier 개선 포인트 발굴.
