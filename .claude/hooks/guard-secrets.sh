#!/usr/bin/env bash
# guard-secrets.sh — §9 강제: .env·자격증명 읽기/출력 차단 (PreToolUse matcher: "Read|Bash").
# 차단 = exit 2 (+stderr 이유가 Claude로 전달됨). 패턴은 보수적(과차단 우선). 조정은 아래 변수에서.
# bash 3.2 호환. 의존: jq.
set -u

# jq 탐색: PATH 우선, 없으면 흔한 절대경로 폴백(260629_2349 — PATH 미포함 시 전 도구 마비 방지). 진짜 부재 시만 fail-closed.
JQ=""; for j in jq "$HOME/.local/bin/jq" /opt/homebrew/bin/jq /usr/local/bin/jq /usr/bin/jq /mingw64/bin/jq; do command -v "$j" >/dev/null 2>&1 && { JQ="$j"; break; }; done
[ -n "$JQ" ] || { echo "차단(강제층): jq를 못 찾음 — 보안 가드 작동 불가. jq 설치하거나 훅 일시 비활성화(~/.claude/settings.json hooks 제거). fail-open 방지." >&2; exit 2; }

# 비밀로 간주하는 경로/파일 패턴 (앞뒤 경계로 단어 단위 매칭)
SECRET_PATH='(^|[^A-Za-z0-9._-])(\.env([./A-Za-z0-9_-]*)?|id_rsa|id_dsa|id_ecdsa|id_ed25519|[A-Za-z0-9._-]+\.(pem|p12|pfx))([^A-Za-z0-9]|$)'
# 경계 비소비형 코어 (Bash 명령 매칭용 — 동사 뒤 공백을 경계로 재사용)
SECRET_CORE='(\.env([./A-Za-z0-9_-]*)?|id_rsa|id_dsa|id_ecdsa|id_ed25519|[A-Za-z0-9._-]+\.(pem|p12|pfx))'
SECRET_FILE2='(/\.aws/credentials|(^|/)credentials\.(json|ya?ml|env)|(^|/)secrets?\.(json|ya?ml|toml|env))'
# 비밀 아님(허용): 예시/템플릿 .env
# 비밀 아님(허용): 예시/템플릿 .env, TS 타입선언(.env.d.ts), direnv 설정(.envrc)
ALLOW_ENV='\.env\.(example|sample|template|dist|md|d\.ts)|\.envrc([^A-Za-z0-9]|$)|\.pub([^A-Za-z0-9]|$)'
# 파일을 '읽는' 명령(단순 언급·커밋 메시지와 구분하기 위함)
READ_VERB='(cat|bat|less|more|head|tail|nl|tac|xxd|od|hexdump|strings|nano|vi|vim|view|emacs|open|code|pbcopy|source|\.|cp|rsync|scp|sftp|curl|wget|awk|sed|grep|egrep|fgrep|rg|ag|perl|python|python3|ruby|node|deno|php|dd|tee|gpg|base64|shasum|md5|md5sum|tr)'

input="$(cat)"
tool="$(printf '%s' "$input" | "$JQ" -r '.tool_name // empty' 2>/dev/null)"

block() { echo "차단(§9): 비밀/자격증명 접근 금지 — $1. 대상: $2" >&2; exit 2; }

case "$tool" in
  Read)
    p="$(printf '%s' "$input" | "$JQ" -r '.tool_input.file_path // empty' 2>/dev/null)"
    [ -n "$p" ] || exit 0
    printf '%s' "$p" | grep -Eiq "$ALLOW_ENV" && exit 0
    printf '%s' "$p" | grep -Eiq "$SECRET_PATH"  && block ".env/키 파일" "$p"
    printf '%s' "$p" | grep -Eiq "$SECRET_FILE2" && block "자격증명 파일" "$p"
    ;;
  Bash)
    c="$(printf '%s' "$input" | "$JQ" -r '.tool_input.command // empty' 2>/dev/null)"
    [ -n "$c" ] || exit 0
    # .env/키를 '읽는' 명령만 차단
    if printf '%s' "$c" | grep -Eiq "(^|[|&;(\`[:space:]])$READ_VERB[[:space:]]+([^|&;]*[[:space:]/=\"'(,:])?$SECRET_CORE([^A-Za-z0-9]|\$)" \
       && ! printf '%s' "$c" | grep -Eiq "$ALLOW_ENV"; then
       block "읽기 명령이 비밀 파일 대상" "$c"
    fi
    # 리다이렉트 입력: `< .env`
    if printf '%s' "$c" | grep -Eq '<[[:space:]]*[^|&;<>]*\.env([^A-Za-z0-9._-]|$)' \
       && ! printf '%s' "$c" | grep -Eiq "$ALLOW_ENV"; then
       block "리다이렉트로 .env 읽기" "$c"
    fi
    # ssh/aws 등 자격증명 파일 직접 참조
    printf '%s' "$c" | grep -Eiq "$READ_VERB[[:space:]][^|&;]*$SECRET_FILE2" && block "자격증명 파일 접근" "$c"
    ;;
  *) exit 0 ;;
esac
exit 0
