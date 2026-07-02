#!/usr/bin/env bash
# guard-git.sh — §9 강제: 파괴적 git 차단 (force-push / reset --hard / history rewrite).
# 차단 = exit 2. 일반 push/pull/commit/reset(soft·mixed)은 통과. bash 3.2 호환. 의존: jq.
set -u

# jq 탐색: PATH 우선, 없으면 절대경로 폴백(260629_2349 — PATH 미포함 시 전 도구 마비 방지). 진짜 부재 시만 fail-closed.
JQ=""; for j in jq "$HOME/.local/bin/jq" /opt/homebrew/bin/jq /usr/local/bin/jq /usr/bin/jq /mingw64/bin/jq; do command -v "$j" >/dev/null 2>&1 && { JQ="$j"; break; }; done
[ -n "$JQ" ] || { echo "차단(강제층): jq를 못 찾음 — 파괴적 git 가드 작동 불가. jq 설치하거나 훅 일시 비활성화. fail-open 방지." >&2; exit 2; }

input="$(cat)"
[ "$(printf '%s' "$input" | "$JQ" -r '.tool_name // empty' 2>/dev/null)" = "Bash" ] || exit 0
cmd="$(printf '%s' "$input" | "$JQ" -r '.tool_input.command // empty' 2>/dev/null)"
[ -n "$cmd" ] || exit 0

# 개행 정규화(260702): 백슬래시-개행(연속행)은 공백으로 잇고, 맨 개행은 셸 의미 그대로 ';'로 —
#   근접성 매칭([^|&;]*)이 줄 단위 grep에 갈라져 'git push \<개행> --force'를 놓치던 회귀 방지. bash 3.2 치환만 사용.
cmd_n="${cmd//\\$'\n'/ }"; cmd_n="${cmd_n//$'\n'/;}"
# 인용 구간(-m 메시지·echo 문자열 등) 제거 후 검사 — `git commit -m "...push --force..."` 거짓양성 방지(260629_2349).
scan="$(printf '%s' "$cmd_n" | sed -E 's/"[^"]*"//g' | sed -E "s/'[^']*'//g")"

# git이 포함된 명령만 검사(인용 제거본 기준 — echo "git push --force"는 제외됨)
printf '%s' "$scan" | grep -Eq '(^|[|&;(\`[:space:]])git([[:space:]]|$)' || exit 0

has() { printf '%s' "$scan" | grep -Eq "$1"; }
deny() { echo "차단(§9): 파괴적 git — $1. 명시 승인이 필요하다(히스토리 유실 위험). 정말 의도했다면 터미널에서 직접 실행하거나 훅을 일시 비활성화하라. 명령: $cmd" >&2; exit 2; }

# force push (--force / -f) — 플래그가 push와 같은 파이프라인 조각 안에 있을 때만(260702 오탐 수정: 'rm -f x; git push'가
#   전역 -f 매칭으로 차단되던 것). --force-with-lease/-if-includes는 경계 매칭(--force 뒤 공백/끝)이라 자연 면제.
if has 'git[[:space:]]+([^|&;]*[[:space:]])?push[^|&;]*[[:space:]](--force|-f)([[:space:]]|$)'; then deny "force push(plain)"; fi
# push +ref (강제 갱신)
if has 'git[[:space:]]+([^|&;]*[[:space:]])?push' && has 'push[^|&;]*[[:space:]]\+[A-Za-z0-9_./-]'; then deny "push +ref(강제 갱신)"; fi
# push --mirror
if has 'git[[:space:]]+([^|&;]*[[:space:]])?push[^|&;]*--mirror'; then deny "push --mirror"; fi
# reset --hard — 같은 조각 내 인자일 때만(260702, force push와 동일 계열 수정)
if has 'git[[:space:]]+([^|&;]*[[:space:]])?reset[^|&;]*[[:space:]]--hard([[:space:]]|$)'; then deny "reset --hard"; fi
# history rewrite
if has 'git[[:space:]]+([^|&;]*[[:space:]])?(filter-branch|filter-repo)([[:space:]]|$)'; then deny "history rewrite(filter-branch/repo)"; fi
# ref/reflog 파괴 (히스토리 비가역 손실 — 유지)
if has 'git[[:space:]]+([^|&;]*[[:space:]])?update-ref[[:space:]]+([^|&;]*[[:space:]])?-d([[:space:]]|$)'; then deny "update-ref -d(ref 삭제)"; fi
if has 'git[[:space:]]+([^|&;]*[[:space:]])?reflog[[:space:]]+([^|&;]*[[:space:]])?expire'; then deny "reflog expire(reflog 파괴)"; fi
# 일상 루틴은 의도적으로 차단 안 함(일상검토 260626): branch -D · checkout/restore . · clean -f · rebase -i
#   — reflog 복구 가능하거나 미커밋/미추적만 영향 → 가드레일은 '치명적·비가역'에 한정.

exit 0
