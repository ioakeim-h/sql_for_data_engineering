
CREATE TABLE IF NOT EXISTS company_dim (
    company_id INTEGER PRIMARY KEY ,
    name VARCHAR,
    -- link VARCHAR(50),
    -- link_google VARCHAR(50),
    -- thumbnail
);

CREATE TABLE IF NOT EXISTS skills_dim (
    skill_id INTEGER PRIMARY KEY,
    skills VARCHAR,
    type VARCHAR
);

CREATE TABLE IF NOT EXISTS job_postings_fact (
    job_id INTEGER PRIMARY KEY,
    company_id INTEGER,
    job_title_short VARCHAR,
    job_title VARCHAR,
    job_location VARCHAR,
    job_via VARCHAR,
    job_schedule_type VARCHAR,
    job_work_from_home BOOLEAN,
    search_location VARCHAR,
    job_posted_date TIMESTAMP,
    job_no_degree_mention BOOLEAN,
    job_health_insurance BOOLEAN,
    job_country VARCHAR,
    salary_rate VARCHAR,
    salary_year_avg DOUBLE,
    salary_hour_avg DOUBLE,
    FOREIGN KEY (company_id) REFERENCES company_dim(company_id)
);

CREATE TABLE IF NOT EXISTS skills_job_dim (
    job_id INTEGER,
    skill_id INTEGER,
    PRIMARY KEY (job_id, skill_id),
    FOREIGN KEY (job_id) REFERENCES job_postings_fact(job_id),
    FOREIGN KEY (skill_id) REFERENCES skills_dim(skill_id)
);

-- Verify creation
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'main';

/*
    Run (creates duckdb database file): 
    duckdb dw_marts.duckdb -c ".read 01_create_tables_dw.sql"
*/