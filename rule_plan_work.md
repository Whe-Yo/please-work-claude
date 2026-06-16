# Rule, Plan & Work Log

> [!IMPORTANT]
> 본 문서는 Harnessing_Agent 프로젝트의 규칙(Rules), 진행 계획(Plans), 그리고 작업 로그(Work Log)를 중앙 관리하는 핵심 문서입니다.

---

## 📋 Rules & Persona

| 영역 | 규칙 요약 | 트리거 및 세부 조항 |
| :--- | :--- | :--- |
| **페르소나 (Persona)** | 최상위 소프트웨어 아키텍트 | - 냉철하고 직설적인 업무 톤 유지<br>- 모든 답변 및 문서는 **한국어**로 작성 |
| **작업 루프 (Agent Loop)** | 이해 ➡️ 계획 ➡️ 실행 ➡️ 검증 ➡️ 보고 | - 턴 종료 전 미진한 계획 실행 완료 필수 |
| **셀프 리뷰 (Self-Review)** | 안티테제 검토자 (2회) | - **2회 교차 검증**: 모든 코드 및 설정 수정을 끝낸 후, 프로젝트의 목적과 방향성만 인지하고 이전 대화 컨텍스트는 물리적으로 완전히 기억하지 않는 독립된 제3의 안티테제 검토자 2개(2회)를 순차 가동하여 교차 검증을 수행합니다 (오버피팅으로 인한 환각 방지). |
| **대답 형식 (Report Format)** | 대화 채널 청결성 및 결과 우선 | - 모든 설명의 첫 문장은 직설적 결과로 시작<br>- 채팅창에 가독성을 해치는 YAML, JSON 등 구조화 데이터 출력 금지 (본 문서에만 기록)<br>- 파일 언급 시 마크다운 링크 형식(`[파일명](file:///절대경로)`) 강제 |
| **의사결정 (Decision Log)** | 의사결정 추적성 확보 | - 비자명 결정 시 WHAT / WHY / REJECTED 구조 명시<br>- 날짜 기재 시 절대 날짜 표기 강제 |

### 🛠️ Decision Log (2026-06-16)
* **WHAT**: 난이도 기반 가변 검증(n회 조정) 등 과도하게 복잡한 규칙 설계를 전면 배제하고, "실시간 RPW 운용" 및 "이전 컨텍스트가 격리된 독립 안티테제 검토자 2회 검토"라는 두 가지 핵심 기능 실증(PoC)으로 아키텍처 스펙을 단순화함.
* **WHY**: 규칙과 검증 절차가 지나치게 복잡하면 토큰 낭비 및 레이턴시 증가로 실증이 어려움. 핵심 가치인 '컨텍스트 배제 후 비판적 3자 검토'와 '실시간 작업 로그 관리'의 실효성을 먼저 입증하는 데 집중하기 위함.
* **REJECTED**: 작업 난이도(상/중/하)에 따라 검증 횟수(n)를 동적으로 증가/감소시키는 규칙안 (복잡도가 과하여 실증 단계에서는 오버헤드가 크므로 기각).
* **WHAT**: 특정 에이전트 경로에 종속적인 설치 자동화 스크립트(`install.sh` 등) 및 전용 환경 설정 파일들을 영구 삭제하고, 모든 에이전트 환경에 범용 적용 가능한 프롬프트 규칙(`rules/RULES.md`), 스킬(`skills/`), MCP 명세(`mcp/mcp_template.json`)의 "재료 제공" 형태로 저장소 정체성 전환.
* **WHY**: "어디에나 적용 가능해야 하며 특정 에이전트에 종속되지 않는다"는 제1원칙 준수. 자동 설치 스크립트는 향후 신규 에이전트나 OS 환경 변경 시 호환성 충돌이 크며 오버헤드가 발생함.
* **REJECTED**: 기존 설치 스크립트에 분기 처리를 고도화하는 안 (에이전트별 전용 API나 파일 경로의 유지보수 파편화가 급증하므로 기각).

---

## 🗺️ Plans

### [x] Task 3: 에이전트 종속 파일 삭제 및 구조 간소화
- [x] Subtask 3.1: `scripts/` 디렉토리 하위의 `install.sh` 및 `install_node22.sh` 물리적 제거
- [x] Subtask 3.2: `gemini-cli/` 디렉토리 및 `gemini/GEMINI.md` 물리적 제거

