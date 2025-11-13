# 데이터베이스 테스트 실행 가이드

## 🚀 빠른 시작

### 방법 1: 자동 실행 (권장)

```bash
# Oracle 접속
sqlplus llm_admin/comp322@pdb1

# 전체 자동 실행
@run_all.sql
```

**결과**: `run_all_output.log` 파일에 모든 실행 결과 저장됨

---

### 방법 2: 단계별 수동 실행

```bash
# Oracle 접속
sqlplus llm_admin/comp322@pdb1

# 1. 테이블 생성
@0_create_table.sql

# 2. 데이터 삽입 (순서대로)
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

# 3. 종합 테스트
@test_all_queries.sql
```

---

## 📁 파일 구조

```
database-project/
├── 📝 실행 스크립트
│   ├── run_all.sql                  # ✨ 전체 자동 실행
│   ├── 0_create_table.sql           # 테이블 생성
│   ├── 1_insert_department.sql      # 부서 데이터
│   ├── 2_insert_user.sql            # 사용자 데이터
│   ├── 3_insert_project.sql         # 프로젝트 데이터
│   ├── 4_insert_model.sql           # 모델 데이터
│   ├── 5_insert_model_config.sql    # 모델 설정
│   ├── 6_insert_dataset.sql         # 데이터셋
│   ├── 7_insert_deployments.sql     # 배포 환경
│   ├── 8_insert_prompt_template.sql # 프롬프트 템플릿
│   ├── 9_insert_sessions.sql        # 세션
│   └── 10_insert_session_logs.sql   # 세션 로그
│
├── 🧪 테스트 파일
│   └── test_all_queries.sql         # ✨ 종합 테스트 (43개 쿼리)
│
└── 📚 문서
    ├── README_EXECUTION.md          # ✨ 실행 가이드 (이 파일)
    ├── TEST_SUMMARY.md              # 테스트 요약
    ├── EXECUTION_PLAN.md            # 실행 계획
    ├── ERROR_LOG.md                 # 에러 로그
    ├── 1.txt                        # 상재님 쿼리 원본
    ├── 2.txt                        # 영진님 쿼리 원본
    └── 3.txt                        # CREATE TABLE 스키마
```

---

## ✅ 실행 전 체크리스트

- [ ] Oracle Database 실행 중
- [ ] PDB1 열려 있음
- [ ] llm_admin 사용자 생성됨 (비밀번호: comp322)
- [ ] 모든 SQL 파일이 같은 디렉토리에 있음
- [ ] 충분한 권한 (ALL PRIVILEGES)

---

## 📊 실행 후 확인 사항

### 1. 테이블 생성 확인
```sql
SELECT table_name FROM user_tables ORDER BY table_name;
```

**예상 결과**: 10개 테이블
- DATASET
- DEPARTMENT
- DEPLOYMENTS
- MODEL
- MODEL_CONFIG
- PROMPT_TEMPLATE
- PROJECT
- SESSION_LOGS
- SESSIONS
- USER

### 2. 데이터 삽입 확인
```sql
SELECT 'DEPARTMENT' AS table_name, COUNT(*) AS count FROM DEPARTMENT
UNION ALL SELECT 'USER', COUNT(*) FROM "USER"
UNION ALL SELECT 'PROJECT', COUNT(*) FROM PROJECT
UNION ALL SELECT 'MODEL', COUNT(*) FROM MODEL
UNION ALL SELECT 'MODEL_CONFIG', COUNT(*) FROM MODEL_CONFIG
UNION ALL SELECT 'DATASET', COUNT(*) FROM DATASET
UNION ALL SELECT 'DEPLOYMENTS', COUNT(*) FROM DEPLOYMENTS
UNION ALL SELECT 'PROMPT_TEMPLATE', COUNT(*) FROM PROMPT_TEMPLATE
UNION ALL SELECT 'SESSIONS', COUNT(*) FROM SESSIONS
UNION ALL SELECT 'SESSION_LOGS', COUNT(*) FROM SESSION_LOGS
ORDER BY table_name;
```

