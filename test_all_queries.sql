-- ============================================
-- 종합 쿼리 테스트 파일
-- ============================================
-- 작성일: 2025-10-19
-- 목적: Phase 3 모든 쿼리 검증 및 테스트
-- 실행 환경: Oracle Database (llm_admin 계정)
-- ============================================

SET SERVEROUTPUT ON;
SET LINESIZE 200;
SET PAGESIZE 100;

-- ============================================
-- PART 1: 데이터 값 검증 (실제 데이터 확인)
-- ============================================

PROMPT ========================================
PROMPT PART 1: 데이터 값 검증
PROMPT ========================================

-- 1-1. DEPLOYMENTS 환경 및 상태 확인
PROMPT [1-1] DEPLOYMENTS 환경 및 상태값 확인
SELECT DISTINCT environment, status
FROM DEPLOYMENTS
ORDER BY environment, status;

-- 1-2. SESSIONS 상태 확인
PROMPT [1-2] SESSIONS 상태값 확인
SELECT DISTINCT status, session_type
FROM SESSIONS
ORDER BY status, session_type;

-- 1-3. USER 역할 확인
PROMPT [1-3] USER 역할값 확인
SELECT DISTINCT role
FROM "USER"
ORDER BY role;

-- 1-4. PROMPT_TEMPLATE 카테고리 확인
PROMPT [1-4] PROMPT_TEMPLATE 카테고리값 확인
SELECT DISTINCT task_category
FROM PROMPT_TEMPLATE
ORDER BY task_category;

-- 1-5. 테이블별 레코드 수 확인
PROMPT [1-5] 테이블별 레코드 수
SELECT 'DEPARTMENT' AS table_name, COUNT(*) AS record_count FROM DEPARTMENT
UNION ALL
SELECT 'USER', COUNT(*) FROM "USER"
UNION ALL
SELECT 'PROJECT', COUNT(*) FROM PROJECT
UNION ALL
SELECT 'MODEL', COUNT(*) FROM MODEL
UNION ALL
SELECT 'MODEL_CONFIG', COUNT(*) FROM MODEL_CONFIG
UNION ALL
SELECT 'DATASET', COUNT(*) FROM DATASET
UNION ALL
SELECT 'DEPLOYMENTS', COUNT(*) FROM DEPLOYMENTS
UNION ALL
SELECT 'SESSIONS', COUNT(*) FROM SESSIONS
UNION ALL
SELECT 'SESSION_LOGS', COUNT(*) FROM SESSION_LOGS
UNION ALL
SELECT 'PROMPT_TEMPLATE', COUNT(*) FROM PROMPT_TEMPLATE
ORDER BY 1;

-- ============================================
-- PART 2: 상재님 쿼리 테스트 (Type 1-10)
-- ============================================
-- 담당 엔티티: MODEL, MODEL_CONFIG, DEPLOYMENTS, DATASET, PROMPT_TEMPLATE
-- ============================================

PROMPT ========================================
PROMPT PART 2: 상재님 쿼리 테스트
PROMPT ========================================

-- ============================================
-- Type 1: Single-table query (Selection + Projection)
-- ============================================
PROMPT [Type 1] 활성 상태인 프로덕션 배포 환경 조회
-- 수정: 'production' → '프로덕션', 'active' → '활성'

SELECT server_name, gpu_count, environment, status
FROM DEPLOYMENTS
WHERE environment = '프로덕션'
  AND status = '활성';

-- ============================================
-- Type 2: Multi-way join with join predicates in WHERE
-- ============================================
PROMPT [Type 2] 모델-데이터셋-배포 환경 매핑 관계
SELECT
    M.model_name AS model_name,
    M.model_type AS model_type,
    D.server_name AS server_name,
    D.environment AS environment,
    DS.learning_type AS dataset_learning_type,
    DS.s3_path AS dataset_path
FROM MODEL M, DEPLOYMENTS D, DATASET DS
WHERE M.model_id = D.model_id
  AND D.dataset_id = DS.dataset_id;

