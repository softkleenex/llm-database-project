# 종합 쿼리 테스트 요약서

## 📋 개요

- **파일명**: `test_all_queries.sql`
- **작성일**: 2025-10-19
- **목적**: Phase 3 모든 쿼리 검증 및 데이터 무결성 테스트
- **실행 환경**: Oracle Database (llm_admin 계정)

## 📊 테스트 구성

### PART 1: 데이터 값 검증 (5개 쿼리)
실제 데이터베이스에 삽입된 값들을 확인하여 쿼리 조건 검증

| 번호 | 테스트 항목 | 목적 |
|------|------------|------|
| 1-1 | DEPLOYMENTS 환경/상태 값 | 배포 환경 및 상태 값 확인 |
| 1-2 | SESSIONS 상태 값 | 세션 상태 및 타입 확인 |
| 1-3 | USER 역할 값 | 사용자 역할 값 확인 |
| 1-4 | PROMPT_TEMPLATE 카테고리 값 | 템플릿 카테고리 확인 |
| 1-5 | 테이블별 레코드 수 | 전체 데이터 삽입 확인 |

### PART 2: 상재님 쿼리 테스트 (10개 쿼리)
**담당 엔티티**: MODEL, MODEL_CONFIG, DEPLOYMENTS, DATASET, PROMPT_TEMPLATE

| Type | 쿼리 유형 | 설명 | 수정사항 |
|------|----------|------|----------|
| 1 | Single-table (Selection + Projection) | 프로덕션 환경 활성 배포 조회 | ✅ 'production'→'프로덕션', 'active'→'활성' |
| 2 | Multi-way join (WHERE) | 모델-데이터셋-배포 매핑 | - |
| 3 | Aggregation + JOIN + GROUP BY | 모델별 설정/배포 개수 | - |
| 4 | Subquery | 평균 GPU보다 많은 배포 | - |
| 5 | EXISTS Subquery | 배포에 사용된 데이터셋 | - |
| 6 | IN predicates | 특정 카테고리 템플릿 조회 | - |
| 7 | Inline view | 모델별 평균 temperature | - |
| 8 | Multi-way join + ORDER BY | 모델-설정-배포 정렬 | - |
| 9 | Aggregation + GROUP BY + ORDER BY | 환경별 통계 | - |
| 10 | SET operation (MINUS) | 미배포 모델 조회 | - |

### PART 3: 영진님 쿼리 테스트 (10개 쿼리)
**담당 엔티티**: DEPARTMENT, USER, PROJECT, SESSIONS, SESSION_LOGS

| Type | 쿼리 유형 | 설명 | 수정사항 |
|------|----------|------|----------|
| 1 | Single-table (Selection + Projection) | Team Leader 조회 | - |
| 2 | Multi-way join (WHERE) | 프로젝트-유저-부서 매핑 | - |
| 3 | Aggregation + JOIN + GROUP BY | 부서별 프로젝트 수 | - |
| 4 | Subquery | AI연구팀 소속 유저 | - |
| 5 | EXISTS Subquery | 진행중 세션 보유 유저 | ✅ 'ACTIVE'→'진행중' |
| 6 | IN predicates | 관리자 있는 부서 프로젝트 | - |
| 7 | Inline view | 세션 5개 이상 유저 | - |
| 8 | Multi-way join + ORDER BY | 토큰 사용량 순 조회 | - |
| 9 | Aggregation + GROUP BY + ORDER BY | 유저별 세션 수 | - |
| 10 | SET operation (UNION) | Data Scientist + 관리자 | ✅ 'MData Scientist'→'Data Scientist' |

### PART 4: 데이터 무결성 검증 (13개 쿼리)
데이터베이스 제약조건 및 무결성 확인

