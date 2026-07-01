#!/usr/bin/env bash
# stop-antithesis.sh — §6 antithesis 자동화 (Stop 훅).
# 주요 작업(파일 편집)이 있었는데 턴을 끝내려 하면 1회 막고 antithesis를 환기한다.
# 무한루프 차단: (a) stop_hook_active=true면 통과, (b) 세션당 1회만(nudged 마커 — 한 번 환기 후 영구 통과).
# 발동: 주요 작업(편집 3회↑) 후 독립검토 0회일 때 세션당 1회(RPW 존재 무관). bash 3.2 호환. 의존: jq.
set -u
input="$(cat)"

# (a) 이미 한 번 막았으면 통과 — 루프 방지
active="$(printf '%s' "$input" | jq -r '.stop_hook_active // false' 2>/dev/null)"
[ "$active" = "true" ] && exit 0

sid="$(printf '%s' "$input" | jq -r '.session_id // "nosession"' 2>/dev/null)"
[ -n "$sid" ] || sid=nosession

dir="${HOME}/.claude/.harness_state"
nudged="$dir/${sid}.nudged"

# 발동 기준 = 주요 작업(편집 3회↑), RPW 존재 무관 (260701 B1: RPW 게이트가 실전 프로젝트서 antithesis를 꺼버렸다).
edits=$(cat "$dir/${sid}.edits" 2>/dev/null || echo 0); case "$edits" in *[!0-9]*) edits=0 ;; esac
[ "$edits" -ge 3 ] || exit 0
# 이미 서브에이전트(독립검토 등) 돌았으면 통과
review=$(cat "$dir/${sid}.review" 2>/dev/null || echo 0); case "$review" in *[!0-9]*) review=0 ;; esac
[ "$review" -ge 1 ] && exit 0
# 세션당 1회만 환기 — 이미 환기했으면 통과(매 턴 재차단·나그 방지)
[ -f "$nudged" ] && exit 0

touch "$nudged" 2>/dev/null
reason="이번 세션에 파일 편집(주요 작업)이 있었다. 끝내기 전 §6 antithesis를 처리하라 — 독립 인스턴스(Agent 툴)로 RPW+변경분 1회 반론 검토를 '묻지 말고' 실행하거나, 사소한 변경이라 생략한다면 그 사유를 한 줄로 남겨라. (세션당 1회 환기.)"
jq -n --arg r "$reason" '{decision:"block", reason:$r}' 2>/dev/null \
  || printf '{"decision":"block","reason":"주요 작업 후 antithesis를 실행하거나 생략 사유를 남겨라."}\n'
exit 0
