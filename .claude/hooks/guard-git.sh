#!/usr/bin/env bash
# guard-git.sh — §9 강제: 파괴적 git 차단 (force-push / reset --hard / history rewrite).
# 차단 = exit 2. 일반 push/pull/commit/reset(soft·mixed)은 통과. bash 3.2 호환. 의존: jq.
set -u

input="$(cat)"
[ "$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)" = "Bash" ] || exit 0
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)"
[ -n "$cmd" ] || exit 0

# git이 포함된 명령만 검사
printf '%s' "$cmd" | grep -Eq '(^|[|&;(\`[:space:]])git([[:space:]]|$)' || exit 0

has() { printf '%s' "$cmd" | grep -Eq "$1"; }
deny() { echo "차단(§9): 파괴적 git — $1. 명시 승인이 필요하다(히스토리 유실 위험). 정말 의도했다면 터미널에서 직접 실행하거나 훅을 일시 비활성화하라. 명령: $cmd" >&2; exit 2; }

# force push (--force / --force-with-lease / -f)
if has 'git[[:space:]]+([^|&;]*[[:space:]])?push([[:space:]]|$)' && has '(--force([-=a-z]*)?|[[:space:]]-f([[:space:]]|$))'; then deny "force push"; fi
# push +ref (강제 갱신)
if has 'git[[:space:]]+([^|&;]*[[:space:]])?push' && has 'push[^|&;]*[[:space:]]\+[A-Za-z0-9_./-]'; then deny "push +ref(강제 갱신)"; fi
# push --mirror
if has 'git[[:space:]]+([^|&;]*[[:space:]])?push[^|&;]*--mirror'; then deny "push --mirror"; fi
# reset --hard
if has 'git[[:space:]]+([^|&;]*[[:space:]])?reset([[:space:]]|$)' && has '[[:space:]]--hard([[:space:]]|$)'; then deny "reset --hard"; fi
# history rewrite
if has 'git[[:space:]]+([^|&;]*[[:space:]])?(filter-branch|filter-repo)([[:space:]]|$)'; then deny "history rewrite(filter-branch/repo)"; fi
# 대화형 rebase(히스토리 재작성) — pull --rebase는 미해당(rebase 단독 토큰만으론 안 막음)
if has 'git[[:space:]]+([^|&;]*[[:space:]])?rebase([[:space:]]|$)' && has '(-i([[:space:]]|$)|--interactive)'; then deny "rebase -i(히스토리 재작성)"; fi
# 미추적 파일 삭제 clean -f
if has 'git[[:space:]]+([^|&;]*[[:space:]])?clean([[:space:]]|$)' && has '[[:space:]]-[A-Za-z]*f'; then deny "clean -f(미추적 파일 삭제)"; fi
# 미커밋 변경 대량 폐기: checkout/restore의 '.' 타깃 (단일 파일 checkout은 통과)
if has 'git[[:space:]]+([^|&;]*[[:space:]])?(checkout|restore)[[:space:]]+([^|&;]*[[:space:]])?(--[[:space:]]+)?\.([[:space:]]|$)'; then deny "checkout/restore . (미커밋 변경 폐기)"; fi
# ref/reflog 파괴
if has 'git[[:space:]]+([^|&;]*[[:space:]])?update-ref[[:space:]]+([^|&;]*[[:space:]])?-d([[:space:]]|$)'; then deny "update-ref -d(ref 삭제)"; fi
if has 'git[[:space:]]+([^|&;]*[[:space:]])?reflog[[:space:]]+([^|&;]*[[:space:]])?expire'; then deny "reflog expire(reflog 파괴)"; fi
# 브랜치 강제 삭제(-D) — 안전한 -d(병합 확인)는 통과
if has 'git[[:space:]]+([^|&;]*[[:space:]])?branch[[:space:]]+([^|&;]*[[:space:]])?-D([[:space:]]|$)'; then deny "branch -D(강제 삭제)"; fi

exit 0
