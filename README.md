# 🏗️ Data Warehouse & Mart Build: Production ETL Pipeline

An end-to-end data engineering pipeline that transforms raw CSV files from Google Cloud Storage into a normalized star schema data warehouse, then builds analytical data marts.

![workflow](img/1_2_Project2_Data_Pipeline.png)

## 🧩 Problem & Context

Raw job posting data arrives as flat CSV files in Google Cloud Storage—not structured for analytical queries. Analysts need to answer:

- Which skills are most in-demand over time?
- What are hiring trends by company and location?
- How do salary patterns vary by role and skill?
  
**Challenge**: Data teams need a single source of truth system—a data warehouse—to enable consistent, reliable analysis across the organization. Additionally, specialized data marts are required to optimize resources by pre-aggregating data for specific business use cases, reducing query complexity and improving performance for common analytical patterns.

**Solution**: End-to-end ETL pipeline that extracts CSVs from cloud storage, normalizes them into a star schema warehouse (separating facts from dimensions), and creates specialized data marts optimized for specific use cases (flat queries, skill demand analysis, priority role tracking).

## 🧰 Tech Stack
- 🐤 **Database**: DuckDB (file-based OLAP database with GCS integration via httpfs)
- 🧮 **Language**: SQL (DDL for schema design, DML for data loading and transformation)
- 📊 **Data Model**: Star schema (fact + dimension + bridge tables)
- 🛠️ **Development**: VS Code for SQL editing + Terminal for DuckDB CLI execution
- 🔧 **Automation**: Master SQL script for pipeline orchestration
- 📦 **Version Control**: Git/GitHub for versioned pipeline scripts
- ☁️ **Storage**: Google Cloud Storage for source CSV files
  
## 📂 Structure

```
2_WH_Mart_Build/
├── 01_create_tables_dw.sql        # Star schema DDL
├── 02_load_schema_dw.sql          # GCS data extraction & loading
├── 03_create_flat_mart.sql        # Denormalized flat mart
├── 04_create_skills_mart.sql      # Skills demand mart
├── 05_create_priority_mart.sql    # Priority roles mart
├── 06_update_priority_mart.sql    # Priority mart incremental update (MERGE)
├── build_dw_marts.sql             # Master SQL build script
└── README.md                      # You are here
```

### Data Warehouse

The data warehouse implements a star schema with `company_dim`, `skills_dim`, `job_postings_fact`, and `skills_job_dim` tables.

![dw](img/1_2_Data_Warehouse.png)

- **SQL Files**:
  - [01_create_tables_dw.sql](01_create_tables_dw.sql) – Defines star schema with 4 core tables
  - [02_load_schema_dw.sql](02_load_schema_dw.sql) – Extracts CSVs from GCS and loads into warehouse tables
- **Purpose**: Star schema serving as single source of truth for analytical queries
- **Grain**: One row per job posting in the fact table (`job_postings_fact`)

### Flat Mart

Denormalized table with all dimensions for ad-hoc queries.

![flat_mart](img/1_2_Flat_Mart.png)

- **SQL File**: [03_create_flat_mart.sql](03_create_flat_mart.sql) – Builds denormalized table with all dimensions joined
- **Purpose**: Denormalized table for quick ad-hoc queries
- **Grain**: One row per job posting with all dimensions joined

### Skills Mart

Time-series skill demand analysis with additive measures.

![skills_mart](img/1_2_Skills_Mart.png)

- **SQL File**: [04_create_skills_mart.sql](04_create_skills_mart.sql) – Builds time-series skill demand mart
- **Purpose**: Time-series analysis of skill demand over time with additive measures
- **Grain**: `skill_id + month_start_date + job_title_short`
- **Key Features**: All measures are additive (counts/sums) for safe re-aggregation

### Priority Mart

Priority role tracking with incremental updates using MERGE operations.

![priority_mart](img/1_2_Priority_Mart.png)

- **SQL Files**:
    - [05_create_priority_mart.sql](05_create_priority_mart.sql) – Initial build of priority roles and jobs snapshot
    - [06_update_priority_mart.sql](06_update_priority_mart.sql) – Incremental update using MERGE (upsert pattern)
- **Purpose**: Track priority roles and job snapshots with incremental update capabilities
- **Grain**: One row per job posting with priority level assignment
- **Key Features**: MERGE operations for incremental updates - demonstrates production-ready upsert patterns (INSERT, UPDATE, DELETE in single statement)