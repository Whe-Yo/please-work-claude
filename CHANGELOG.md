# Changelog

이 프로젝트의 주요 변경을 기록한다. 형식은 [Keep a Changelog](https://keepachangelog.com/)를 따르고, 버전은 [SemVer](https://semver.org/)를 지향한다. 프로토타입 단계이므로 0.x.

업데이트 확인(`manage`의 일일 점검)은 이 파일과 git 태그를 기준점으로 삼을 수 있다.

## [Unreleased]
- (다음 변경을 여기에 누적)

## [0.1.0] - 260617
프로토타입 첫 버전. 핵심 3축(적응형 하네싱 / RPW / N회 안티테제) + 2층 구조 정립.

### Added
- **3축 정체성**: 적응형 하네싱, RPW(현재 상태 스냅샷), N회 안티테제 검토.
- **2층 구조 명문화**: 지시 층(범용·소프트) + 강제 층(런타임 종속·하드). README에 효력 그라데이션 문서화.
- 스킬 11종: `boost`, `worklog`, `plan`, `verify`, `review`, `antithesis`, `peer`, `paper`, `setup`, `manage`, `resource`.
- `resource` 스킬: 무거운 작업 착수 전 호스트 리소스 라이브 조회(저장 없음, 호스트별 분기).
- `setup`의 상태 파일 초기화(`~/.agents/harnessing_state.json`: repoPath·skillsDir).
- `manage`의 일일 업데이트 확인(boost에서 자동 트리거) + skillsDir 기반 경로 조회.
- AGENTS.md 9절 "절대 금지"(치명적·강제 층 대상), 강제 층 예시로 `.env` Read 차단(권한 deny).
- `ROADMAP.md`: 보류 기능(리소스 예약 원장) 설계 기록.

### Changed
- `RULES.md` → `AGENTS.md` 리네임 (2026 업계 표준 대응).
- RPW를 히스토리 로그에서 "현재 상태 스냅샷"(Rule/Plan/Work)으로 단순화. 3-tier(Always/Ask first/Never do) + WHY 병기.
- AGENTS.md signal density 패스: generic 규칙 압축, 각 규칙에 WHY.
- antithesis 적용 범위 확장(코드·문서·조사·설계), 최소 1회 하한.
- 날짜 형식 `YYMMDD_HHMM`로 통일.

### Removed
- 에이전트 종속 설치 스크립트·전용 설정, 에이전트별 적용 가이드(→ `setup` 위임).
- RPW의 Decision Log·Work Log·AntiPatterns 누적 구조(→ git 히스토리/커밋 메시지).
