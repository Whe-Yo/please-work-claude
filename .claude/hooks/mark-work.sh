#!/usr/bin/env bash
# mark-work.sh — §6 antithesis 자동화 보조 (PreToolUse matcher: "Edit|Write").
# 파일 편집 발생을 세션별 마커로 기록한다. Stop 훅(stop-antithesis.sh)이 이 마커로
# "주요 작업 후 antithesis 미실행"을 판정한다. 차단하지 않는다(항상 exit 0).
set -u
input="$(cat)"
sid="$(printf '%s' "$input" | jq -r '.session_id // "nosession"' 2>/dev/null)"
dir="${HOME}/.claude/.harness_state"
mkdir -p "$dir" 2>/dev/null
find "$dir" -type f \( -name '*.work' -o -name '*.nudged' \) -mtime +7 -delete 2>/dev/null  # 오래된 마커 정리(260629_2349)
touch "$dir/${sid}.work" 2>/dev/null   # 마지막 편집 시각 기록
exit 0
