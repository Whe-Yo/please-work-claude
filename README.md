# Harnessing Agent: Raw Materials for Smart Agents

어떤 인공지능 에이전트(Claude Code, Antigravity IDE, Gemini CLI, Cursor, Cline 등)에서도 즉시 탑재해 지능 품질과 동작 완성도를 극대화할 수 있는 **프롬프트 규칙(Rules), 표준 자율 행동 지침(Skills), 외부 보강 도구 명세(MCP)**의 범용 템플릿(재료) 모음입니다.

> [!IMPORTANT]
> **제1원칙: 어디에나 적용 가능 (Agent-Agnostic)**
> 본 프로젝트는 특정 에이전트의 설치 환경이나 OS 경로를 강제하지 않습니다. 런타임의 주입과 세팅은 각 사용자 및 에이전트의 수동 구성을 따르며, 본 레포지토리는 세팅에 필요한 순수 **설정 재료**만을 제공합니다.

---

## 🏗️ 3대 핵심 재료 (Components)

### 🧠 1. 지능 재료: 글로벌 규칙셋 ([rules/RULES.md](rules/RULES.md))
에이전트가 생각하고 검증하는 행동 절차를 근본적으로 강제하여, 지연 최소화와 결과물의 정밀도를 높입니다.
* **작업 루프**: `이해 ➡️ 계획 ➡️ 실행 ➡️ 검증 ➡️ 보고` 순서로 일관되게 행동하게 강제.
* **다중 검토자 페르소나**: 단순 수정은 $n=2$회, 복잡 수정(파일 3개 이상/아키텍처 변경)은 $n=3$회 제3자 시점에서 교차 검토를 수행하여 컨텍스트 오버피팅과 환각을 예방.
* **정직한 검증**: 단순히 코드를 편집한 것으로 끝내지 않고 컴파일/실행 테스트 결과를 가감 없이 투명하게 보고하게 규정.

### 🛠️ 2. 행동 재료: 에이전트 스킬 7종 ([skills/](skills))
각 에이전트가 상황에 따라 로드하여 자율 수행할 수 있는 절차 지침서 모음입니다.
* **스킬 구성**: `boost` (컨텍스트 복원), `plan` (계획 수립 및 승인), `verify` (실행 검증), `review` (셀프 리뷰), `paper` (학술 글쓰기/LaTeX 검증), `claude-peer` (외부 고성능 모델 위임), `worklog` (로그 갱신).
* **적용 방식**: 에이전트가 스킬을 감지하는 로컬 디렉토리(예: `~/.agents/skills/`)로 필요한 스킬 폴더를 직접 복사하여 주입합니다.

### 🔌 3. 도구 재료: MCP 템플릿 ([mcp/mcp_template.json](mcp/mcp_template.json))
에이전트의 지식 컷오프를 해결하고 외부 API 환각을 방지하기 위한 4대 MCP(Model Context Protocol) 서버 정의 명세입니다.
* **제공 서버**: `context7` (최신 공식 문서 조회), `sequential-thinking` (다단계 사고 보완), `exa` (실시간 웹 검색), `memory` (장기 지식 그래프).
* **적용 방식**: 본 템플릿의 JSON 포맷을 참고하여 각 에이전트의 MCP 설정 파일에 직접 병합하거나 CLI 도구로 추가합니다.

---

## ⚙️ 에이전트별 재료 주입 가이드

### 1. Claude Code 환경
* **규칙 적용**: [rules/RULES.md](rules/RULES.md) 내용을 복사하여 프로젝트 루트의 `CLAUDE.md` 파일로 붙여넣거나 `~/.claude/settings.json` 내의 룰 필드에 주입합니다.
* **MCP 등록**: `~/.claude.json` 파일의 `mcpServers` 블록에 [mcp/mcp_template.json](mcp/mcp_template.json)의 명세를 복사하여 붙여넣거나 아래 CLI 명령어로 순차 등록합니다:
  ```bash
  claude mcp add context7 npx -y @upstash/context7-mcp
  claude mcp add sequential-thinking npx -y @modelcontextprotocol/server-sequential-thinking
  claude mcp add exa npx -y mcp-remote https://mcp.exa.ai/mcp
  claude mcp add memory npx -y @modelcontextprotocol/server-memory
  ```

### 2. Antigravity IDE 및 Gemini CLI 환경
* **규칙 적용**: [rules/RULES.md](rules/RULES.md) 내용을 복사하여 `~/.gemini/GEMINI.md`에 덮어씁니다.
* **스킬 적용**: `skills/` 하위의 원하는 스킬 폴더들을 `~/.agents/skills/` 디렉토리 하위로 복사합니다.
* **MCP 등록**: `~/.gemini/antigravity/mcp_config.json` 또는 `~/.gemini/settings.json` 내 `mcpServers` 항목에 [mcp/mcp_template.json](mcp/mcp_template.json) 내용을 병합합니다.

### 3. Cursor 및 Cline (VS Code) 환경
* **규칙 적용**: [rules/RULES.md](rules/RULES.md) 내용을 복사하여 프로젝트 루트의 `.cursorrules` 또는 `.clinerules` 파일로 붙여넣습니다.
* **MCP 등록**: Cursor 설정의 `Features -> MCP` 항목에 각 서버의 `command`와 `args`를 수동 기입하여 활성화합니다.