-- ============================================
-- Type 3: Aggregation + multi-way join + GROUP BY
-- ============================================
PROMPT [Type 3] 모델별 설정 개수 및 배포 개수 집계
SELECT
    M.model_name,
    M.model_type,
    COUNT(DISTINCT MC.config_id) AS config_count,
    COUNT(DISTINCT D.deployment_id) AS deployment_count
FROM MODEL M, MODEL_CONFIG MC, DEPLOYMENTS D
WHERE M.model_id = MC.model_id
  AND M.model_id = D.model_id
GROUP BY M.model_name, M.model_type;

-- ============================================
-- Type 4: Subquery
-- ============================================
PROMPT [Type 4] 평균보다 많은 GPU를 사용하는 배포 환경
SELECT
    deployment_id,
    server_name,
    gpu_count,
    environment
FROM DEPLOYMENTS
WHERE gpu_count > (
    SELECT AVG(gpu_count)
    FROM DEPLOYMENTS
);

-- ============================================
-- Type 5: EXISTS를 포함하는 Subquery
-- ============================================
PROMPT [Type 5] 실제로 배포에 사용된 데이터셋
SELECT
    dataset_id,
    learning_type,
    description,
    created_at
FROM DATASET DS
WHERE EXISTS (
    SELECT 1
    FROM DEPLOYMENTS D
    WHERE D.dataset_id = DS.dataset_id
);

-- ============================================
-- Type 6: Selection + Projection + IN predicates
-- ============================================
PROMPT [Type 6] 특정 카테고리 프롬프트 템플릿 조회
SELECT
    template_name,
    task_category,
    version,
    usage_count
FROM PROMPT_TEMPLATE
WHERE task_category IN ('요약', '번역', '코딩')
ORDER BY usage_count DESC;

-- ============================================
-- Type 7: In-line view를 활용한 Query
-- ============================================
PROMPT [Type 7] 모델별 평균 temperature와 배포 개수
SELECT
    M.model_name,
    AVG_CONFIG.avg_temperature,
    AVG_CONFIG.config_count,
    DEPLOY_COUNT.deployment_count
FROM MODEL M,
    (SELECT
        model_id,
        AVG(temperature) AS avg_temperature,
        COUNT(*) AS config_count
     FROM MODEL_CONFIG
     GROUP BY model_id) AVG_CONFIG,
    (SELECT
        model_id,
        COUNT(*) AS deployment_count
     FROM DEPLOYMENTS
     GROUP BY model_id) DEPLOY_COUNT
WHERE M.model_id = AVG_CONFIG.model_id
  AND M.model_id = DEPLOY_COUNT.model_id;

-- ============================================
-- Type 8: Multi-way join + ORDER BY
-- ============================================
PROMPT [Type 8] 모델-설정-배포 관계 (GPU 수 기준 정렬)
SELECT
    M.model_name,
    MC.config_name,
    MC.max_tokens,
    MC.temperature,
    D.server_name,
    D.gpu_count,
    D.environment
FROM MODEL M, MODEL_CONFIG MC, DEPLOYMENTS D
WHERE M.model_id = MC.model_id
  AND M.model_id = D.model_id
ORDER BY D.gpu_count DESC, M.model_name ASC;

-- ============================================
-- Type 9: Aggregation + multi-way join + GROUP BY + ORDER BY
-- ============================================
PROMPT [Type 9] 환경별 평균 GPU 수 및 배포 개수
SELECT
    D.environment,
    COUNT(DISTINCT D.deployment_id) AS deployment_count,
    AVG(D.gpu_count) AS avg_gpu_count,
    COUNT(DISTINCT M.model_id) AS unique_models
FROM DEPLOYMENTS D, MODEL M
WHERE D.model_id = M.model_id
GROUP BY D.environment
ORDER BY avg_gpu_count DESC;

-- ============================================
-- Type 10: SET operation (MINUS)
-- ============================================
PROMPT [Type 10] 아직 배포되지 않은 모델
SELECT
    model_id,
    model_name,
    model_type
FROM MODEL
MINUS
SELECT
    M.model_id,
    M.model_name,
    M.model_type
FROM MODEL M, DEPLOYMENTS D
WHERE M.model_id = D.model_id;

