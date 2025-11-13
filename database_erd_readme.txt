# LLM Platform ERD 설명서 (README)

이 문서는 LLM Platform ERD를 이해하기 위한 안내입니다.
본 ERD는 사내 오픈소스 LLM 관리 대시보드를 위한 데이터베이스 설계 초안으로,
사용자 관리, 세션 및 로그 추적, 모델/배포/데이터셋 관리, 프롬프트 템플릿 관리 등을 포함합니다.

---

## 1. Entities (엔티티) & Attributes

### Strong Entities (9개)

### USER (사용자)

**엔티티 설명**: 시스템을 사용하는 모든 사용자의 정보를 관리하는 핵심 엔티티입니다. LLM 플랫폼의 모든 활동 주체로서, 프로젝트 생성, 세션 실행, 템플릿 작성 등 시스템 내 모든 활동의 출발점이 됩니다.

**속성 상세 설명**:

- **user_id (Key Attribute)** - 사용자 고유 식별자. 시스템 전체에서 각 사용자를 유일하게 식별하는 속성.
- user_name - 사용자 실명. 화면 표시 및 보고서 생성 시 사용되는 실제 이름.
- user_email - 사용자의 이메일 정보.
- role - 사용자 역할. 관리자(Admin), 개발자(Developer), 연구원(Researcher), 분석가(Analyst) 등 역할에 따라 프로젝트 관리 권한이나 배포 설정 권한 등을 구분할 수 있음.
- is_active - 활성 상태. True/False로 표현되며, 현재 활동 중인 사용자만 시스템에서 선택적으로 보여줄 수 있음.
- last_login - 마지막 접속 시간. 사용자 활동 모니터링 및 보안 감사에 활용

### DEPARTMENT (부서)

**엔티티 설명**: 조직의 부서 구조를 표현하는 엔티티입니다. 사용자와 프로젝트를 조직 단위로 그룹화하여 관리하며, 부서별 자원 할당의 기준이 됩니다.

**속성 상세 설명**:

- **department_id** **(Key Attribute)** - 부서 고유 식별자. 각 부서를 시스템 내에서 유일하게 구분하는 속성.
- department_name - 부서명. AI연구팀, 데이터분석팀, 개발1팀 등 실제 조직도상의 부서명

### PROJECT (프로젝트)

**엔티티 설명**: LLM을 활용한 각종 프로젝트 정보를 관리하는 엔티티입니다. 부서별로 진행되는 AI/ML 프로젝트를 추적하고, 관련 세션과 사용량을 집계하는 단위가 됩니다.

**속성 상세 설명**:

- **project_id** **(Key Attribute)** - 프로젝트 고유 식별자. 각 프로젝트를 유일하게 구분하는 속성.
- project_name - 프로젝트명. "고객서비스 챗봇", "문서요약 시스템", "코드리뷰 자동화" 등 프로젝트의 공식 명칭
- description - 프로젝트 설명. 프로젝트의 목적, 범위, 예상 결과물, 주요 마일스톤 등 상세 정보
- created_at - 생성 시간. 프로젝트 시작 시점을 기록하여 진행 기간 산정에 활용.

### SESSIONS (사용 세션)

**엔티티 설명**: 사용자가 LLM을 사용하는 개별 작업 세션을 관리하는 엔티티입니다. 하나의 세션은 사용자가 시스템에 접속하여 여러 번의 질의응답을 수행하는 하나의 작업 단위를 나타냅니다.

**속성 상세 설명**:

- **session_id (Key Attribute)** - 세션 고유 식별자. 각 세션을 유일하게 구분하는 속성.
- start_time - 시작 시간. 세션이 시작된 정확한 시각을 기록
- end_time - 종료 시간. 세션이 종료된 시각으로, 세션 지속 시간 계산에 사용
- session_type - 세션 유형. "개발", "테스트", "프로덕션", "실험" 등 세션의 용도별 분류
- status - 세션 상태. "진행중", "완료", "오류", "중단" 등 현재 세션의 상태 표시

