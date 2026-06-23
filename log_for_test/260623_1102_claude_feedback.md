# Feedback — 260623_1102 / claude

## 유형
friction + enhancement

---

## [1] friction — hooks 강제층 누락 (settings.json)

### 요약
글로벌 설치본의 `~/.claude/settings.json`에 `hooks` 키가 없어, CLAUDE.md 9절의 치명적 금지가 강제되지 않고 텍스트 지시(소프트 룰)로만 적용됨.

### 무슨 일이
- 하려던 것: 세션 시작 후 please-work-claude 글로벌 세팅 점검.
- 일어난 것: `settings.json` top keys = `['permissions', 'theme', 'effortLevel', 'model']`. `permissions.allow`(67 rules)만 있고 `hooks` 차단층 없음.
- 기대한 것: CLAUDE.md 9절 "치명적 금지(.env 읽기, force push, 성역 수정)를 Hooks·permissions로 **함께** 강제" → hooks deny 층 존재.

### 영향
- force push / `reset --hard`, `.env` 읽기, 성역 경로 수정이 결정론적으로 차단되지 않음(소프트 룰 의존).

### 환경
- 에이전트: claude / OS: linux / settings.json 8027B
- harnessing_state_claude.json `lastCheck: 260618_1610` (점검 시점 기준 5일 경과 → manage 일일 업데이트 대상이기도 함)

### 재현
1. `python -c "import json;print(list(json.load(open('~/.claude/settings.json')).keys()))"`
2. `hooks` 부재 확인.

### 관련 스킬·규칙
- CLAUDE.md 9절(절대 금지 — 강제 층), setup(hooks 주입), manage(일일 업데이트)

---

## [2] enhancement — 다중 세션 GPU 점유 조정(대기열) 도구 부재

### 요약
여러 Claude 세션이 같은 GPU를 동시에 점유해 OOM·응답 끊김이 발생. 세션 간 GPU 사용을 직렬화하는 표준 도구가 하네스에 없음.

### 무슨 일이
- 일어난 것: 한 세션이 GPU 연산 중일 때 다른 세션의 연산이 OOM으로 실패, tool 실행/응답이 부하로 끊김.
- 기대한 것: 세션 간 GPU를 직렬화하고 현황을 공유하는 락/대기열.

### 제안 (프로토타입 구현해 둠)
- `flock(LOCK_EX)` 기반 단일 점유 락 + 대기열, `holder.json`으로 현황 공유.
- 현재 위치: `/workspace/00/gpu_queue/gpu_lock.py`
  - `gpu_lock.py status` — GPU 메모리 + 현재 점유자
  - `gpu_lock.py run <name> -- <cmd>` — 락 잡고 실행(블로킹=대기열), 끝나면 자동 해제(프로세스 죽어도 OS가 flock 해제)
- 하네스 표준 도구로 승격 시 `bin/` 또는 신규 스킬로 편입 검토.

### 환경
- 에이전트: claude / OS: linux / 다중 세션 동일 GPU(47.38 GiB) 공유 환경

### 관련 스킬·규칙
- clemini 위임(다중 에이전트 동시 연산), boost(자원 상태 점검)