| 번호 | 검증 항목 | 목적 |
|------|----------|------|
| 4-1 | USER 고아 레코드 | 존재하지 않는 department_id 참조 확인 |
| 4-2 | PROJECT 고아 레코드 | 존재하지 않는 FK 참조 확인 |
| 4-3 | MODEL_CONFIG 고아 레코드 | 존재하지 않는 model_id 참조 확인 |
| 4-4 | DEPLOYMENTS 고아 레코드 | 존재하지 않는 model_id 참조 확인 |
| 4-5 | SESSION_LOGS 고아 레코드 | 존재하지 않는 FK 참조 확인 |
| 4-6 | NULL 값 체크 | NOT NULL 제약 검증 |
| 4-7 | 이메일 중복 체크 | UNIQUE 제약 검증 |
| 4-8 | 부서 관리자 중복 체크 | UNIQUE 제약 검증 |
| 4-9 | is_active 값 범위 | CHECK 제약 검증 ('Y', 'N') |
| 4-10 | temperature 값 범위 | CHECK 제약 검증 (0~2) |
| 4-11 | top_p 값 범위 | CHECK 제약 검증 (0~1) |
| 4-12 | SESSIONS 시간 제약 | end_time >= start_time 검증 |
| 4-13 | SESSION_LOGS 시간 제약 | response_time >= request_time 검증 |

### PART 5: 통계 요약 (5개 쿼리)
전체 시스템 통계 및 요약 정보

| 번호 | 통계 항목 | 내용 |
|------|----------|------|
| 5-1 | 부서별 통계 | 직원 수, 프로젝트 수, 세션 수 |
| 5-2 | 모델별 통계 | 설정 수, 배포 수, 세션 로그 수 |
| 5-3 | 사용자 활동 통계 | 상위 10명 활동량 (프로젝트, 세션, 템플릿) |
| 5-4 | 배포 환경별 통계 | GPU 사용량, 모델 수 |
| 5-5 | 템플릿 카테고리별 통계 | 평균 사용 횟수 |

## 🔧 수정 사항 상세

### 1. 상재님 쿼리 수정
#### Type 1: 환경 및 상태 값 한글 변환
```sql
-- 수정 전
WHERE environment = 'production' AND status = 'active'

-- 수정 후
WHERE environment = '프로덕션' AND status = '활성'
```

**이유**: 실제 데이터가 한글로 삽입됨
- environment: '프로덕션', '개발', '테스트'
- status: '활성', '비활성', '유지보수'

### 2. 영진님 쿼리 수정
#### Type 5: 세션 상태 값 수정
```sql
-- 수정 전
WHERE S.status = 'ACTIVE'

-- 수정 후
WHERE S.status = '진행중'
```

**이유**: 실제 데이터의 status 값이 '진행중', '완료'

#### Type 10: 역할명 오타 수정
```sql
-- 수정 전
SELECT user_id FROM "USER" WHERE role = 'MData Scientist'

-- 수정 후
SELECT user_id FROM "USER" WHERE role = 'Data Scientist'
```

**이유**: 'MData Scientist'는 오타

## 📝 실행 방법

### 1. 데이터베이스 접속
```bash
# PDB1에 sysdba로 접속
sqlplus sys/password@pdb1 as sysdba

# llm_admin 사용자 생성 (이미 생성되어 있다면 생략)
CREATE USER llm_admin IDENTIFIED BY comp322;
GRANT ALL PRIVILEGES TO llm_admin;

# llm_admin으로 재접속
CONN llm_admin/comp322@pdb1
```

### 2. 테이블 생성 및 데이터 삽입
```bash
# 순서대로 실행
@0_create_table.sql
@1_insert_department.sql
@2_insert_user.sql
@3_insert_project.sql
@4_insert_model.sql
@5_insert_model_config.sql
@6_insert_dataset.sql
@7_insert_deployments.sql
@8_insert_prompt_template.sql
@9_insert_sessions.sql
@10_insert_session_logs.sql
```

### 3. 테스트 실행
```bash
# 종합 테스트 실행
@test_all_queries.sql
```

## ✅ 예상 결과

### 성공 케이스
- **PART 1**: 모든 DISTINCT 값들이 정상 출력
- **PART 2 & 3**: 각 쿼리가 에러 없이 실행되고 적절한 결과 반환
- **PART 4**: 모든 무결성 검증 쿼리가 0개 행 반환 (문제 없음)
- **PART 5**: 통계 정보가 정상 출력

