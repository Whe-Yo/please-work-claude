#!/usr/bin/env bash
# mark-work.sh — §6 antithesis 자동화 보조 (PreToolUse matcher: "Edit|Write").
# 파일 편집 발생을 세션별 마커로 기록한다. Stop 훅(stop-antithesis.sh)이 이 마커로
# "주요 작업 후 antithesis 미실행"을 판정한다. 차단하지 않는다(항상 exit 0).
set -u
input="$(cat)"
sid="$(printf '%s' "$input" | jq -r '.session_id // "nosession"' 2>/dev/null)"
dir="${HOME}/.claude/.harness_state"
mkdir -p "$dir" 2>/dev/null
find "$dir" -type f -mtime +7 -delete 2>/dev/null  # 오래된 세션 마커/카운터 정리(260629_2349)
touch "$dir/${sid}.work" 2>/dev/null   # 마지막 편집 시각
ef="$dir/${sid}.edits"; ec=$(cat "$ef" 2>/dev/null || echo 0); case "$ec" in *[!0-9]*) ec=0 ;; esac; echo $((ec+1)) > "$ef" 2>/dev/null  # 편집 카운터(프로세스 상태)
exit 0
