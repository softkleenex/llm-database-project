-- ============================================
-- 전체 테스트 자동 실행 스크립트
-- ============================================
-- 사용법:
-- sqlplus llm_admin/comp322@pdb1 @run_all.sql
-- ============================================

SET SERVEROUTPUT ON;
SET ECHO ON;
SET FEEDBACK ON;
SET LINESIZE 200;
SET PAGESIZE 100;

SPOOL run_all_output.log;

PROMPT ========================================
PROMPT 시작 시간:
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS start_time FROM DUAL;
PROMPT ========================================

-- ============================================
-- Phase 1: 기존 객체 삭제 (있다면)
-- ============================================
PROMPT ========================================
PROMPT Phase 1: 기존 객체 삭제
PROMPT ========================================

BEGIN
    FOR t IN (SELECT table_name FROM user_tables) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS';
        DBMS_OUTPUT.PUT_LINE('Dropped table: ' || t.table_name);
    END LOOP;
END;
/

BEGIN
    FOR s IN (SELECT sequence_name FROM user_sequences) LOOP
        EXECUTE IMMEDIATE 'DROP SEQUENCE ' || s.sequence_name;
        DBMS_OUTPUT.PUT_LINE('Dropped sequence: ' || s.sequence_name);
    END LOOP;
END;
/

-- ============================================
-- Phase 2: 테이블 생성
-- ============================================
PROMPT ========================================
PROMPT Phase 2: 테이블 생성
PROMPT ========================================

@@0_create_table.sql

-- 생성된 테이블 확인
PROMPT [확인] 생성된 테이블 목록:
SELECT table_name FROM user_tables ORDER BY table_name;

PROMPT [확인] 생성된 시퀀스 목록:
SELECT sequence_name FROM user_sequences ORDER BY sequence_name;

-- ============================================
-- Phase 3: 데이터 삽입
-- ============================================
PROMPT ========================================
PROMPT Phase 3: 데이터 삽입
PROMPT ========================================

PROMPT [1/10] DEPARTMENT 삽입...
@@1_insert_department.sql
SELECT COUNT(*) AS dept_count FROM DEPARTMENT;

PROMPT [2/10] USER 삽입...
@@2_insert_user.sql
SELECT COUNT(*) AS user_count FROM "USER";

PROMPT [3/10] PROJECT 삽입...
@@3_insert_project.sql
SELECT COUNT(*) AS project_count FROM PROJECT;

PROMPT [4/10] MODEL 삽입...
@@4_insert_model.sql
SELECT COUNT(*) AS model_count FROM MODEL;

PROMPT [5/10] MODEL_CONFIG 삽입...
@@5_insert_model_config.sql
SELECT COUNT(*) AS config_count FROM MODEL_CONFIG;

PROMPT [6/10] DATASET 삽입...
@@6_insert_dataset.sql
SELECT COUNT(*) AS dataset_count FROM DATASET;

PROMPT [7/10] DEPLOYMENTS 삽입...
@@7_insert_deployments.sql
SELECT COUNT(*) AS deployment_count FROM DEPLOYMENTS;

PROMPT [8/10] PROMPT_TEMPLATE 삽입...
@@8_insert_prompt_template.sql
SELECT COUNT(*) AS template_count FROM PROMPT_TEMPLATE;

PROMPT [9/10] SESSIONS 삽입...
@@9_insert_sessions.sql
SELECT COUNT(*) AS session_count FROM SESSIONS;

PROMPT [10/10] SESSION_LOGS 삽입...
@@10_insert_session_logs.sql
SELECT COUNT(*) AS log_count FROM SESSION_LOGS;

-- ============================================
-- Phase 4: 종합 테스트 실행
-- ============================================
PROMPT ========================================
PROMPT Phase 4: 종합 테스트 실행
PROMPT ========================================

@@test_all_queries.sql

-- ============================================
-- 완료
-- ============================================
PROMPT ========================================
PROMPT 종료 시간:
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS end_time FROM DUAL;
PROMPT ========================================

SPOOL OFF;

PROMPT
PROMPT ✅ 모든 작업이 완료되었습니다!
PROMPT 📄 결과 로그: run_all_output.log
PROMPT
