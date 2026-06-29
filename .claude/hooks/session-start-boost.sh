#!/usr/bin/env bash
# session-start-boost.sh — §7 강제 보강: 세션 시작 시 boost 리마인드 주입.
# SessionStart는 도구 차단을 못 한다 → 컨텍스트 주입으로 "가장 먼저 boost" 규칙을 환기한다.
# plain stdout이 SessionStart에선 Claude 컨텍스트로 전달됨.
cat <<'CTX'
[하네스 · SessionStart] 이 프로젝트엔 please-work 하네스가 장착돼 있다.
작업/코딩에 바로 진입하지 말고, 가장 먼저 `boost`로 RPW(rule_plan_work.md)와 하네스 상태를 로드하라(§7). 이미 로드했다면 무시.
CTX
exit 0