### 실패 케이스 대응
1. **FK 제약조건 위반**: INSERT 순서 확인
2. **데이터 값 불일치**: PART 1 결과를 보고 쿼리 조건 재수정
3. **고아 레코드 발견**: 데이터 삽입 스크립트 재점검

## 📊 테스트 커버리지

### 쿼리 타입 커버리지
- ✅ Single-table query (2개)
- ✅ Multi-way join (4개)
- ✅ Aggregation + GROUP BY (4개)
- ✅ Subquery (2개)
- ✅ EXISTS Subquery (2개)
- ✅ IN predicates (2개)
- ✅ Inline view (2개)
- ✅ ORDER BY (4개)
- ✅ SET operation (2개 - MINUS, UNION)

### 엔티티 커버리지
| 엔티티 | 담당자 | 테스트 쿼리 수 |
|--------|--------|---------------|
| DEPARTMENT | 영진 | 6개 |
| USER | 영진 | 8개 |
| PROJECT | 영진 | 5개 |
| SESSIONS | 영진 | 6개 |
| SESSION_LOGS | 영진 | 4개 |
| MODEL | 상재 | 7개 |
| MODEL_CONFIG | 상재 | 6개 |
| DEPLOYMENTS | 상재 | 8개 |
| DATASET | 상재 | 3개 |
| PROMPT_TEMPLATE | 상재 | 3개 |

## 🎯 검증 포인트

### 1. 기능적 정확성
- [ ] 모든 10개 Query Type이 정상 실행
- [ ] 결과가 논리적으로 타당한지 확인
- [ ] WHERE 조건이 실제 데이터와 일치

### 2. 데이터 무결성
- [ ] FK 제약조건이 모두 유효
- [ ] UNIQUE 제약조건 위반 없음
- [ ] CHECK 제약조건 범위 준수
- [ ] NULL 제약조건 준수

### 3. 성능
- [ ] 대용량 테이블(SESSION_LOGS) 쿼리 성능 확인
- [ ] JOIN 성능 확인
- [ ] 인덱스 활용 확인 (옵션)

## 📌 주의사항

1. **데이터 값 의존성**
   - 실제 데이터 값이 변경되면 쿼리 조건도 수정 필요
   - PART 1에서 먼저 값 확인 후 진행

2. **순환참조 해결**
   - DEPARTMENT ↔ USER FK는 ALTER TABLE로 나중에 추가됨
   - 데이터 삽입 순서가 중요

3. **대용량 데이터**
   - SESSION_LOGS는 약 4,860줄로 가장 큼
   - 테스트 시 성능 저하 가능

4. **언어 일관성**
   - 일부 컬럼은 한글 (environment, status, task_category)
   - 일부 컬럼은 영어 (role)
   - 쿼리 작성 시 주의 필요

## 🔍 추가 테스트 아이디어

### 성능 테스트 (옵션)
```sql
-- 실행 계획 확인
EXPLAIN PLAN FOR
SELECT ... ;

SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY);

-- 통계 정보 수집
EXEC DBMS_STATS.GATHER_TABLE_STATS('LLM_ADMIN', 'SESSION_LOGS');
```

### 트랜잭션 테스트 (옵션)
```sql
-- CASCADE DELETE 테스트
DELETE FROM SESSIONS WHERE session_id = 'Ssn0001';
-- SESSION_LOGS에서도 자동 삭제되는지 확인
```

## 📚 참고 자료

- **Phase 1**: ER Diagram 설계
- **Phase 2**: Relational Schema 매핑
- **Phase 3**: 쿼리 작성 및 테스트 (현재)
- **데이터 삽입 스크립트**: 0-10번 SQL 파일
- **원본 요구사항**: 1.txt, 2.txt, 3.txt

---

**작성자**: Claude Code
**작성일**: 2025-10-19
**버전**: 1.0
