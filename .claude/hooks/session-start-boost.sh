#!/usr/bin/env bash
# session-start-boost.sh — §7 강제 보강: 세션 시작 시 boost 리마인드 주입.
# SessionStart는 도구 차단을 못 한다 → 컨텍스트 주입으로 "가장 먼저 boost" 규칙을 환기한다.
# RPW 있는 프로젝트에서만 주입(무관 프로젝트 오염 방지). Stop 게이트·자문층은 의도적으로 전역 발동(260701) — 이 훅만 RPW 게이트. 의존: jq.
set -u
input="$(cat 2>/dev/null)"
# 상태 GC(30일) — 세션당 1회 여기서(매 편집마다 돌던 mark-work에서 이관, 코호트 감사 260702). RPW 게이트보다 먼저.
find "${HOME}/.claude/.harness_state" -type f -mtime +30 -delete 2>/dev/null
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null)"
[ -n "$cwd" ] && { [ -f "$cwd/rule_plan_work.md" ] || [ -f "$cwd/work.md" ]; } || exit 0
cat <<'CTX'
[하네스 · SessionStart] 이 프로젝트엔 please-work 하네스가 장착돼 있다.
작업/코딩에 바로 진입하지 말고, 가장 먼저 `boost`로 RPW(rule_plan_work.md)와 하네스 상태를 로드하라(§7). 이미 로드했다면 무시.
CTX
exit 0
