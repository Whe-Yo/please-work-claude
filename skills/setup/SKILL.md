---
name: setup
description: 최초 1회 실행. 스킬 인덱스를 읽고 현재 에이전트 환경에 맞는 스킬을 자가 선택해 장착. "스킬 세팅해줘", 새 에이전트에 하네싱 처음 적용 시 사용.
---

# Setup — 최초 스킬 장착

이 저장소를 처음 적용하는 에이전트가 1회 실행한다. 환경에 맞는 스킬을 스스로 선택하고 장착한다.

## 절차

1. **룰 파일 주입 (최우선)**: `rules/CLAUDE.md`를 Claude의 **글로벌 룰 파일 `~/.claude/CLAUDE.md`**에 주입한다 (프로젝트 한정이면 프로젝트 `CLAUDE.md`).
   - **기본은 내용 직접 병합(append)**: `rules/CLAUDE.md` 내용을 `~/.claude/CLAUDE.md`에 붙여넣는다(덮어쓰기 금지). **`@경로` import는 신뢰하지 마라** — 실증 결과 VSCode 확장·마운트 환경·절대경로에서 전개 안 돼 규칙이 통째로 미로드된 사례 있음(260618). import는 그 환경에서 실제 전개됨을 확인한 경우에만.
   - **검증은 결정론적으로**: 주입 후 새 세션의 system-reminder(claudeMd)에 규칙 본문이 **실제로 보이는지** 확인. import 한 줄만 보이고 본문이 없으면 미전개 — 병합으로 전환.
   - **멱등**: 이미 주입돼 있으면 다시 넣지 않는다.

2. **스킬 인덱스 읽기**: `skills/SKILL_INDEX.md`를 읽고 전체 스킬 목록과 설명을 파악한다.

3. **환경 파악**: 현재 에이전트가 어떤 환경인지 확인한다.
   - 서브에이전트 소환 툴 보유 여부 (antithesis, peer 스킬 자동화 가능 여부)
   - 쉘 명령 실행 가능 여부 (verify, worklog 스킬 활용 범위)
   - 프로젝트 성격 (논문 작업이면 paper, 코드 프로젝트면 review·verify 등)
   - 강제 수단(Hook·권한) 지원 여부 — 지원하면 강제 층 어댑터(치명적 소수만)를 `manage`로 제안.

4. **스킬 선택**: 환경과 프로젝트에 맞는 스킬을 고르고 사용자에게 선택 이유와 함께 보고한다.

   ```
   ## 선택한 스킬
   - [스킬명]: (선택 이유 한 줄)
   - ...

   ## 제외한 스킬
   - [스킬명]: (제외 이유 한 줄)
   ```

5. **사용자 설정 확인**: 아래 항목을 사용자에게 질문하고 답변을 RPW 문서에 기록한다.
   - **안티테제 검토 횟수(n)**: 에이전트 자율 결정을 원하는지, 아니면 최대값 또는 고정값을 설정할지.
     (기본값: 에이전트 자율 — 변경 규모에 따라 1~3회 판단)

6. **장착**: 에이전트의 스킬 로드 방식에 따라 선택한 스킬 폴더를 지정 위치에 복사하거나, 에이전트 설정에 등록한다.
   - 에이전트 스킬 폴더가 명확하지 않으면 사용자에게 위치를 확인한다.

6-2. **강제 층 설치 (Hook 지원 환경 = Claude Code)**: 이 저장소의 [`.claude/`](../../.claude/) 강제 층을 사용자 환경에 설치한다(§9·§7을 하드 강제).
   - **의존성 사전 점검(필수)**: 훅은 `jq`에 의존한다. `command -v jq`가 실패하면 **먼저 jq를 설치**(`brew install jq` / `apt install -y jq`)한다. 설치 불가 시 강제 층 설치를 **중단·경고**한다. (jq 없으면 guard-secrets/guard-git은 fail-closed로 차단하지만, 검증을 건너뛰면 무력 상태를 모를 수 있다 — 260629 피드백.)
   - `.claude/hooks/`의 `guard-secrets.sh`·`guard-git.sh`·`session-start-boost.sh`·`mark-work.sh`·`stop-antithesis.sh`를 사용자 훅 위치(예: `~/.claude/hooks/`)로 복사(실행권한 유지).
   - `.claude/settings.json`의 `hooks` 블록을 사용자 `~/.claude/settings.json`(또는 프로젝트 `.claude/settings.json`)에 **병합**하고, `command`의 `${CLAUDE_PROJECT_DIR}`를 복사한 실제 경로로 치환한다(덮어쓰기 금지·멱등).
   - **Windows(Git Bash)**: PATH에 bash가 없으므로 각 hook `command`를 `"C:/Program Files/Git/usr/bin/bash.exe" "<hook.sh 절대경로>"`로 감싼다. Git 설치 위치는 `where bash`/레지스트리로 **탐지해 치환**(위치가 다르면 훅 전멸 → fail-open). `jq`도 설치·PATH 확인(훅이 jq를 못 찾으면 fail-closed로 차단). (260629_2349)
   - 효과: `.env`·자격증명 읽기와 force-push·`reset --hard`·history rewrite를 PreToolUse가 **하드 차단**(exit 2), 세션 시작 시 boost 환기, 주요 작업 후 antithesis 미실행 시 Stop이 턴 종료를 막고 환기.
   - **검증 게이트(필수 — 통과 못 하면 "설치 완료" 보고 금지)**: `echo '{"tool_name":"Read","tool_input":{"file_path":"/x/.env"}}' | ~/.claude/hooks/guard-secrets.sh; echo $?` 가 반드시 **`2`(차단)**여야 한다. `0`(통과)이면 가드 무력(jq 누락 등) → 원인 해결 후 재검증. force-push도 `printf '{"tool_name":"Bash","tool_input":{"command":"git push --force"}}' | ~/.claude/hooks/guard-git.sh; echo $?` → `2` 확인.

7. **상태 파일 초기화**: `~/.agents/harnessing_state_{에이전트}.json`을 생성한다 (예: `harnessing_state_claude.json`, `harnessing_state_gemini.json`). **에이전트별 개별 파일**이어야 한다 — 한 머신에서 여러 에이전트가 각자 클론을 가지므로, 단일 공유 파일은 서로 덮어쓴다(클로버).
   - `~/.agents/`는 프로젝트 무관 전역 위치다. 따라서 setup 세션과 다른 프로젝트 작업 세션에서도 이 파일을 절대경로로 읽어 클론 위치를 알 수 있다 (세션 분리 문제 해결).
   - `repoPath`에는 **이 에이전트가 클론한 자기 경로**를 적는다.

   ```json
   {
     "lastCheck": "YYMMDD_HHMM",
     "repoPath": "/이 에이전트의 please-work-harness 클론 절대경로",
     "skillsDir": "/스킬을 장착한 위치",
     "skipUntilNext": false
   }
   ```

8. **완료 보고**: 주입한 룰 파일 위치, 장착된 스킬 목록과 트리거 조건, 사용자 설정값을 요약해 보고한다.

## 규칙
- boost와 worklog는 모든 환경에서 기본 장착을 권장한다.
- 환경이 지원하지 않는 스킬은 장착하지 말고 이유를 명시한다.
- 장착 후 `manage` 스킬을 통해 주기적으로 업데이트할 수 있음을 안내한다.
