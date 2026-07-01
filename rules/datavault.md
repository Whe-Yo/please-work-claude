# Datavault — 누적 지식 그래프 (제텔카스텐)

> **"Knowledge is power, guard it well."** RPW가 *지금*을 담는 스냅샷이면, Datavault는 *아는 것*을 담는 영속 그래프다. (설계 근거: Cohort 병렬 조사 + Magos 종합 260701. 이름 유래: clemini에서 트림됐던 'Datavault'를 지식 그래프로 **재정의**.)

## 1. RPW vs Datavault vs git — 역할 분리(중복 금지)
| | **RPW** (`rule_plan_work.md`) | **Datavault** (`datavault/`) | **git** |
|---|---|---|---|
| 담는 것 | 현재 세션 실행 컨텍스트(상태·계획·할 일) | 세션 초월 지식(결정·패턴·안티패턴·참조) | 변경 사실(diff·커밋) |
| 수명 | 덮어씀(휘발) | 누적(안 지움) | 영구 로우데이터 |
| 로드 | boost가 매 세션 전체 | `[[링크]]`로 필요한 것만 | — |

**중복 판단**: *지금만 필요* = RPW / *다시 쓸 지식* = Datavault / *무엇이 언제 바뀜* = git. RPW의 Work가 관련 Datavault 노트로 `[[링크]]`한다.

## 2. 구조 (옵시디언·git 호환)
- 위치: 프로젝트 루트 `datavault/`.
- **세미-플랫**: `datavault/` 아래 원자 노트를 평면으로 + `datavault/INDEX.md`(MOC=Map of Content)가 허브. 깊은 폴더 금지(파일 이동=git 이력 단절).
- 파일명: `YYMMDD_HHMM_kebab-case.md` — 공백·특수문자(`/ \ : * ? " < > |`) 금지(Win/mac 호환·충돌 방지).
- **`[[wikilink]]`** (상대경로 강제, grep 가능한 수동 링크). 백링크는 옵시디언 패널로 조회 — **수동 작성 금지**(머지 충돌 주범).
- `.gitignore`: `.obsidian/workspace*.json`, `.obsidian/cache/`.

## 3. 원자 노트 규칙
- **원자성**: 1 노트 = 1 개념/결정/패턴/안티패턴(화면 한 페이지 이내).
- **연결성**: 고아 노트 금지 — 새 노트는 기존 노트나 INDEX와 반드시 `[[링크]]`.
- **독립성**: 노트 하나만 읽어도 이해되게.
- **맥락적 링크**: 왜 연결했는지 한 줄.

### 노트 템플릿
```markdown
---
title: <한 문장 요약>
type: decision | pattern | anti-pattern | reference
date: YYMMDD_HHMM
tags: []
links: []          # 관련 노트 파일명
---

<하나의 원자적 지식. type=decision이면 WHAT / WHY / REJECTED.>

관련: [[다른-노트]]
```

### INDEX.md (MOC)
주제 허브. `[[노트]]` + 1줄 맥락만. 깊은 폴더 대신 여기서 관계를 정의한다.

## 4. 자율 작동 — "잊혀지지 않게" (핵심)
Datavault는 antithesis·RPW와 같은 **"항상 판단" 층**에 든다:
- `process-status` 훅(UserPromptSubmit)이 **매 턴 Datavault 노트 수를 노출**하고, **주요 작업(편집 임계치↑) 후 노트 미추가면 넛지**한다.
- 원칙: **아키텍처 결정·패턴·안티패턴이 나오면 그 자리에서 원자 노트로.** "나중에"는 유실.
- (참조 구현: 에이전트 memory 시스템 `MEMORY.md`(인덱스) + 원자 노트 + `[[링크]]`가 이미 이 구조 — 검증됨.)
