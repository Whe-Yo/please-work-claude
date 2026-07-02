#!/usr/bin/env bash
# track-tools.sh — 카운터 갱신 + antithesis baseline 리셋. PostToolUse "Bash|Task|WebSearch|WebFetch". 항상 exit 0.
# baseline = 마지막 antithesis(검토 ack) 시점의 편집수. antithesis Task 실행 시만 리셋(안티테제 1-A: 아무 Task나 리셋하던 것 수정).
# research는 하달(agy) 시 리셋한다(260702 코호트 반론: 미리셋이면 work 단조증가로 넛지가 영구 고착=좀비 알림).
#   "계속 팍팍"은 넛지를 안 끄는 게 아니라, 조사분을 코호트로 넘기면 꺼졌다가 새 조사가 쌓이면 다시 뜨는 방식으로 달성.
set -u
input="$(cat 2>/dev/null)"
sid="$(printf '%s' "$input" | (jq -r '.session_id // "nosession"' 2>/dev/null || echo nosession))"
[ -n "$sid" ] || sid=nosession
tool="$(printf '%s' "$input" | (jq -r '.tool_name // empty' 2>/dev/null || echo ''))"
dir="${HOME}/.claude/.harness_state"; mkdir -p "$dir" 2>/dev/null
rd(){ v=$(cat "$dir/${sid}.$1" 2>/dev/null || echo 0); case "$v" in ''|*[!0-9]*) v=0 ;; esac; echo "$v"; }
inc(){ echo $(( $(rd "$1") + 1 )) > "$dir/${sid}.$1" 2>/dev/null; }
# antithesis 시그니처(ack 판정). 알려진 한계: 키워드 기반이라 안티테제에 '관한' 조사도 ack될 수 있다(거짓 양성) —
#   결과 반영 여부까지는 추적 불가(작업완료 마커 재프레임은 백로그).
SIG='antithesis|안티테제|반론 검토|독립 검토자|독립 인스턴스'
case "$tool" in
  Task)
    # antithesis Task일 때만 baseline 리셋(=검토 ack). 다른 서브에이전트(Explore·구현 위임)는 리셋 안 함.
    tp="$(printf '%s' "$input" | (jq -r '.tool_input.prompt // .tool_input.description // empty' 2>/dev/null || echo ''))"
    printf '%s' "$tp" | grep -Eqi "$SIG" && echo "$(rd edits)" > "$dir/${sid}.baseline" 2>/dev/null
    ;;
  WebSearch|WebFetch) inc research ;;
  Bash)
    cmd="$(printf '%s' "$input" | (jq -r '.tool_input.command // empty' 2>/dev/null || echo ''))"
    # 단어경계(-w) — 'magyar'·'pagy.txt'·'xdelegate.sh' 오탐 방지(260702 안티테제 C).
    if printf '%s' "$cmd" | grep -Ewq 'agy|delegate\.sh|delegate-fanout\.sh'; then
      inc agy
      # 마지막 하달 시점의 편집·조사 스냅샷 = 코호트 넛지 방출 경로(하달하면 증분 0 → 꺼짐). 260702 2차 안티테제 A/B:
      #   research 절대값(WebSearch만 증가 → agy 조사 시 자기소거)도, SIG 의존 pending(편집형 좀비)도 아닌
      #   '마지막 하달 이후 증분'으로 통일 → 조사를 agy로 하든 편집을 하든 하달만 하면 확실히 방출.
      echo "$(rd edits)" > "$dir/${sid}.agy_be" 2>/dev/null
      echo "$(rd research)" > "$dir/${sid}.agy_br" 2>/dev/null
      # agy 경유 검토(--deep 오프로드 등)는 antithesis도 ack — clemini '이원 안티테제'와 정합.
      printf '%s' "$cmd" | grep -Eqi "$SIG" && echo "$(rd edits)" > "$dir/${sid}.baseline" 2>/dev/null
    fi
    ;;
esac
exit 0
