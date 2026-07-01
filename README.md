# Please-Work Claude

**Claude(Claude Code·Claude Desktop)를 위한 하네스** 모음입니다. 규칙(Rules), 스킬(Skills), 외부 도구 명세(MCP)를 Claude에 주입해 사고·검증·보고 절차를 일관되게 만듭니다.

> 처음엔 "어떤 에이전트에든 쓰는 범용 하네스"를 지향했으나, 그건 시기상조였습니다. 강제 층은 런타임 종속이고 모델마다 미끄러지는 양상이 달라, 한 모델에 맞춰 깊게 가는 편이 낫습니다. **이 저장소는 Claude에 집중합니다.** (제미나이용은 [please-work-gemini](https://github.com/Whe-Yo/please-work-gemini), Claude×Gemini 오케스트레이션은 [please-work-clemini](https://github.com/Whe-Yo/please-work-clemini).)

> [!CAUTION]
> **이 저장소는 도구함(Toolbox)입니다. 도구함 안에서 작업하지 않습니다.**
> Claude는 이 저장소에서 재료를 읽고 복사해 자신의 환경(`~/.claude/`)에 주입합니다.
> 프로젝트 작업의 일환으로 이 저장소 내 파일을 수정·기록·설정하는 행위는 금지입니다.
>
> **단 하나의 예외: [`log_for_test/`](log_for_test/).** 실증·피드백 로그 전용으로, `feedback` 절차로만 md를 추가·커밋합니다. 그 외 경로(rules/, skills/, mcp/)는 성역입니다.

---

## 이 프로젝트의 의의

### 1. 적응형 하네싱 (Adaptive Harnessing)
Claude는 고정 도구 묶음이 아니라, 프로젝트에 맞게 스스로 스킬을 골라 장착합니다.
- **자가 선택**: `setup` 스킬이 `SKILL_INDEX.md`를 읽고 필요한 스킬만 `~/.claude/commands/`에 장착.
- **주기적 갱신**: `manage` 스킬로 업데이트·제거.

### 2. RPW — 현재 상태 스냅샷 (Rule, Plan, Work)
세션이 바뀌어도 맥락이 끊기지 않도록 단일 문서가 **현재 상태**를 관리합니다. 히스토리 로그가 아닌 스냅샷 — 세 섹션 모두 갱신 시 덮어씁니다(히스토리는 git이 담당).
- **Rule**: 프로젝트 공통 규칙. 3-tier(Always do / Ask first / Never do).
- **Plan**: 지금 작업 단위의 목표·체크리스트.
- **Work**: 어디까지 됐는지 2~3문장. 다음 세션 `boost`가 즉시 복원.
- **템플릿**: [`rules/rule_plan_work_template.md`](rules/rule_plan_work_template.md).

### 3. N회 안티테제 검토 (Antithesis Review)
컨텍스트 오버피팅·확증 편향 제거를 위해, **이전 대화를 모르는 독립 인스턴스**(Claude Code의 Agent 툴로 소환)가 RPW + 검토 대상만 받아 반론 검토합니다.
- 격리된 컨텍스트, 반론 관점, 수렴까지 N회(최소 1회, 발산 시 사용자 중재).
- 구현: `antithesis` 스킬 — Claude Code는 Agent 툴로 자동 소환.

---

## 하네스의 두 층 — 효력의 경계

| 층 | 구성 | 효력 |
| :--- | :--- | :--- |
| **지시 층** | CLAUDE.md, 스킬, RPW (프롬프트·마크다운) | 소프트 — "대체로 따름" |
| **강제 층** | Claude Code의 Hooks·permissions (settings.json) | 하드 — "우발·일상 위반 차단 (셸 우회까지 막진 못함 — 가드레일)" |

- **지시 층**이 가치의 대부분을 짊어집니다. Claude가 규칙을 읽고 대체로 따릅니다. 단 가끔 미끄러집니다.
- **강제 층**은 치명적 소수(.env 보안, 파괴적 git, 루프 폭주)만 Claude Code의 Hooks·권한 deny로 하드 강제합니다.
- 효력은 On/Off가 아니라 신뢰도 그라데이션. 치명적 규칙은 **양쪽에** 둡니다 — 지시 층 텍스트 + 강제 층 실제 차단.

---

## 구성 요소

- **규칙셋 ([rules/CLAUDE.md](rules/CLAUDE.md))** — 사고·검증·보고 행동 원칙. `~/.claude/CLAUDE.md`에 주입.
- **스킬 12종 ([skills/](skills/))** — 상황별 절차 지침서. 목록은 [`SKILL_INDEX.md`](skills/SKILL_INDEX.md). Claude Code는 `~/.claude/commands/`의 슬래시 커맨드로 장착.
- **MCP 템플릿 ([mcp/mcp_template.json](mcp/mcp_template.json))** — context7, sequential-thinking, exa, memory.
- **강제·가시성 층 ([.claude/](.claude/))** — `settings.json` + 훅 5종. **차단(하드):** §9(.env·파괴적 git)을 PreToolUse `exit 2`로. **가시성/넛지(소프트):** §7 boost 세션 환기(SessionStart), §6 antithesis 주요 작업(편집 3회↑) 후 미실행 시 Stop이 턴 종료를 막고 환기, 그리고 **매 턴 UserPromptSubmit이 [RPW·편집·antithesis·위임·조사] 상태 1줄 + 조건부 넛지를 노출**(PostToolUse가 카운터 갱신) — "안 보여서 안 돌던" 넛지형 규칙을 가시화. `setup`이 설치.

---

## 적용 방법

1. [`rules/CLAUDE.md`](rules/CLAUDE.md) **내용을 직접** `~/.claude/CLAUDE.md`(또는 프로젝트 `CLAUDE.md`)에 붙여넣습니다. (`@경로` import는 환경에 따라 전개 안 될 수 있어 — 실증 확인됨 — 내용 병합이 기본입니다.)
2. Claude에게 `setup` 스킬을 실행하도록 지시합니다 — 스킬 선택·장착(`~/.claude/commands/`)·MCP 등록·상태 파일 초기화까지 처리합니다.
3. 강제 층은 [`.claude/`](.claude/)에 **실물로 동봉**됩니다 — `setup`이 `.claude/hooks/`(guard-secrets·guard-git·session-start-boost)와 `settings.json`의 hooks 블록을 사용자 환경에 설치하고 `${CLAUDE_PROJECT_DIR}` 경로를 치환합니다. `.env`·자격증명 읽기와 파괴적 git을 PreToolUse 훅이 exit 2로 하드 차단합니다.

> RPW 문서는 프로젝트별로 그 루트에 생성됩니다.

---

## 개발자 디버그 로그 ([log_for_test/](log_for_test/))
안티테제 검토·스킬 실증·설계 결함 기록. 파일명 `YYMMDD_HHMM_claude.md`. 하네스 자체 개선용.