### MODEL (LLM 모델)

**엔티티 설명**: 시스템에서 사용 가능한 LLM 모델들의 마스터 정보를 관리하는 엔티티입니다. GPT-oss, Mistral, LLaMA 등 다양한 오픈소스 모델의 기본 정보를 저장합니다.

**속성 상세 설명**:

- **model_id** **(Key Attribute)** - 모델 고유 식별자. 각 모델을 유일하게 구분하는 속성.
- model_name - 모델명. "gpt-oss-120b", "Mistral-8b", "LLaMA-2-70B" 등 공식 모델 명칭
- model_type - 모델 유형. 모델의 주요 용도 분류를 위함.

### MODEL_CONFIG (모델 설정)

**엔티티 설명**: 각 모델의 세부 파라미터 설정을 관리하는 엔티티입니다. 동일한 모델에 대해 여러 가지 설정 프리셋을 만들어 용도별로 최적화된 설정을 재사용할 수 있습니다.

**속성 상세 설명**:

- **config_id (Key Attribute)** - 설정 고유 식별자. 각 설정 프리셋을 유일하게 구분하는 속성.
- config_name - 설정명. 프리셋의 용도를 나타내는 이름
- max_tokens - 최대 토큰 수. 생성할 텍스트의 최대 길이를 토큰 단위로 제한 (예: 4096)
- temperature - 온도 파라미터. 0.0~2.0 범위로 창의성과 일관성의 균형을 조절 (낮을수록 일관성, 높을수록 창의성)
- top_p - 누적 확률 임계값. 토큰 선택의 다양성 제어.
- top_k - 선택 가능한 토큰을 상위 k개로 제한하여 응답의 품질 향상.
- created_at - 설정이 생성된 시간.

### DEPLOYMENTS (배포 환경)

**엔티티 설명**: LLM 모델이 실제로 배포되어 실행되는 서버 환경 정보를 관리하는 엔티티입니다. 모델의 물리적 배포 위치와 리소스 할당 상태를 추적합니다.

**속성 상세 설명**:

- **deployment_id (Key Attribute)** - 배포 고유 식별자. 각 배포 인스턴스를 유일하게 구분하는 속성.
- server_name - 서버명. "[ml-server-01.company.com](http://ml-server-01.company.com/)" 등 실제 서버의 호스트명이나 IP
- gpu_count - GPU 개수. 해당 배포에 할당된 GPU 리소스 수량 (성능에 직접적 영향)
- environment - 배포 환경. "개발", "테스트", "스테이징", "프로덕션" 등 배포 스테이지 구분
- status - 배포 상태. "활성", "비활성", "유지보수", "오류" 등 현재 서비스 가용성 표시

### DATASET (데이터셋)

**엔티티 설명**: 모델 파인튜닝이나 추가 학습에 사용되는 데이터셋 정보를 관리하는 엔티티입니다. 커스텀 모델 학습을 위한 훈련 데이터를 관리합니다.

**속성 상세 설명**:

- **dataset_id (Key Attribute)** - 데이터셋 고유 식별자. 각 데이터셋을 유일하게 구분하는 속성.
- learning_type - 학습 유형. "파인튜닝", "프롬프트학습", "전이학습", "강화학습" 등 학습 방법론 구분
- description - 데이터셋 설명. 데이터 출처, 크기, 품질, 전처리 방법, 용도 등 상세 메타데이터
- s3_path - S3 저장 경로. "s3://bucket/datasets/custom_data_v1.parquet" 등 대용량 데이터 파일의 클라우드 저장 위치
- created_at - 생성 시간. 데이터셋이 준비 완료된 시각

### PROMPT_TEMPLATE (프롬프트 템플릿)

**엔티티 설명**: 재사용 가능한 프롬프트 템플릿을 관리하는 엔티티입니다. 표준화된 프롬프트를 템플릿화하여 일관성 있는 LLM 활용을 지원합니다.

**속성 상세 설명**:

- **template_id (Key Attribute)** - 템플릿 고유 식별자. 각 템플릿을 유일하게 구분하는 기본키
- template_name - 템플릿명. "이메일요약", "코드리뷰", "번역템플릿" 등 템플릿의 용도를 나타내는 이름
- prompt_s3_path - 프롬프트 S3 경로. 긴 프롬프트 텍스트를 저장한 S3 파일 위치
- description - 템플릿 설명. 템플릿의 사용 목적, 예상 입출력, 주의사항 등 상세 가이드
- task_category - 작업 카테고리. "요약", "번역", "생성", "분석", "코딩" 등 작업 유형별 분류
- variables - 템플릿 변수. "{user_input}", "{context}", "{language}" 등 동적으로 치환될 변수 목록
- created_at - 생성 시간. 템플릿이 최초 작성된 시각
- version - 버전. "1.0", "1.1", "2.0" 등 템플릿의 버전 관리 번호.
- usage_count - 사용 횟수. 템플릿이 실제 사용된 누적 횟수.

### Weak Entity (1개)

### SESSION_LOGS (세션 로그)

**엔티티 설명**: 각 세션 내에서 발생하는 개별 요청-응답 쌍을 기록하는 약한 엔티티입니다. SESSIONS에 완전히 종속되며, 하나의 세션에서 여러 번의 LLM 호출이 순차적으로 발생한 내역을 상세히 저장합니다. Partial Key인 log_sequence와 부모 엔티티의 Key Attribute인 session_id의 조합으로 고유 식별 가능합니다.

**속성 상세 설명**:

- **log_sequence** **(Partial Key)** - 세션 내 로그 순번. 동일 세션 내에서 발생한 요청의 순서를 나타내는 일련번호 (1, 2, 3...)
- request_time - 요청 시간. 각 개별 LLM API 호출이 발생한 정확한 시각
- request_prompt_s3_path - 요청 프롬프트 S3 경로. 사용자가 입력한 프롬프트 전체 내용을 저장한 S3 파일 위치
- response_s3_path - 응답 S3 경로. LLM이 생성한 응답 전체 내용을 저장한 S3 파일 위치
- token_used - 사용 토큰 수. 입력 토큰과 출력 토큰의 합계로 비용 계산의 기준
- response_time - 응답 시간. LLM이 응답을 생성 완료한 시간.
- latency - Derived Attributes. Response시간에서 Request시간을 뺀 실제 처리 시간.

**Weak Entity 특징**:

- SESSIONS 엔티티에 완전히 종속 (세션이 삭제되면 관련 로그도 모두 삭제)
- session_id + log_sequence 조합으로만 유일하게 식별
- Identifying Relationship (HAS)로 SESSIONS와 연결

---

## 2. Relationships (관계) & Cardinality / Participation

### CREATES_PROJ(USER — PROJECT)

PROJECT는 반드시 하나의 USER에 의해 생성되므로 Total Participant이며, USER는 PROJECT를 하나도 생성하지 않을 수도 있으므로 Partial Participant. 하나의 USER가 여러 PROJECT를 생성할 수 있으므로 1 : N 관계이다.

### MANAGES(USER-DEPARTMENT)

DEPARTMENT는 반드시 한 명의 USER(관리자)에 의해 관리되어야하므로 Total Participant이며, USER는 어떤 DEPARTMENT도 관리하지 않을 수 있으므로(관리자가 아닐 수 있으므로) Partial Participant. 한 명의 USER가 한 DEPARTMENT만 관리할 수 있으므로 1:1 관계이다.

### WORKS_FOR(USER-DEPARTMENT)

USER는 반드시 하나의 DEPARTMENT에 소속되어야 하므로 Total Participant이며, DEPARTMENT는 USER를 반드시 보유해야 하므로 Total Participant. 하나의 DEPARTMENT에 여러 USER가 속할 수 있으므로 1:N 관계이다.

### BELONGS_TO(DEPARTMENT — PROJECT)

