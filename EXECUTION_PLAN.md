# 데이터베이스 테스트 실행 계획

## 📋 실행 순서

### Phase 1: 환경 준비 및 검증 (5분)
1. ✅ Oracle Database 연결 확인
2. ✅ llm_admin 사용자 확인/생성
3. ✅ 기존 테이블 존재 여부 확인
4. ✅ 필요시 DROP TABLE 실행

### Phase 2: 테이블 생성 (5분)
1. 0_create_table.sql 실행
2. 테이블 생성 확인 (10개 테이블)
3. 제약조건 확인
4. 에러 발생 시 기록 및 수정

### Phase 3: 데이터 삽입 (10분)
1. 1_insert_department.sql (10개)
2. 2_insert_user.sql (150개)
3. 3_insert_project.sql (100개)
4. 4_insert_model.sql (22개)
5. 5_insert_model_config.sql (132개)
6. 6_insert_dataset.sql (30개)
7. 7_insert_deployments.sql (44개)
8. 8_insert_prompt_template.sql (120개)
9. 9_insert_sessions.sql (650개)
10. 10_insert_session_logs.sql (4,860개)

각 단계마다:
- 삽입 전 테이블 레코드 수 확인
- 삽입 실행
- 삽입 후 레코드 수 확인
- 에러 발생 시 기록

### Phase 4: 종합 테스트 실행 (10분)
1. test_all_queries.sql 실행
2. PART 1: 데이터 값 검증 (5개 쿼리)
3. PART 2: 상재님 쿼리 (10개)
4. PART 3: 영진님 쿼리 (10개)
5. PART 4: 무결성 검증 (13개)
6. PART 5: 통계 요약 (5개)

### Phase 5: 에러 분석 및 수정 (10분)
1. 에러 로그 분석
2. 수정 사항 기록
3. SQL 파일 수정
4. 재실행

### Phase 6: 최종 보고서 작성 (5분)
1. 실행 결과 요약
2. 발견된 이슈 목록
3. 수정 사항 목록
4. 최종 검증 결과

---

## 🔍 체크리스트

### 테이블 생성 체크리스트
- [ ] DEPARTMENT
- [ ] USER
- [ ] PROJECT
- [ ] MODEL
- [ ] MODEL_CONFIG
- [ ] DATASET
- [ ] DEPLOYMENTS
- [ ] SESSIONS
- [ ] SESSION_LOGS
- [ ] PROMPT_TEMPLATE
- [ ] seq_log_sequence (시퀀스)

### 데이터 삽입 체크리스트
- [ ] DEPARTMENT (목표: 10개)
- [ ] USER (목표: 150개)
- [ ] PROJECT (목표: 100개)
- [ ] MODEL (목표: 22개)
- [ ] MODEL_CONFIG (목표: 132개)
- [ ] DATASET (목표: 30개)
- [ ] DEPLOYMENTS (목표: 44개)
- [ ] PROMPT_TEMPLATE (목표: 120개)
- [ ] SESSIONS (목표: 650개)
- [ ] SESSION_LOGS (목표: ~4,860개)

### 쿼리 테스트 체크리스트
#### PART 1: 데이터 검증
- [ ] 1-1: DEPLOYMENTS 값 확인
- [ ] 1-2: SESSIONS 값 확인
- [ ] 1-3: USER 역할 확인
- [ ] 1-4: PROMPT_TEMPLATE 카테고리 확인
- [ ] 1-5: 테이블별 레코드 수

#### PART 2: 상재님 쿼리 (10개)
- [ ] Type 1: Single-table
- [ ] Type 2: Multi-way join
- [ ] Type 3: Aggregation + GROUP BY
- [ ] Type 4: Subquery
- [ ] Type 5: EXISTS
- [ ] Type 6: IN predicates
- [ ] Type 7: Inline view
- [ ] Type 8: Multi-way join + ORDER BY
- [ ] Type 9: Aggregation + GROUP BY + ORDER BY
- [ ] Type 10: MINUS

#### PART 3: 영진님 쿼리 (10개)
- [ ] Type 1: Single-table
- [ ] Type 2: Multi-way join
- [ ] Type 3: Aggregation + GROUP BY
- [ ] Type 4: Subquery
- [ ] Type 5: EXISTS
- [ ] Type 6: IN predicates
- [ ] Type 7: Inline view
- [ ] Type 8: Multi-way join + ORDER BY
- [ ] Type 9: Aggregation + GROUP BY + ORDER BY
- [ ] Type 10: UNION

#### PART 4: 무결성 검증 (13개)
- [ ] 4-1: USER 고아 레코드
- [ ] 4-2: PROJECT 고아 레코드
- [ ] 4-3: MODEL_CONFIG 고아 레코드
- [ ] 4-4: DEPLOYMENTS 고아 레코드
- [ ] 4-5: SESSION_LOGS 고아 레코드
- [ ] 4-6: NULL 값 체크
- [ ] 4-7: 이메일 중복 체크
- [ ] 4-8: 관리자 중복 체크
- [ ] 4-9: is_active 범위
- [ ] 4-10: temperature 범위
- [ ] 4-11: top_p 범위
- [ ] 4-12: SESSIONS 시간 제약
- [ ] 4-13: SESSION_LOGS 시간 제약

#### PART 5: 통계 요약 (5개)
- [ ] 5-1: 부서별 통계
- [ ] 5-2: 모델별 통계
- [ ] 5-3: 사용자 활동 통계
- [ ] 5-4: 배포 환경별 통계
- [ ] 5-5: 템플릿 카테고리별 통계

---

## 📝 에러 기록 템플릿

### 에러 발생 시 기록 형식
```
[에러 번호] [단계] [파일명]
- 에러 코드: ORA-XXXXX
- 에러 메시지: ...
- 발생 위치: Line XXX
- 원인 분석: ...
- 수정 방안: ...
- 수정 완료: [ ] / [X]
```

---

## 🎯 예상 이슈 및 대응

### 1. 순환참조 문제
**예상**: DEPARTMENT ↔ USER
**대응**: ALTER TABLE로 나중에 FK 추가 (이미 0_create_table.sql에 반영됨)

### 2. FK 제약조건 위반
**예상**: INSERT 순서 문제
**대응**: 1→2→3→...→10 순서대로 실행

### 3. 데이터 값 불일치
**예상**: 영어/한글 혼용
**대응**: PART 1 결과 확인 후 쿼리 재수정

### 4. 대용량 데이터 처리
**예상**: SESSION_LOGS 4,860줄 처리 시간
**대응**: 배치 커밋 또는 COMMIT 주기 조정

### 5. UNIQUE 제약조건 위반
**예상**: 이메일, 관리자 중복
**대응**: 데이터 수정 또는 제약조건 재검토

---

## ⏱️ 예상 소요 시간

| 단계 | 예상 시간 | 실제 시간 | 상태 |
|------|----------|----------|------|
| Phase 1: 환경 준비 | 5분 | - | ⏳ |
| Phase 2: 테이블 생성 | 5분 | - | ⏳ |
| Phase 3: 데이터 삽입 | 10분 | - | ⏳ |
| Phase 4: 테스트 실행 | 10분 | - | ⏳ |
| Phase 5: 에러 수정 | 10분 | - | ⏳ |
| Phase 6: 보고서 작성 | 5분 | - | ⏳ |
| **총계** | **45분** | - | ⏳ |

---

작성일: 2025-10-19
작성자: Claude Code