**예상 결과**:
| TABLE_NAME | COUNT |
|------------|-------|
| DATASET | 30 |
| DEPARTMENT | 10 |
| DEPLOYMENTS | 44 |
| MODEL | 22 |
| MODEL_CONFIG | 132 |
| PROMPT_TEMPLATE | 120 |
| PROJECT | 100 |
| SESSION_LOGS | ~4,860 |
| SESSIONS | 650 |
| USER | 150 |

### 3. 테스트 결과 확인
`run_all_output.log` 파일을 열어서 다음을 확인:
- ✅ PART 1: 데이터 값 검증 (5개 쿼리)
- ✅ PART 2: 상재님 쿼리 (10개 Type 1-10)
- ✅ PART 3: 영진님 쿼리 (10개 Type 1-10)
- ✅ PART 4: 무결성 검증 (13개 - 모두 0개 행 반환이 정상)
- ✅ PART 5: 통계 요약 (5개)

---

## ⚠️ 에러 발생 시

### ORA-00942: 테이블 또는 뷰가 존재하지 않습니다
**원인**: 테이블이 생성되지 않음
**해결**: `0_create_table.sql`을 먼저 실행

### ORA-02291: 무결성 제약조건 위반 (부모 키가 없음)
**원인**: INSERT 순서 문제
**해결**: 1→2→3→...→10 순서대로 실행

### ORA-00001: 무결성 제약 조건 위반 (중복 값)
**원인**: 데이터가 이미 삽입됨
**해결**:
```sql
-- 모든 테이블 삭제 후 재실행
BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
    END LOOP;
END;
/
```

### ORA-12541: TNS: 리스너가 없습니다
**원인**: Oracle 서버가 실행 중이지 않음
**해결**: Oracle Database 시작

---

## 🔍 트러블슈팅

### 1. 로그 파일 확인
```bash
# 에러만 필터링
grep -i "ORA-" run_all_output.log

# 성공 여부 확인
grep -i "complete\|완료" run_all_output.log
```

### 2. 수동으로 테이블 확인
```sql
-- 각 테이블의 첫 5개 행 확인
SELECT * FROM DEPARTMENT WHERE ROWNUM <= 5;
SELECT * FROM "USER" WHERE ROWNUM <= 5;
SELECT * FROM PROJECT WHERE ROWNUM <= 5;
-- ...
```

### 3. 제약조건 확인
```sql
-- 모든 제약조건 확인
SELECT constraint_name, constraint_type, table_name
FROM user_constraints
ORDER BY table_name, constraint_type;
```

---

## 📝 추가 유용한 쿼리

### 테이블 크기 확인
```sql
SELECT segment_name AS table_name,
       ROUND(bytes/1024/1024, 2) AS size_mb
FROM user_segments
WHERE segment_type = 'TABLE'
ORDER BY bytes DESC;
```

### 인덱스 확인
```sql
SELECT index_name, table_name, uniqueness
FROM user_indexes
ORDER BY table_name, index_name;
```

### FK 관계 확인
```sql
SELECT a.table_name AS child_table,
       a.constraint_name,
       a.r_constraint_name,
       b.table_name AS parent_table
FROM user_constraints a,
     user_constraints b
WHERE a.constraint_type = 'R'
  AND a.r_constraint_name = b.constraint_name
ORDER BY a.table_name;
```

---

## 🎯 성공 기준

### ✅ 모든 테스트 통과 조건
1. **테이블 생성**: 10개 테이블 + 1개 시퀀스
2. **데이터 삽입**: 총 6,118개 레코드
3. **쿼리 테스트**: 43개 쿼리 모두 에러 없이 실행
4. **무결성 검증**: PART 4의 13개 쿼리가 모두 0개 행 반환
5. **통계 요약**: PART 5의 5개 쿼리가 정상 결과 반환

---

## 📞 문제 해결 순서

1. `ERROR_LOG.md` 파일 확인
2. `run_all_output.log` 파일에서 에러 메시지 검색
3. 해당 SQL 파일 직접 확인
4. 필요시 수동으로 단계별 실행
5. 그래도 안되면 전체 삭제 후 재실행

---

**작성일**: 2025-10-19
**작성자**: Claude Code
**버전**: 1.0

**다음 단계**: `run_all.sql` 실행 후 결과를 `ERROR_LOG.md`에 기록