PROJECT는 반드시 하나의 DEPARTMENT에 속하므로 Total Participant이며, DEPARTMENT는 PROJECT를 하나도 보유하지 않을 수도 있으므로 Partial Participan. 하나의 DEPARTMENT가 여러 PROJECT를 가질 수 있으므로 1:N 관계이다.

### USES (USER-SESSIONS)

SESSION은 반드시 하나의 USER에 의해 생성되므로 Total Participant이며, USER는 SESSION을 하나도 가지지 않을 수도 있으므로 Partial Participant이다. 하나의 USER가 여러 SESSION을 생성할 수 있으므로 1:N 관계이다.

### RELTED_TO (PROJECT - SESSIONS)

SESSION은 PROJECT와 관련되지 않을 수 있으므로 Partial participant이며, PROJECT 역시 SESSION을 갖지 않을 수 있으므로 Partial participant이다. 하나의 PROJECT에서 여러 SESSION을 사용할 수 있으므로 1:N 관계이다.

### HAS_SESSION (SESSIONS - SESSION_LOGS)

SESSION_LOGS는 반드시 하나의 SESSIONS에 속해야 하므로 Total participant이며, SESSIONS는 로그가 없는 경우도 있을 수 있어 Partial participant이다. SESSIONS는 하나 이상의 SESSION_LOGS를 가질 수 있으므로 1:N 관계이다.

### HAS_CONFIG (MODEL - MODEL_CONFIG)

MODEL_CONFIGURATION은 반드시 하나의 MODEL에 의해 정의되어야 하므로 Total participant이며, MODEL은 아직 설정을 갖지 않을 수도 있어 Partial participant이다. MODEL 하나에 여러 개의 MODEL_CONFIGURATION이 존재할 수 있으므로 1:N 관계이다.

### APPLIES_CONFIG(MODEL_CONFIG - SESSION_LOGS)

SESSION_LOGS는 각 요청 시점에 사용된 모델 설정을 참조하므로 MODEL_CONFIG에 대해 Partial Participation이며, MODEL_CONFIG 또한 특정 요청에 적용되지 않을 수도 있으므로 Partial Participation이다. 하나의 MODEL_CONFIG가 여러 요청(SESSION_LOGS)에 재사용될 수 있고 하나의 SESSION_LOGS는 하나의 CONFIG값만 가지고 있으므로 1:N 관계이다.

### DEPLOYED_AS (MODEL - DEPLOYMENTS)

DEPLOYMENTS는 반드시 하나의 MODEL을 기반으로 하므로 Total participant이며, MODEL은 아직 배포되지 않았을 수도 있어 Partial participant이다. 하나의 MODEL은 여러 DEPLOYMENTS로 배포될 수 있으므로 1:N 관계이다.

### DEPLOYED_IN (DEPLOYMENTS - SESSION_LOGS)

DEPLOYMENTS는 SESSION_LOGS를 갖지 않을 수 있으므로 Partial participant이며, SESSION_LOGS는 반드시 DEPLOYMENTS 정보를 가지므로 Total participant이다. 하나의 DEPLOYMENTS에 대해 여러 SESSION_LOGS가 존재할 수 있으므로 1:N 관계이다.

### USES_DATA (DATASET - DEPLOYMENTS)

DEPLOYMENTS는 데이터셋 없이 생성될 수 있으므로 Partial participant이며, DATASET도 배포에 사용되지 않을 수 있어 Partial participant이다. 하나의 DATASET은 여러 DEPLOYMENTS에 사용될 수 있고, 각 DEPLOYMENT는 최대 하나의 DATASET을 사용할 수 있으므로 1:N 관계이다.

### CREATES_TEPL (USER - PROMPT_TEMPLATE)

PROMPT_TEMPLATE은 반드시 작성한 USER가 존재하므로 Total participant이며, USER는 템플릿을 생성하지 않을 수도 있어 Partial participant이다. 하나의 USER는 여러 PROMPT_TEMPLATE을 생성할 수 있으므로 1:N 관계이다.