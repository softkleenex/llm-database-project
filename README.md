# LLM Database Platform Project

A comprehensive database design and implementation project for a Large Language Model (LLM) management platform. This project demonstrates enterprise-level database architecture, SQL programming, and data modeling skills.

## 📋 Project Overview

This project implements a complete database system for managing:
- **Users & Departments**: Multi-user organization management
- **AI Projects**: Project tracking and team collaboration
- **ML Models**: Model lifecycle and version management
- **Datasets**: Training and validation data management
- **Deployments**: Production environment tracking
- **Sessions & Logs**: User activity and system auditing
- **Prompt Templates**: Reusable AI prompt library

### Key Features

- ✅ **10 interconnected tables** with proper referential integrity
- ✅ **6,118 test records** across all tables
- ✅ **43 validation queries** testing all relationships
- ✅ **Complete documentation** with execution guides
- ✅ **Automated testing** with comprehensive error handling

## 🗄️ Database Schema

### Entity-Relationship Overview

```
DEPARTMENT (10 records)
    ↓ manages
USER (150 records) ← supervises each other
    ↓ creates
PROJECT (100 records)
    ↓ uses
MODEL (22 records)
    ↓ configured via
MODEL_CONFIG (132 records)
    ↓ trained on
DATASET (30 records)
    ↓ deployed to
DEPLOYMENTS (44 records)
    ↓ generates
SESSIONS (650 records)
    ↓ logs
SESSION_LOGS (4,860 records)
    ↑ references
PROMPT_TEMPLATE (120 records)
```

### Table Summary

| Table | Records | Purpose |
|-------|---------|---------|
| DEPARTMENT | 10 | Organization structure |
| USER | 150 | System users |
| PROJECT | 100 | AI/ML projects |
| MODEL | 22 | ML model registry |
| MODEL_CONFIG | 132 | Model configurations |
| DATASET | 30 | Training datasets |
| DEPLOYMENTS | 44 | Production deployments |
| PROMPT_TEMPLATE | 120 | AI prompt templates |
| SESSIONS | 650 | User sessions |
| SESSION_LOGS | 4,860 | Activity logs |
| **TOTAL** | **6,118** | |

## 🚀 Quick Start

### Prerequisites

- Oracle Database 19c or later
- SQL*Plus or SQL Developer
- User account with CREATE TABLE, INSERT, SELECT privileges

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/softkleenex/llm-database-project.git
   cd llm-database-project
   ```

2. **Connect to Oracle**
   ```bash
   sqlplus your_username/your_password@your_database
   ```

3. **Run the automated setup**
   ```sql
   @run_all.sql
   ```

That's it! The script will:
- Create all 10 tables
- Insert 6,118 test records
- Run 43 validation queries
- Generate a log file with results

### Manual Installation

If you prefer step-by-step execution:

```sql
-- 1. Create tables
@0_create_table.sql

-- 2. Insert data (in order)
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

-- 3. Run tests
@test_all_queries.sql
```

## 📁 Project Structure

```
database-project/
├── run_all.sql                     # ⭐ Automated setup script
├── test_all_queries.sql            # ⭐ Comprehensive test suite
│
├── SQL Scripts/
│   ├── 0_create_table.sql          # Table definitions
│   ├── 1_insert_department.sql     # Department data
│   ├── 2_insert_user.sql           # User data
│   ├── 3_insert_project.sql        # Project data
│   ├── 4_insert_model.sql          # Model data
│   ├── 5_insert_model_config.sql   # Config data
│   ├── 6_insert_dataset.sql        # Dataset data
│   ├── 7_insert_deployments.sql    # Deployment data
│   ├── 8_insert_prompt_template.sql # Template data
│   ├── 9_insert_sessions.sql       # Session data
│   └── 10_insert_session_logs.sql  # Log data
│
└── Documentation/
    ├── README.md                   # ⭐ This file
    ├── README_EXECUTION.md         # Detailed execution guide
    ├── TEST_SUMMARY.md             # Test results summary
    ├── FINAL_REPORT.md             # Project final report
    ├── EXECUTION_PLAN.md           # Implementation plan
    ├── ERROR_LOG.md                # Known issues & solutions
    ├── FINAL_CHECKLIST.md          # Quality assurance
    ├── ERD_SQL_MISMATCH_REPORT.md  # Schema validation
    └── database_team_proj_erd.pdf  # ER diagram
