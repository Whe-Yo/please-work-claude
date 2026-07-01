#!/usr/bin/env bash
# track-tools.sh — 프로세스 상태 카운터 갱신 (PostToolUse, matcher "Bash|Task|WebSearch|WebFetch").
# process-status.sh(UserPromptSubmit)가 읽어 매 턴 노출한다. 관찰 전용, 항상 exit 0.
set -u
input="$(cat 2>/dev/null)"
sid="$(printf '%s' "$input" | (jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession))"
[ -n "$sid" ] || sid=nosession
tool="$(printf '%s' "$input" | (jq -r '.tool_name // empty' 2>/dev/null || echo ''))"
dir="${HOME}/.claude/.harness_state"; mkdir -p "$dir" 2>/dev/null
inc(){ f="$dir/${sid}.$1"; c=$(cat "$f" 2>/dev/null || echo 0); case "$c" in *[!0-9]*) c=0 ;; esac; echo $((c+1)) > "$f" 2>/dev/null; }
case "$tool" in
  Task)               inc review ;;
  WebSearch|WebFetch) inc research ;;
  Bash)
    cmd="$(printf '%s' "$input" | (jq -r '.tool_input.command // empty' 2>/dev/null || echo ''))"
    printf '%s' "$cmd" | grep -Eq '(^|[[:space:]/])(agy|delegate\.sh|delegate-fanout\.sh)([[:space:]]|$)' && inc agy
    ;;
esac
exit 0
