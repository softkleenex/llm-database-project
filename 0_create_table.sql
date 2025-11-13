-- ============================================
-- 1. DEPARTMENT 테이블 (다른 테이블이 참조하므로 먼저 생성)
-- ============================================
CREATE TABLE DEPARTMENT (
    department_id VARCHAR2(50) PRIMARY KEY,
    department_name VARCHAR2(200) NOT NULL,
    manager_user_id VARCHAR2(50) UNIQUE -- 부서의 관리자(MANAGES)
);

-- ============================================
-- 2. USER 테이블
-- ============================================
CREATE TABLE "USER" (
    user_id VARCHAR2(50) PRIMARY KEY,
    user_name VARCHAR2(100) NOT NULL,
    user_email VARCHAR2(200) NOT NULL UNIQUE,
    role VARCHAR2(50) NOT NULL,
    is_active CHAR(1) DEFAULT 'Y' CHECK (is_active IN ('Y', 'N')),
    last_login TIMESTAMP,
    department_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_user_dept FOREIGN KEY (department_id)
        REFERENCES DEPARTMENT(department_id) -- 일반 직원의 소속 부서 (WORKS_FOR)
);

-- DEPARTMENT에 FK 나중에 추가 (순환참조문제 해결)
ALTER TABLE DEPARTMENT
ADD CONSTRAINT fk_dept_manager 
    FOREIGN KEY (manager_user_id) REFERENCES "USER"(user_id);

-- ============================================
-- 3. PROJECT 테이블
-- ============================================
CREATE TABLE PROJECT (
    project_id VARCHAR2(50) PRIMARY KEY,
    project_name VARCHAR2(200) NOT NULL,
    description CLOB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    creator_user_id VARCHAR2(50) NOT NULL,
    department_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_project_user FOREIGN KEY (creator_user_id) 
        REFERENCES "USER"(user_id), -- 프로젝트 생성유저 (CREATES_PROJ)
    CONSTRAINT fk_project_dept FOREIGN KEY (department_id) 
        REFERENCES DEPARTMENT(department_id) -- 프로젝트 소속부서 (BELONGS_TO)
);

-- ============================================
-- 4. MODEL 테이블
-- ============================================
CREATE TABLE MODEL (
    model_id VARCHAR2(50) PRIMARY KEY,
    model_name VARCHAR2(200) NOT NULL,
    model_type VARCHAR2(100) NOT NULL
);

-- ============================================
-- 5. MODEL_CONFIG 테이블
-- ============================================
CREATE TABLE MODEL_CONFIG (
    config_id VARCHAR2(50) PRIMARY KEY,
    config_name VARCHAR2(200) NOT NULL,
    max_tokens NUMBER(10) NOT NULL,
    temperature NUMBER(3,2) CHECK (temperature BETWEEN 0 AND 2),
    top_p NUMBER(3,2) CHECK (top_p BETWEEN 0 AND 1),
    top_k NUMBER(10),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    model_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_config_model FOREIGN KEY (model_id) 
        REFERENCES MODEL(model_id) -- Config가 속하는 모델 (HAS_CONFIG)
);

