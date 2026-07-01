#!/usr/bin/env bash
# process-status.sh — §6·§7 가시성 강제 (UserPromptSubmit, 매처 없음 = 매 턴 발동).
# 260701 피드백 C: 넛지형 규칙(RPW·antithesis·위임)이 '안 보여서' 안 돈다 → 매 턴 상태를
# 에이전트 컨텍스트에 주입해 가시화·책임화한다. 관찰/주입 전용, 항상 exit 0(보안 아님 → fail-open OK).
set -u
input="$(cat 2>/dev/null)"
sid="$(printf '%s' "$input" | (jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession))"
[ -n "$sid" ] || sid=nosession
cwd="$(printf '%s' "$input" | (jq -r '.cwd // empty' 2>/dev/null || echo ''))"
[ -n "$cwd" ] || cwd="$PWD"
dir="${HOME}/.claude/.harness_state"
rd(){ cat "$dir/${sid}.$1" 2>/dev/null || echo 0; }
edits=$(rd edits); agy=$(rd agy); review=$(rd review); research=$(rd research)
case "$edits$agy$review$research" in *[!0-9]*) edits=0; agy=0; review=0; research=0 ;; esac

if   [ -f "$cwd/rule_plan_work.md" ]; then rpw="있음";
elif [ -f "$cwd/work.md" ];          then rpw="있음(work.md)";
else rpw="없음"; fi
dv=$(find "$cwd/datavault" -maxdepth 1 -name '*.md' ! -name 'INDEX.md' 2>/dev/null | wc -l | tr -d ' '); case "$dv" in ''|*[!0-9]*) dv=0 ;; esac

rem=""
[ "$rpw" = "없음" ] && [ "$edits" -ge 2 ] && rem="${rem} RPW 미생성 → rule_plan_work.md 스켈레톤 생성 권장."
[ "$edits" -ge 3 ] && [ "$review" -eq 0 ] && rem="${rem} 주요 작업(편집 ${edits}회) 후 antithesis/독립검토 0회 → 묻지 말고 실행."
[ "$research" -ge 4 ] && [ "$agy" -eq 0 ] && rem="${rem} 조사 ${research}회 직접 수행·위임 0 → clemini delegate.sh로 Gemini 위임 고려(Claude 토큰 절약)."
[ "$edits" -ge 5 ] && rem="${rem} 주요 작업(편집 ${edits}회) — 아키텍처 결정·패턴·안티패턴이 나왔다면 Datavault 원자 노트로 남겨라(현재 ${dv}개, '나중에'는 유실)."

printf '[하네스 상태] RPW:%s · 편집:%s · antithesis/서브에이전트:%s · agy위임:%s · 조사:%s · Datavault:%s\n' "$rpw" "$edits" "$review" "$agy" "$research" "$dv"
[ -n "$rem" ] && printf '[하네스 리마인더]%s — 이 상태를 사용자에게도 한 줄로 알리고 해당 항목을 처리하라.\n' "$rem"
exit 0
