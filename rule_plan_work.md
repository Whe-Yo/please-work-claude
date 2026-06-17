# RPW — please-work-harness

## Rule

### Always do
- 작업 유형에 맞게 페르소나를 조정한다 (코드·구현 → 아키텍트, 조사·분석 → 분석가, 논문·편집 → 학술 편집자)
- 이해 > 계획 > 실행 > 검증 > 보고 순서로 작업한다
- 단순 답변이 아닌 주요 작업 완료 후 antithesis를 실행한다
- 모든 소통은 한국어로, 첫 문장은 결과로 시작한다
- 날짜는 YYMMDD_HHMM 형식으로 표기한다

### Ask first
- 스킬 파일 삭제·전면 교체 전
- 아키텍처 범위 밖 변경 시
- 파괴적 git 명령 실행 전 (force push, reset --hard 등)

### Never do
- 검증 안 된 결과를 완료로 보고
- antithesis 검토 프롬프트에 이전 대화 컨텍스트 포함
- 채팅창에 YAML·JSON 등 구조화 데이터 출력

---

## Plan

목표: 보류 설계 기록 + 버전 관리 + 피드백 채널

- [x] Harnessing_Agent → please-work-harness 디렉토리·참조·GitHub 원격명 리네임
- [x] agents_chat.md 프로젝트 내 이동 + gitignore
- [x] README 2층 모델(지시 층/강제 층) 명문화, 낡은 RPW·n회 서술 교정
- [x] AGENTS.md signal density 패스 + WHY 병기 + 9절 치명적 금지 신설
- [x] RPW 템플릿 WHY·Never do 구체화
- [x] antithesis 로그 채택 4건 반영(#2·#4·#5·#6), #3은 스냅샷화로 무효 명시
- [x] Claude 어댑터 동기화(~/.claude commands) + 강제 층(.env Read deny) 추가
- [x] 절차 실행 검증: state파일 생성 → manage fetch/감지 체인 동작 확인
- 제미나이 3대 과제 판정: ① Metrics 블록·③ archive 압축 = 기각(스냅샷 충돌). ② Policy Gate = 범용 스킬 신설 대신 강제 층 어댑터로 흡수.

---

## Work

ROADMAP.md(리소스 예약 원장 보류 설계), CHANGELOG.md + v0.1.0 태그(버전 관리), feedback 스킬 + GitHub 이슈 템플릿(사용 중 피드백 채널) 추가. 스킬 12종. 피드백은 성역 원칙상 저장소 직접 수정 대신 이슈로, 환경별 분기(API 직접/수동 붙여넣기).

이전: resource 스킬 추가 완료 — 무거운 작업 착수 전 호스트 리소스 라이브 조회·보고(저장 없음, 호스트별 분기). 3차 안티테제로 큐·스코프계층·좀비GC 기각(자기모순·과잉설계), 스냅샷 전용으로 축소. Mac에서 ps 폴백 동작 검증. SKILL_INDEX·README(11종)·Claude 커맨드 동기화.

이전: 업데이트 5단계 완료. README 2층 모델 + AGENTS.md signal density + RPW 템플릿 WHY/Never do + 버그 4건 + Claude 어댑터 동기화 + 강제 층(.env Read deny). 절차 동작은 state파일→manage fetch 체인으로 실행 검증함. 강제 층 deny 규칙은 스키마 검증 완료, 현재 세션 즉시 활성 여부는 Claude Code 핫리로드 의존(재시작 시 확실). 제미나이(안티그래비티)와 agents_chat.md로 교차 협업 중.