-- ============================================
-- PART 3: 영진님 쿼리 테스트 (Type 1-10)
-- ============================================
-- 담당 엔티티: DEPARTMENT, USER, PROJECT, SESSIONS, SESSION_LOGS
-- ============================================

PROMPT ========================================
PROMPT PART 3: 영진님 쿼리 테스트
PROMPT ========================================

-- ============================================
-- Type 1: Single-table query (Selection + Projection)
-- ============================================
PROMPT [Type 1] Team Leader 역할 유저 조회
SELECT user_id, user_name, user_email
FROM "USER"
WHERE role = 'Team Leader';

-- ============================================
-- Type 2: Multi-way join with join predicates in WHERE
-- ============================================
PROMPT [Type 2] 프로젝트 생성자와 소속 부서 정보
SELECT U.user_name, D.department_name, P.project_name
FROM "USER" U, DEPARTMENT D, PROJECT P
WHERE U.department_id = D.department_id
  AND P.creator_user_id = U.user_id;

-- ============================================
-- Type 3: Aggregation + multi-way join + GROUP BY
-- ============================================
PROMPT [Type 3] 부서별 프로젝트 수 집계
SELECT D.department_name, COUNT(P.project_id) AS project_count
FROM DEPARTMENT D, PROJECT P
WHERE D.department_id = P.department_id
GROUP BY D.department_name;

-- ============================================
-- Type 4: Subquery
-- ============================================
PROMPT [Type 4] AI연구팀 소속 유저
SELECT user_id, user_name
FROM "USER"
WHERE department_id = (
    SELECT department_id
    FROM DEPARTMENT
    WHERE department_name = 'AI연구팀'
);

-- ============================================
-- Type 5: Subquery with EXISTS
-- ============================================
PROMPT [Type 5] 진행중인 세션을 보유한 유저
-- 수정: S.status = 'ACTIVE' → S.status = '진행중'

SELECT U.user_id, U.user_name
FROM "USER" U
WHERE EXISTS (
    SELECT 1
    FROM SESSIONS S
    WHERE S.user_id = U.user_id
      AND S.status = '진행중'
);

-- ============================================
-- Type 6: Selection + Projection + IN predicates
-- ============================================
PROMPT [Type 6] 관리자가 지정된 부서의 프로젝트
SELECT project_id, project_name
FROM PROJECT
WHERE department_id IN (
    SELECT department_id
    FROM DEPARTMENT
    WHERE manager_user_id IS NOT NULL
);

-- ============================================
-- Type 7: In-line view 활용한 Query
-- ============================================
PROMPT [Type 7] 세션 5개 이상 보유한 유저
SELECT U.user_id, U.user_name, S.session_count
FROM (
    SELECT user_id, COUNT(*) AS session_count
    FROM SESSIONS
    GROUP BY user_id
) S, "USER" U
WHERE S.user_id = U.user_id
  AND session_count >= 5;

-- ============================================
-- Type 8: Multi-way join + ORDER BY
-- ============================================
PROMPT [Type 8] 세션 로그 토큰 사용량 순 조회
SELECT SL.session_id, SL.log_sequence, U.user_name, SL.token_used
FROM SESSION_LOGS SL, SESSIONS S, "USER" U
WHERE SL.session_id = S.session_id
  AND S.user_id = U.user_id
ORDER BY SL.token_used DESC;

-- ============================================
-- Type 9: Aggregation + multi-way join + GROUP BY + ORDER BY
-- ============================================
PROMPT [Type 9] 유저별 세션 수 집계 및 정렬
SELECT U.user_name, COUNT(S.session_id) AS total_sessions
FROM "USER" U, SESSIONS S
WHERE U.user_id = S.user_id
GROUP BY U.user_name
ORDER BY total_sessions DESC;

-- ============================================
-- Type 10: SET operation (UNION)
-- ============================================
PROMPT [Type 10] Data Scientist 역할 유저와 부서 관리자 통합 조회
-- 수정: role = 'MData Scientist' → role = 'Data Scientist'

