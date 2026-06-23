# Feedback — 260623_1819 / claude

> 환경: Claude Desktop "Cowork"(에이전트 모드, Claude Code/Agent SDK 기반)에서 하네스 클론을 직접 점검하다 발견. 대상: please-work-claude (Claude·Claude Desktop 타깃 하네스).

---

## [FRICTION-1] Claude Desktop(Cowork) 삭제제한 마운트 → git index.lock 잔존으로 클론 wedge

### 유형
friction

### 요약
Cowork(Claude Desktop)은 사용자 폴더를 "생성 가능·삭제 차단" 마운트로 노출한다. 이 위에서 git이 인덱스/ref를 갱신할 때 `.git/index.lock`을 만들고 rename으로 교체하는데, unlink가 EPERM이라 락이 남아 이후 모든 git 작업이 `index.lock: File exists`로 막힌다. feedback 스킬의 commit/push 절차가 이 런타임에서 선행 차단된다.

### 무슨 일이
- 하려던 것: 하네스 클론에서 상태 점검(`git status`) 후 feedback md 커밋.
- 일어난 것: `git status` 한 번만으로 `.git/index.lock`(0B)이 생성되고 `rm` 불가(`Operation not permitted`) → 3개 클론 모두 wedge → 커밋 차단.
- 기대한 것: 표준 git 작업이 마운트에서 그대로 동작.

### 환경
- 에이전트: claude (Claude Desktop · Cowork 에이전트 모드)
- OS: 호스트 macOS, 작업 샌드박스 Linux(virtiofs류 마운트)
- 마운트 특성: 파일 create OK / unlink·rename-over EPERM. Cowork `allow_cowork_file_delete` 승인 후 해소됨.
- git 2.34.1

### 재현
1. Cowork에서 하네스 클론 폴더 연결.
2. 클론에서 `git status` 1회 → `.git/index.lock` 생성.
3. `rm .git/index.lock` → `Operation not permitted` → 이후 `git add`/`commit` 전부 차단.
4. (해소) Cowork 삭제 권한 승인 → `rm` 가능 → git 정상화, 인덱스 갱신 후 락 미잔존 확인.

### 관련 스킬·규칙
- `skills/feedback/SKILL.md` 5절(commit/push)이 이 런타임에서 선행 차단. 6절(환경 분기: git 불가 시 md 출력)이 안전망이지만 "삭제제한 마운트" 케이스를 명시하지 않음.
- `skills/setup`·`skills/manage` — Claude Desktop/Cowork 런타임 어댑터 부재.

### 권장 대응
- feedback/setup에 "삭제제한 마운트(Cowork 등)" 감지 분기: 인덱스 쓰는 git 작업 전 삭제권한 확보 안내, 실패 시 6절(md 출력) 자동 폴백.
- 점검류 스킬(boost 등)은 선행 git 호출이 남긴 `.git/index.lock` 잔존 여부를 확인·정리하도록(클론 잠금 방지).

---

## [DOC-1] SKILL_INDEX의 feedback 설명이 실제 절차와 불일치

### 유형
enhancement (doc)

### 요약
`skills/SKILL_INDEX.md`는 feedback을 "사용 중 발견한 문제를 저장소 GitHub 이슈로 보고"로 적었으나, 실제 `skills/feedback/SKILL.md`는 `log_for_test/`에 md 작성·커밋(이슈 아님). 입문자가 GitHub 이슈를 찾게 만든다.

### 권장 대응
- SKILL_INDEX의 feedback 행 설명을 "log_for_test/에 md로 기록·커밋"으로 정정(현행 절차와 일치).

---

## 반영 (260623)

- **[FRICTION-1] 삭제제한 마운트 → index.lock wedge** → **반영(완화)**. (1) 정체된 `.git/index.lock`을 제거해 3개 클론 git wedge 해소. (2) `skills/feedback/SKILL.md` 6절(환경 분기)에 "삭제제한 마운트·잔존 락 제거 후 폴백" 절차 추가. 근본(마운트 unlink EPERM)은 런타임 특성이라 코드로 못 막음 → 절차로 완화. **종결.**
- **[DOC-1] SKILL_INDEX feedback 설명 불일치** → **반영**. `skills/SKILL_INDEX.md` feedback 행을 "`log_for_test/`에 md로 기록·커밋(GitHub 이슈 아님)"으로 정정, 트리거도 "피드백 남겨"로 정렬. **종결.**
