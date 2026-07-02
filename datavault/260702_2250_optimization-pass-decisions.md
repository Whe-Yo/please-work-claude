---
title: 최적화 패스는 실측이 먼저 — 매 턴 경로만 깎고, 마이크로 최적화는 기각
type: decision
date: 260702_2250
tags: [optimization, hooks, cost]
links: [260702_1510_cohort-critiques-own-activation, 260702_1126_install-doc-drift]
---

**WHAT**: 첫 하네스 최적화 패스(260702). 먼저 실측(매 턴 자문 최악 380B·36ms, 세션 로드 8.4KB, 훅 239줄) → 코호트 3파티션 감사 → 채택 7·기각 5.

**채택**(모두 매 턴/매 편집 경로): 자문 문구 압축(380→245B, -36%) · GC를 mark-work(매 편집)→session-start(세션 1회) 이관 · `.paper` 마커에 방출 경로 부여(antithesis ack 시 해제 — 세션 고착 해소) · datavault 폴더 존재 게이트 · dead `agy` read 제거 · gemini AGENTS.md "Universal" 정체성 정정 · clemini auto_edit 문서-코드 모순 제거.

**REJECTED**:
- 영문 미러 삭제(코호트 제안) — 사용자가 당일 명시한 README 스타일. 코호트는 이 맥락이 없다 → 코호트 제안은 맥락 필터 필수.
- 훅 공용 lib(common.sh) — 결합도↑, 한 파일 문제가 전체 가드 fail-closed 마비로 확산. 코호트도 기각 권고.
- jq eval @sh 통합·cat→read — 실측 36ms에서 수 ms 절감. 이득 미미 vs eval 표면·churn. **마이크로 최적화는 실측이 아프다고 말할 때만.**
- AGENTS.md 규율 절 압축 — 뉘앙스(함정 주석) 손실 위험 > 1.5KB 절감.
- ROADMAP 스테일 주장 — 사실과 다름(조건부 보류 문서로서 정확).

**WHY**: 하네스 고정비의 지배항은 "매 턴 주입 토큰"과 "매 편집 I/O"다. 거기만 깎으면 나머지는 소음. 규칙 이중 유지(전역↔레포)는 버그가 아니라 **소유권 분리**(전역=사용자 개인판, 레포=배포 템플릿)로 재정의 — 단 하네스 고유 절(코호트·금지)은 수동 동기화 대상.

관련: [[260702_1510_cohort-critiques-own-activation]] — 같은 날 코호트 감사 사이클.