SELECT user_id FROM "USER" WHERE role = 'Data Scientist'
UNION
SELECT manager_user_id FROM DEPARTMENT WHERE manager_user_id IS NOT NULL;

-- ============================================
-- PART 4: 데이터 무결성 검증
-- ============================================

PROMPT ========================================
PROMPT PART 4: 데이터 무결성 검증
PROMPT ========================================

-- 4-1. Foreign Key 무결성 체크 (고아 레코드 확인)
PROMPT [4-1] USER 테이블의 고아 레코드 체크 (존재하지 않는 department_id 참조)
SELECT U.user_id, U.user_name, U.department_id
FROM "USER" U
WHERE NOT EXISTS (
    SELECT 1 FROM DEPARTMENT D WHERE D.department_id = U.department_id
);

PROMPT [4-2] PROJECT 테이블의 고아 레코드 체크
SELECT P.project_id, P.project_name, P.creator_user_id, P.department_id
FROM PROJECT P
WHERE NOT EXISTS (
    SELECT 1 FROM "USER" U WHERE U.user_id = P.creator_user_id
)
OR NOT EXISTS (
    SELECT 1 FROM DEPARTMENT D WHERE D.department_id = P.department_id
);

PROMPT [4-3] MODEL_CONFIG 테이블의 고아 레코드 체크
SELECT MC.config_id, MC.model_id
FROM MODEL_CONFIG MC
WHERE NOT EXISTS (
    SELECT 1 FROM MODEL M WHERE M.model_id = MC.model_id
);

PROMPT [4-4] DEPLOYMENTS 테이블의 고아 레코드 체크
SELECT D.deployment_id, D.model_id, D.dataset_id
FROM DEPLOYMENTS D
WHERE NOT EXISTS (
    SELECT 1 FROM MODEL M WHERE M.model_id = D.model_id
);

PROMPT [4-5] SESSION_LOGS 테이블의 고아 레코드 체크
SELECT SL.session_id, SL.log_sequence, SL.deployment_id
FROM SESSION_LOGS SL
WHERE NOT EXISTS (
    SELECT 1 FROM SESSIONS S WHERE S.session_id = SL.session_id
)
OR NOT EXISTS (
    SELECT 1 FROM DEPLOYMENTS D WHERE D.deployment_id = SL.deployment_id
);

-- 4-6. NULL 값 체크 (NOT NULL 제약 검증)
PROMPT [4-6] NULL 값이 있으면 안되는 컬럼 체크
SELECT 'USER.user_name' AS column_name, COUNT(*) AS null_count
FROM "USER" WHERE user_name IS NULL
UNION ALL
SELECT 'PROJECT.project_name', COUNT(*)
FROM PROJECT WHERE project_name IS NULL
UNION ALL
SELECT 'MODEL.model_name', COUNT(*)
FROM MODEL WHERE model_name IS NULL
UNION ALL
SELECT 'DEPLOYMENTS.server_name', COUNT(*)
FROM DEPLOYMENTS WHERE server_name IS NULL;

-- 4-7. 중복 데이터 체크
PROMPT [4-7] 이메일 중복 체크 (UNIQUE 제약 검증)
SELECT user_email, COUNT(*) AS duplicate_count
FROM "USER"
GROUP BY user_email
HAVING COUNT(*) > 1;

PROMPT [4-8] 부서 관리자 중복 체크 (UNIQUE 제약 검증)
SELECT manager_user_id, COUNT(*) AS duplicate_count
FROM DEPARTMENT
WHERE manager_user_id IS NOT NULL
GROUP BY manager_user_id
HAVING COUNT(*) > 1;

-- 4-9. CHECK 제약조건 검증
PROMPT [4-9] USER.is_active 값 범위 체크
SELECT is_active, COUNT(*) AS count
FROM "USER"
GROUP BY is_active
ORDER BY is_active;

PROMPT [4-10] MODEL_CONFIG.temperature 값 범위 체크 (0~2)
SELECT MIN(temperature) AS min_temp, MAX(temperature) AS max_temp,
       AVG(temperature) AS avg_temp
FROM MODEL_CONFIG;