### [x] Task 4: 범용 지능/도구 재료(Raw Materials) 자산화 및 문서화
- [x] Subtask 4.1: `rules/RULES.md` 신설 - 특정 에이전트 툴 명세를 제거한 순수 범용 인지 및 프롬프트 행동 규칙 정의
- [x] Subtask 4.2: `mcp/mcp_config.json`을 범용 템플릿인 `mcp/mcp_template.json`으로 구조 개편
- [x] Subtask 4.3: `README.md` 가이드 전면 개편 - 특정 에이전트 전용 설명 및 실행 구문을 제거하고 각 사용자의 에이전트 런타임에 이 재료들을 주입하는 가이드로 개편
- [x] Subtask 4.4: $n=3$ 교차 검증을 통해 새로운 범용화 자산들과 규칙서 간의 정합성 검증

### [x] Task 5: 깃허브 배포 및 동기화
- [x] Subtask 5.1: 변경사항을 단일 초기 커밋에 병합(amend)하여 원격 `Harnessing_Agent`에 force push 완료

### [x] Task 6: PoC 실증을 위한 스펙 단순화
- [x] Subtask 6.1: 복잡한 가변 검증 및 사전 분석 프레임워크 계획 기각 반영
- [x] Subtask 6.2: 안티테제 검토자 규칙을 '2회 교차 검증'으로 단순화하여 `rules/RULES.md` 및 로컬 rpw 업데이트 완료
- [x] Subtask 6.3: 디폴트 템플릿 파일인 `rules/rule_plan_work_template.md` 생성 완료

---

## 📜 Work Log (2026-06-16)

* **환경 설정**:
  * `trustedFolders.json` 파일에 `/Volumes/Wheyo/0_RESEARCH` 디렉토리를 `TRUST_PARENT`로 추가하여 `untrusted folder` 경고 및 MCP 서버/스킬 비활성화 문제 해결.
* **규칙 및 하네스 기능 보강**:
  * `GEMINI.md`에 다중 검토자 페르소나($n$회 검토) 규칙 추가 및 글로벌/로컬 설정에 완전 반영.
  * `install.sh` 스크립트를 개량하여 Claude Code 설정(`~/.claude.json`) 병합 기능 탑재 및 `README.md` 가이드라인 수정.
  * $n=3$ 교차 검증을 통해 스크립트 완료 문구와 `README.md` 상의 불일치를 탐지하고 즉각 동기화 완료.
* **Git 및 원격 저장소 관리**:
  * 커밋 메시지 내 Anthropic Claude 공동 저자 기입 항목 제거 및 커밋 날짜를 현재로 최신화하여 단일 초기 커밋으로 정리 완료.
  * 깃허브 원격 저장소 이전 경고(`Harnessing_Antigravity` -> `Harnessing_Agent`)를 확인하고 로컬 origin URL을 `https://github.com/Whe-Yo/Harnessing_Agent.git`로 업데이트 완료.
  * 보안 점검을 통해 소스 코드 및 깃 히스토리 상에 민감 토큰/패스워드 하드코딩 없음(Clean)을 전수 확인 완료.
  * 향후 보안 유출 방지 및 OS 메타데이터 배제를 위해 `.gitignore`를 추가하고 기추적된 `.DS_Store` 제거 후 원격 force push 최종 동기화 완료.
  * 로컬 저장소 디렉토리명을 `Harnessing_Antigravity`에서 `Harnessing_Agent`로 변경 완료하고 물리적 `.DS_Store` 파일 정리 완료.
  * **에이전트 비종속 범용화 제1원칙** 구현을 위해 특정 에이전트 경로에 강제 설치되던 스크립트(`scripts/`) 및 전용 환경 설정(`gemini-cli/`) 등을 영구 삭제 처리 완료.
  * 범용 룰셋인 `rules/RULES.md`를 신설하고 MCP 서버 연동 명세를 범용화한 `mcp/mcp_template.json`으로 개편 완료.
  * `README.md` 가이드를 설치형에서 "각 사용자별 런타임 수동 주입/연동형 가이드"로 전면 개편하고, 깃허브 원격 저장소에 단일 초기 커밋으로 최종 force push 완료.
  * 사용자 가독성 향상을 위해 대화방 내 YAML 출력 규칙을 제거(대화 채널 청결성 유지)하고, 규칙서(`rules/RULES.md` 및 로컬 `~/.gemini/GEMINI.md`)에 반영 완료.
  * **실증(PoC) 중심 스펙 단순화**:
    * 복잡한 동적 격상/감소/난이도 사전 분석 계획을 철회하고, 핵심 실증 영역인 `rpw 운용`과 `독립 안티테제 2회 검토`로 규칙 단순화 및 [rules/RULES.md](file:///Volumes/Wheyo/0_RESEARCH/Harnessing_Agent/rules/RULES.md) 수정 완료.
    * 공용 디폴트 템플릿인 [rules/rule_plan_work_template.md](file:///Volumes/Wheyo/0_RESEARCH/Harnessing_Agent/rules/rule_plan_work_template.md)를 2회 검증 사양에 맞추어 신설 완료.
