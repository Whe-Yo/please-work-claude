# Feedback — 260629_1600 / claude

## 유형
bug

## 요약
강제 층 훅(guard-secrets/guard-git)이 `jq` 미설치 환경에서 fail-open으로 조용히 통과 — 보안 가드가 무력화돼도 검증 없이는 알 수 없다.

## 무슨 일이
- 하려던 것: setup 6-2 절차대로 `.claude/hooks/` 강제 층을 사용자 `~/.claude/`에 설치.
- 일어난 것: 훅은 정상 복사·settings.json 병합됐으나, 의존 도구 `jq`가 미설치였다. guard-secrets.sh는 `tool="$(... jq -r '.tool_name')"`가 빈 문자열이 되어 `case` 기본분기 `*) exit 0`으로 빠지고, guard-git도 동일하게 통과. 즉 `.env` Read·`cat .env`·force-push가 **차단 없이 exit 0**(통과).
- 기대한 것: 의존성 미충족이면 설치가 실패하거나 최소한 fail-closed(차단)로 동작하거나, 설치 절차가 jq 존재를 사전 점검.

## 위험
- 설치자가 "강제 층 있음"이라 믿지만 실제로는 가드가 0개 작동 → §9 치명 항목(.env 읽기·파괴적 git)이 무방비. 이번엔 설치 직후 차단 검증(`echo '{...".env"}' | hook; echo $?`)을 돌려서 `exit 0`(통과)을 보고 잡아냈으나, 검증을 건너뛴 세션이면 무력화 상태를 모른 채 안전하다 오인.

## 제안
1. setup 6-2에 **jq 사전 점검·설치를 명시 단계로** 추가(`command -v jq || apt-get install -y jq` 등), 설치 불가 시 강제 층 설치 중단·경고.
2. setup 6-2의 검증을 **선택이 아닌 필수 게이트**로: 설치 직후 `echo '{"tool_name":"Read","tool_input":{"file_path":"/x/.env"}}' | guard-secrets.sh; [ $? -eq 2 ]` 가 참이어야 "설치 완료" 보고 허용.
3. (선택) 훅 자체를 fail-closed로: jq 없거나 파싱 실패 시 `exit 2`(차단)로 바꿔 무음 통과 제거. 단 과차단/오작동 시 작업 전체가 막히는 트레이드오프 — 1·2번(사전 점검+검증 게이트)이 더 안전한 1차 대응.

## 환경
- 에이전트: claude (Claude Code, Opus 4.8)
- OS: Linux 6.17
- 도구: agy, jq(설치 전 미존재 → apt로 설치), Claude Code hooks
- 설치 경로: `~/.claude/hooks/`, `~/.claude/settings.json` hooks 병합

## 재현
1. jq 미설치 환경에서 `.claude/hooks/`를 설치하고 settings.json hooks 병합.
2. `echo '{"tool_name":"Read","tool_input":{"file_path":"/x/.env"}}' | ~/.claude/hooks/guard-secrets.sh; echo $?`
3. 기대 `2`(차단)이나 실제 `0`(통과) — 가드 무력화.
4. `apt-get install -y jq` 후 재실행하면 `2`로 정상.

## 관련 스킬·규칙
- skills/setup/SKILL.md 6-2 (강제 층 설치)
- .claude/hooks/guard-secrets.sh, guard-git.sh (의존: jq)
- rules/CLAUDE.md §9 (절대 금지 — 강제 층 대상)
