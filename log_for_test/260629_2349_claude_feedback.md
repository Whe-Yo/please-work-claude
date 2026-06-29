# Feedback — 260629_2349 / claude

## 유형
bug + enhancement (Windows 환경 강건성)

## 요약
Windows에서 강제층 훅 설치·운용 중 발견한 결함 4건 — jq fail-closed의 전 도구 마비 위험, guard-git 거짓양성, .pub 차단, bash.exe 경로 하드코딩. 독립 적대 검토로 전부 실측 재현됨.

## 무슨 일이
setup 풀세팅(Windows 11, Claude Code) 직후 독립 인스턴스로 강제층을 적대 검증하다 확인.

- **[중대] jq 부재 → 전 도구 마비 + 복구 난항**
  - 하려던 것: jq 일시 부재 상황 점검.
  - 일어난 것: `guard-secrets.sh:8`·`guard-git.sh:7`의 `command -v jq || exit 2`가 fail-closed라, jq를 못 찾으면 benign한 `Read readme.txt`까지 exit 2로 차단됨. 복구하려면 Bash가 필요한데 그 Bash도 막혀 자가복구 불가.
  - 기대한 것: 보안 민감 대상만 차단하거나, jq를 PATH 의존이 아니라 절대경로 폴백으로 탐색.
  - 제안: 훅 상단에서 `for j in "$HOME/.local/bin/jq" "$(command -v jq)" /usr/bin/jq /mingw64/bin/jq; do [ -x "$j" ] && JQ="$j" && break; done` 식으로 jq를 확정하고 이후 `"$JQ"` 사용. fail-closed는 유지하되 탈출구(훅 비활성화 경로)를 stderr에 명시.

- **[중대] guard-git 거짓양성 — 명령 문자열 substring 검사**
  - 일어난 것: `git commit -m "never push --force to main"`, `echo 'do not reset --hard' > notes.txt`가 exit 2로 차단됨. 실제 파괴 행위가 아닌 언급/문서화·커밋 메시지도 막음. 실사용 빈발 예상.
  - 기대한 것: `git push`/`git reset`이 실제 실행 토큰일 때만 차단. 최소한 `-m`/`--message`의 인용문 구간은 검사 제외.
  - 참고: `--force-with-lease` 면제, 읽기전용 `grep 'git push --force'` 통과는 양호.

- **[경미] guard-secrets가 .pub 공개키도 차단**
  - 일어난 것: `Read .../id_ed25519_main.pub`가 SECRET_PATH 키이름 매칭으로 차단 가능. 공개키는 비밀 아님.
  - 제안: `.pub` 확장자를 ALLOW에 추가.

- **[경미] settings.json의 bash.exe 절대경로 하드코딩 (Windows)**
  - 일어난 것: Windows엔 PATH에 bash가 없어 훅 command를 `"C:/Program Files/Git/usr/bin/bash.exe" "<hook>.sh"`로 하드코딩해야 함. Git 설치 위치가 다르면(예: `%LOCALAPPDATA%\Programs\Git`) 전 훅이 실행 실패 → fail-open(가드 무력) 우려.
  - 제안: setup이 `bash.exe` 위치를 탐지해 치환하도록 절차화(현재는 수동). Windows 설치 가이드에 명시.

- **[경미] .harness_state 마커 누적**
  - `.work`/`.nudged` 마커가 세션마다 쌓이고 청소 로직 없음(기능 영향은 없음).

## 환경
- 에이전트: claude (Claude Code)
- OS: Windows 11 (MINGW64 / Git Bash, bash 5.x)
- 도구: winget jq 1.8.2, 훅은 `"C:/Program Files/Git/usr/bin/bash.exe"`로 호출

## 재현
1. 강제층 설치(setup) 후 PATH에서 jq 제거 → 임의 `Read` 도구 호출 → exit 2(전 차단) 확인.
2. `git commit -m "... push --force ..."` 형태 JSON을 guard-git.sh에 파이프 → exit 2(거짓양성).
3. `.../id_ed25519_main.pub` Read JSON을 guard-secrets.sh에 파이프 → exit 2.

## 관련 스킬·규칙
- skills/setup (강제층 설치·Windows 분기 부재)
- .claude/hooks/guard-secrets.sh, guard-git.sh
- rules/CLAUDE.md §9 (강제층 대상)
