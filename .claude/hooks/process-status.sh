#!/usr/bin/env bash
# process-status.sh — 하이브리드 자율 판단(UserPromptSubmit, 매처 없음 = 매 턴).
# 방식: 물리 조건(싸게 감지) 충족 → "스스로에게 질문"을 주입한다 — "툴박스에 a,b,c,d가 있는데 지금 쓸 게 있나?"
#   특정 명령을 강제하지 않으므로, 편집 카운터 proxy의 오차(안티테제 260701 문제 B/G)가
#   '틀린 명령'이 아니라 '검토할 후보'로 완화된다. 어느 툴이 맞는지는 에이전트가 판단(자율).
# 판단은 매 턴, 출력은 후보 있을 때만(clean이면 침묵 → 의례화·토큰 완화, 문제 D).
#
# 물리 트리거(구체화 260701):
#   antithesis  : pending(=마지막 검토 이후 편집) ≥3   (Task 실행 시 track-tools가 baseline 리셋)
#   clemini 하달: 마지막 agy 하달 이후 쌓인 작업(편집+조사 증분) ≥2   (하달하면 스냅샷 갱신으로 방출 — 좀비 없음, 슬롯 밖 독립 노출)
#   RPW 생성    : RPW 없음 & 누적편집 ≥2
#   Datavault   : 누적편집 ≥5 & 노트 0
set -u
input="$(cat 2>/dev/null)"
sid="$(printf '%s' "$input" | (jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession))"
[ -n "$sid" ] || sid=nosession
cwd="$(printf '%s' "$input" | (jq -r '.cwd // empty' 2>/dev/null || echo ''))"
[ -n "$cwd" ] || cwd="$PWD"
dir="${HOME}/.claude/.harness_state"
rd(){ v=$(cat "$dir/${sid}.$1" 2>/dev/null || echo 0); case "$v" in ''|*[!0-9]*) v=0 ;; esac; echo "$v"; }
edits=$(rd edits); baseline=$(rd baseline); research=$(rd research)   # agy 카운터는 여기서 미사용(코호트 감사 260702 — dead read 제거)
pending=$(( edits - baseline )); [ "$pending" -lt 0 ] && pending=0
if   [ -f "$cwd/rule_plan_work.md" ]; then rpw="있음";
elif [ -f "$cwd/work.md" ];          then rpw="있음(work.md)";
else rpw="없음"; fi
dv=0   # datavault 폴더 있을 때만 스캔(불필요 find 제거 — 코호트 감사 260702)
[ -d "$cwd/datavault" ] && { dv=$(find "$cwd/datavault" -maxdepth 1 -name '*.md' ! -name 'INDEX.md' 2>/dev/null | wc -l | tr -d ' '); case "$dv" in ''|*[!0-9]*) dv=0 ;; esac; }

# 물리 조건 → 후보 툴 목록(판단은 에이전트). 아래 슬롯형은 상위 최대 2개만(과부하 방지, 안티테제 1-C).
# 순위: verify > antithesis > paper > RPW > Datavault.
# 알려진 한계: verify·antithesis가 같은 신호(pending) 파생이라 pending≥3인 동안 두 슬롯을 점유 —
#   단 antithesis 실행 시 baseline 리셋으로 슬롯이 비므로 기아는 '검토를 계속 미루는 세션'에서만 지속(260702 안티테제).
paper=0; [ -f "$dir/${sid}.paper" ] && paper=1
cand=""; n=0
addc(){ [ "$n" -lt 2 ] && { cand="${cand} · $1"; n=$((n+1)); }; }
[ "$pending" -ge 2 ] && addc "verify(동작 확인?)"
[ "$pending" -ge 3 ] && addc "antithesis(미검토 ${pending})"
[ "$paper" = "1" ] && [ "$pending" -ge 2 ] && addc "paper(tex 편집 — 컴파일·리뷰?)"
[ "$rpw" = "없음" ] && [ "$edits" -ge 2 ] && addc "RPW생성(스냅샷 없음)"
[ "$edits" -ge 5 ] && [ "$dv" -eq 0 ] && addc "Datavault(결정→원자노트?)"

# 코호트 하달 — 슬롯 경쟁 밖 독립·최우선 노출(사용자 지시 260702: 팍팍·병렬·백그라운드, 결과 미반영도 OK).
# 트리거 = '마지막 agy 하달 이후 쌓인 작업(편집+조사 증분) ≥2'. 방출 = agy 하달(track-tools가 agy_be/agy_br 스냅샷 갱신 → 증분 0).
#   260702 2차 안티테제 A/B 수정: research 절대값(agy 조사 시 자기소거)·SIG 의존 pending(편집형 좀비) 대신 '하달 이후 증분'으로 통일 —
#   조사를 agy로 하든 WebSearch로 하든, 편집을 하든, 하달만 하면 확실히 꺼지고 새 작업이 쌓이면 다시 뜬다(좀비 없음).
agy_be=$(rd agy_be); agy_br=$(rd agy_br)
d_edits=$(( edits - agy_be )); [ "$d_edits" -lt 0 ] && d_edits=0
d_res=$(( research - agy_br )); [ "$d_res" -lt 0 ] && d_res=0
since=$(( d_edits + d_res )); cohort=""
[ "$since" -ge 2 ] && cohort=" · clemini하달(미하달 편집${d_edits}·조사${d_res} — Cohort 병렬·백그라운드, 결과 미반영 OK)"

# 후보 있을 때만 '자문' 1줄 주입. 코호트를 맨 앞에(최우선). 없으면 침묵. (문구 압축 — 매 턴 주입 토큰, 코호트 감사 260702)
[ -n "$cand$cohort" ] && printf '[하네스 자문] 지금 쓸 것?%s%s — 해당되면 묻지 말고 실행, 없으면 무시.\n' "$cohort" "$cand"
exit 0