-- ============================================
-- 6. DATASET 테이블
-- ============================================
CREATE TABLE DATASET (
    dataset_id VARCHAR2(50) PRIMARY KEY,
    learning_type VARCHAR2(100) NOT NULL,
    description CLOB,
    s3_path VARCHAR2(500) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ============================================
-- 7. DEPLOYMENTS 테이블
-- ============================================
CREATE TABLE DEPLOYMENTS (
    deployment_id VARCHAR2(50) PRIMARY KEY,
    server_name VARCHAR2(200) NOT NULL,
    gpu_count NUMBER(5) NOT NULL,
    environment VARCHAR2(50) NOT NULL,
    status VARCHAR2(50) NOT NULL,
    model_id VARCHAR2(50) NOT NULL,
    dataset_id VARCHAR2(50),
    CONSTRAINT fk_deploy_model FOREIGN KEY (model_id) 
        REFERENCES MODEL(model_id), -- 배포할때 사용된 모델 (DEPLOYED AS)
    CONSTRAINT fk_deploy_dataset FOREIGN KEY (dataset_id) 
        REFERENCES DATASET(dataset_id) -- 배포된 모델이 학습때 사용한 데이터셋. 학습 없을수도 있어서 NULL 가능.(USES DATA)
);

-- ============================================
-- 8. SESSIONS 테이블
-- ============================================
CREATE TABLE SESSIONS (
    session_id VARCHAR2(50) PRIMARY KEY,
    start_time TIMESTAMP NOT NULL,
    end_time TIMESTAMP,
    session_type VARCHAR2(50) NOT NULL,
    status VARCHAR2(50) NOT NULL,
    user_id VARCHAR2(50) NOT NULL,
    project_id VARCHAR2(50),
    CONSTRAINT fk_session_user FOREIGN KEY (user_id) 
        REFERENCES "USER"(user_id), -- 세션을 사용하는 USER (USES)
    CONSTRAINT fk_session_project FOREIGN KEY (project_id) 
        REFERENCES PROJECT(project_id), -- 세션을 오픈한 PROJECT. 프로젝트없이 여는것도 가능해서 NULL 가능 (RELATED TO)
    CONSTRAINT chk_session_time CHECK (end_time IS NULL OR end_time >= start_time)
);

-- ============================================
-- 9. SESSION_LOGS 테이블 (Weak Entity - 복합키)
-- ============================================
CREATE TABLE SESSION_LOGS (
    session_id VARCHAR2(50),
    log_sequence NUMBER(10),
    request_time TIMESTAMP NOT NULL,
    request_prompt_s3_path VARCHAR2(500) NOT NULL,
    response_s3_path VARCHAR2(500) NOT NULL,
    token_used NUMBER(10) NOT NULL,
    response_time TIMESTAMP NOT NULL,
    config_id VARCHAR2(50),
    deployment_id VARCHAR2(50) NOT NULL,
    CONSTRAINT pk_session_logs PRIMARY KEY (session_id, log_sequence),
    CONSTRAINT fk_logs_session FOREIGN KEY (session_id) 
        REFERENCES SESSIONS(session_id) ON DELETE CASCADE, -- 소속된 세션 (HAS_SESSION)
    CONSTRAINT fk_logs_config FOREIGN KEY (config_id) 
        REFERENCES MODEL_CONFIG(config_id), -- 세션이 사용하는 model config. config 기본값 사용했으면 따로 없으므로 Null 가능.(APPLIES_CONFIG)
    CONSTRAINT fk_logs_deployment FOREIGN KEY (deployment_id) 
        REFERENCES DEPLOYMENTS(deployment_id), -- 세션이 사용하는 모델배포버전 (DEPLOYED_IN)
    CONSTRAINT chk_logs_time CHECK (response_time >= request_time)
);

-- ============================================
-- 10. PROMPT_TEMPLATE 테이블
-- ============================================
CREATE TABLE PROMPT_TEMPLATE (
    template_id VARCHAR2(50) PRIMARY KEY,
    template_name VARCHAR2(200) NOT NULL,
    prompt_s3_path VARCHAR2(500) NOT NULL,
    description CLOB,
    task_category VARCHAR2(100) NOT NULL,
    variables VARCHAR2(1000),
    version VARCHAR2(20) NOT NULL,
    usage_count NUMBER(10) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    creator_user_id VARCHAR2(50) NOT NULL,
    CONSTRAINT fk_template_user FOREIGN KEY (creator_user_id) 
        REFERENCES "USER"(user_id) -- PROMPT 생성한 user(CREATES_TEPL)
);

-- ============================================
-- 시퀀스 생성 (log_sequence 자동 증가용)
-- ============================================
CREATE SEQUENCE seq_log_sequence
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

commit;