```

## 🧪 Testing

The project includes comprehensive testing:

### Running Tests

```sql
@test_all_queries.sql
```

### Test Coverage

- ✅ Table creation and constraints
- ✅ Foreign key relationships
- ✅ Data insertion validation
- ✅ Query performance (JOINs, aggregations)
- ✅ Complex queries (nested, correlated)
- ✅ Edge cases and error handling

### Expected Test Results

```sql
-- Verify record counts
SELECT 'DEPARTMENT' as table_name, COUNT(*) as records FROM DEPARTMENT
UNION ALL
SELECT 'USER', COUNT(*) FROM USER_ACCOUNT
-- ... (should match the table above)
```

## 📊 Sample Queries

### 1. Active Users by Department

```sql
SELECT d.department_name, COUNT(u.user_id) as user_count
FROM DEPARTMENT d
LEFT JOIN USER_ACCOUNT u ON d.department_id = u.department_id
WHERE u.status = 'active'
GROUP BY d.department_name
ORDER BY user_count DESC;
```

### 2. Project Models with Deployments

```sql
SELECT p.project_name, m.model_name, m.model_type,
       COUNT(dep.deployment_id) as deployment_count
FROM PROJECT p
JOIN MODEL m ON p.project_id = m.project_id
LEFT JOIN DEPLOYMENTS dep ON m.model_id = dep.model_id
GROUP BY p.project_name, m.model_name, m.model_type
ORDER BY deployment_count DESC;
```

### 3. Most Active Users (by Session Logs)

```sql
SELECT u.username, u.full_name, COUNT(sl.log_id) as activity_count
FROM USER_ACCOUNT u
JOIN SESSIONS s ON u.user_id = s.user_id
JOIN SESSION_LOGS sl ON s.session_id = sl.session_id
WHERE s.session_date >= ADD_MONTHS(SYSDATE, -1)
GROUP BY u.username, u.full_name
ORDER BY activity_count DESC
FETCH FIRST 10 ROWS ONLY;
```

## 📈 Database Design Highlights

### Normalization
- **3NF (Third Normal Form)** compliance
- No transitive dependencies
- Minimal data redundancy

### Constraints
- **Primary Keys**: All tables
- **Foreign Keys**: 15+ relationships
- **Check Constraints**: Data validation
- **NOT NULL**: Critical fields
- **UNIQUE**: Usernames, emails

### Indexing Strategy
- Primary key indexes (automatic)
- Foreign key indexes (recommended)
- Suggested indexes for frequent queries

## 🛠️ Technology Stack

- **Database**: Oracle Database 19c
- **Language**: SQL (PL/SQL)
- **Tools**: SQL*Plus, SQL Developer
- **Testing**: Custom SQL test suite
- **Documentation**: Markdown, PDF

## 📚 Documentation

Detailed documentation is available in the following files:

1. **[README_EXECUTION.md](README_EXECUTION.md)** - Step-by-step execution guide with troubleshooting
2. **[FINAL_REPORT.md](FINAL_REPORT.md)** - Complete project report with analysis
3. **[TEST_SUMMARY.md](TEST_SUMMARY.md)** - Test results and validation
4. **[database_team_proj_erd.pdf](database_team_proj_erd.pdf)** - Visual ER diagram

## 🤝 Contributing

This is an academic project for educational purposes. Feel free to:
- Fork the repository
- Experiment with the schema
- Add new queries
- Improve documentation

## 📄 License

This project is available for educational and non-commercial use.

## 👤 Author

**SoftKleenex**
- GitHub: [@softkleenex](https://github.com/softkleenex)
- Project: LLM Database Platform
- Course: Database Systems (COMP322)

## 🙏 Acknowledgments

- Database Systems course instructors
- Oracle Database documentation
- Team members who contributed to the original design

---

⭐ **Star this repository** if you find it helpful for learning database design!

📧 For questions or feedback, please open an issue on GitHub.