PROMPT [4-11] MODEL_CONFIG.top_p 값 범위 체크 (0~1)
SELECT MIN(top_p) AS min_top_p, MAX(top_p) AS max_top_p,
       AVG(top_p) AS avg_top_p
FROM MODEL_CONFIG;

PROMPT [4-12] SESSIONS 시간 제약 체크 (end_time >= start_time)
SELECT session_id, start_time, end_time
FROM SESSIONS
WHERE end_time IS NOT NULL
  AND end_time < start_time;

PROMPT [4-13] SESSION_LOGS 시간 제약 체크 (response_time >= request_time)
SELECT session_id, log_sequence, request_time, response_time
FROM SESSION_LOGS
WHERE response_time < request_time;

-- ============================================
-- PART 5: 통계 요약
-- ============================================

PROMPT ========================================
PROMPT PART 5: 통계 요약
PROMPT ========================================

-- 5-1. 부서별 통계
PROMPT [5-1] 부서별 직원 수, 프로젝트 수, 세션 수
SELECT
    D.department_name,
    COUNT(DISTINCT U.user_id) AS employee_count,
    COUNT(DISTINCT P.project_id) AS project_count,
    COUNT(DISTINCT S.session_id) AS session_count
FROM DEPARTMENT D
LEFT JOIN "USER" U ON D.department_id = U.department_id
LEFT JOIN PROJECT P ON D.department_id = P.department_id
LEFT JOIN SESSIONS S ON U.user_id = S.user_id
GROUP BY D.department_name
ORDER BY employee_count DESC;

-- 5-2. 모델별 통계
PROMPT [5-2] 모델별 설정 수, 배포 수, 세션 로그 수
SELECT
    M.model_name,
    COUNT(DISTINCT MC.config_id) AS config_count,
    COUNT(DISTINCT D.deployment_id) AS deployment_count,
    COUNT(DISTINCT SL.session_id) AS session_log_count
FROM MODEL M
LEFT JOIN MODEL_CONFIG MC ON M.model_id = MC.model_id
LEFT JOIN DEPLOYMENTS D ON M.model_id = D.model_id
LEFT JOIN SESSION_LOGS SL ON D.deployment_id = SL.deployment_id
GROUP BY M.model_name
ORDER BY deployment_count DESC;

-- 5-3. 사용자별 활동 통계
PROMPT [5-3] 상위 10명 활동량이 많은 사용자
SELECT
    U.user_name,
    U.role,
    D.department_name,
    COUNT(DISTINCT P.project_id) AS created_projects,
    COUNT(DISTINCT S.session_id) AS total_sessions,
    COUNT(DISTINCT PT.template_id) AS created_templates
FROM "USER" U
LEFT JOIN DEPARTMENT D ON U.department_id = D.department_id
LEFT JOIN PROJECT P ON U.user_id = P.creator_user_id
LEFT JOIN SESSIONS S ON U.user_id = S.user_id
LEFT JOIN PROMPT_TEMPLATE PT ON U.user_id = PT.creator_user_id
GROUP BY U.user_name, U.role, D.department_name
ORDER BY total_sessions DESC
FETCH FIRST 10 ROWS ONLY;

-- 5-4. 배포 환경별 통계
PROMPT [5-4] 배포 환경별 GPU 사용량 및 모델 수
SELECT
    environment,
    status,
    COUNT(*) AS deployment_count,
    SUM(gpu_count) AS total_gpu,
    AVG(gpu_count) AS avg_gpu,
    COUNT(DISTINCT model_id) AS unique_models
FROM DEPLOYMENTS
GROUP BY environment, status
ORDER BY environment, status;

-- 5-5. 프롬프트 템플릿 카테고리별 통계
PROMPT [5-5] 프롬프트 템플릿 카테고리별 평균 사용 횟수
SELECT
    task_category,
    COUNT(*) AS template_count,
    AVG(usage_count) AS avg_usage,
    MAX(usage_count) AS max_usage,
    MIN(usage_count) AS min_usage
FROM PROMPT_TEMPLATE
GROUP BY task_category
ORDER BY avg_usage DESC;

PROMPT ========================================
PROMPT 테스트 완료!
PROMPT ========================================
