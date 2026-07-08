
DROP SCHEMA IF EXISTS skills_mart CASCADE;
CREATE SCHEMA skills_mart;

CREATE TABLE skills_mart.dim_skills (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);

CREATE TABLE skills_mart.dim_date_month (
    month_start_date DATE PRIMARY KEY,
    year INTEGER,
    month INTEGER,
    quarter INTEGER,
    quarter_name VARCHAR,
    year_quarter VARCHAR

);

CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id INTEGER,
    month_start_date DATE,
    job_title_short VARCHAR,
    postings_count INTEGER,
    remote_postings_count INTEGER,
    health_insurance_postings_count INTEGER,
    no_degree_postings_count INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id) REFERENCES skills_mart.dim_skills(skill_id),
    FOREIGN KEY (month_start_date) REFERENCES skills_mart.dim_date_month(month_start_date)
);

SELECT '=== Loading Skills Dim for Skills Mart ===' AS info;
INSERT INTO skills_mart.dim_skills (
    skill_id,
    skills,
    type
)
SELECT 
    skill_id,
    skills,
    type
FROM skills_dim;


SELECT '=== Loading Date Dim For Skills Mart ===' AS info;
INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' || 
        EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS year_quarter
FROM job_postings_fact
ORDER BY month_start_date;

SELECT '=== Loading Skill Fact for Skills Mart ===' AS info;
INSERT INTO skills_mart.fact_skill_demand_monthly (
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,
    no_degree_postings_count
)
WITH job_postings_prep AS (
    SELECT  
        sjd.skill_id,
        DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,
        jpf.job_title_short,
        CASE WHEN jpf.job_work_from_home = TRUE THEN 1 ELSE 0 END AS is_remote,
        CASE WHEN jpf.job_health_insurance = TRUE THEN 1 ELSE 0 END AS has_health_insurance,
        CASE WHEN jpf.job_no_degree_mention = TRUE THEN 1 ELSE 0 END AS no_degree_mentioned      
    FROM job_postings_fact AS jpf
    INNER JOIN skills_job_dim AS sjd ON jpf.job_id = sjd.job_id
)
SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS job_postings,
    SUM(is_remote) AS remote_postings_count,
    SUM(has_health_insurance) AS health_insurance_postings_count,
    SUM(no_degree_mentioned) AS no_degree_no_degree_mentioned_postings_count
FROM job_postings_prep
GROUP BY ALL
ORDER BY skill_id, month_start_date, job_title_short;

SELECT '=== Data Validation ===' AS info;
SELECT 'dim_skills' AS table_name, COUNT(*) AS row_count FROM skills_mart.dim_skills
UNION ALL
SELECT 'dim_date_month', COUNT(*) FROM skills_mart.dim_date_month    
UNION ALL
SELECT 'fact_skill_demand_monthly', COUNT(*) FROM skills_mart.fact_skill_demand_monthly;   



