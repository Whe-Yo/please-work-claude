#!/usr/bin/env bash
# mark-work.sh — 편집 카운터(작업량 신호). PostToolUse "Edit|Write|NotebookEdit". 차단 안 함(항상 exit 0).
# PostToolUse인 이유: PreToolUse면 거부·실패한 편집도 +1 — 성공한 편집만 센다(260702 안티테제).
# 한계(안티테제 260701 문제 B): 편집 '횟수'라 1글자 수정과 대규모 리팩터가 동일 +1 — 크기 가중은 백로그.
set -u
input="$(cat 2>/dev/null)"
sid="$(printf '%s' "$input" | (jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession))"
[ -n "$sid" ] || sid=nosession
dir="${HOME}/.claude/.harness_state"
mkdir -p "$dir" 2>/dev/null
# GC는 session-start-boost(세션당 1회)로 이관 — 매 편집마다 find 스캔은 I/O 낭비(코호트 감사 260702)
fp="$(printf '%s' "$input" | (jq -r '.tool_input.file_path // empty' 2>/dev/null || echo ''))"
printf '%s' "$fp" | grep -Eiq '\.(tex|bib)$' && : > "$dir/${sid}.paper" 2>/dev/null   # 논문 파일 편집 감지 → paper 자문
ef="$dir/${sid}.edits"; ec=$(cat "$ef" 2>/dev/null || echo 0); case "$ec" in ''|*[!0-9]*) ec=0 ;; esac
echo $((ec+1)) > "$ef" 2>/dev/null
exit 0
