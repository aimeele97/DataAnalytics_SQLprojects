ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA rename column C1 to snapshot_date;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA rename column C2 to page;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA rename column C3 to job_id;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C4 TO job_title;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C5 TO job_subtitle;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C6 TO advertiser_id;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C7 TO advertiser_name;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C8 TO listing_date;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C9 TO posted_ago;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C10 TO promoted_flag;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C11 TO is_promoted;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C12 TO job_teaser;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C13 TO job_classification_slug;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C14 TO job_processing_code;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C15 TO advertiser_logo_url;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C16 TO job_type;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C17 TO work_location_type;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C18 TO job_salary;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C19 TO job_benefits;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C20 TO job_highlight_1;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C21 TO job_highlight_2;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C22 TO primary_classification_id;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C23 TO primary_classification_name;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C24 TO subclassification_id;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C25 TO subclassification_name;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C26 TO location_name;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C27 TO country_code;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C28 TO location_postcode;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C29 TO location_region;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C30 TO job_guid;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C31 TO job_url_suffix;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C32 TO job_listing_type;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C33 TO listing_source;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C34 TO industry_id;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C35 TO scraper_user;
ALTER TABLE SEEK_DATA.PUBLIC.SEEK_RAW_DATA RENAME COLUMN C36 TO is_expired_flag;
);

-- ========== 1. DIM_ADVERTISER ==========
CREATE OR REPLACE TABLE SEEK_DATA.PUBLIC.DIM_ADVERTISER (
    advertiser_id STRING PRIMARY KEY,
    advertiser_name STRING,
    advertiser_logo_url	STRING
);

INSERT INTO SEEK_DATA.PUBLIC.DIM_ADVERTISER (advertiser_id, advertiser_name, advertiser_logo_url)
SELECT DISTINCT advertiser_id, advertiser_name, advertiser_logo_url
FROM SEEK_DATA.PUBLIC.SEEK_RAW_DATA
WHERE advertiser_id IS NOT NULL;


-- ========== 2. DIM_LOCATION ==========
CREATE OR REPLACE TABLE SEEK_DATA.PUBLIC.DIM_LOCATION (
    location_id STRING PRIMARY KEY,
    location_name STRING,
    region STRING,
    postcode STRING,
    country_code STRING
);

INSERT INTO SEEK_DATA.PUBLIC.DIM_LOCATION (location_id, location_name, region, postcode, country_code)
SELECT DISTINCT
    MD5(location_name || '-' || location_postcode || '-' || location_region) AS location_id,
    location_name,
    location_region,
    location_postcode,
    country_code
FROM SEEK_DATA.PUBLIC.SEEK_RAW_DATA
WHERE location_name IS NOT NULL;


-- ========== 3. DIM_CLASSIFICATION ==========
CREATE OR REPLACE TABLE SEEK_DATA.PUBLIC.DIM_CLASSIFICATION (
    classification_id STRING PRIMARY KEY,
    classification_name STRING
);

INSERT INTO SEEK_DATA.PUBLIC.DIM_CLASSIFICATION (
    classification_id, classification_name
)
SELECT DISTINCT
    primary_classification_id,
    primary_classification_name
FROM SEEK_DATA.PUBLIC.SEEK_RAW_DATA
WHERE primary_classification_id IS NOT NULL;


-- ========== 4. DIM_JOB_TYPE ==========
CREATE OR REPLACE TABLE SEEK_DATA.PUBLIC.DIM_JOB_TYPE (
    job_id STRING PRIMARY KEY,
    job_type string,
    work_location_type STRING
);

INSERT INTO SEEK_DATA.PUBLIC.DIM_JOB_TYPE (job_id,job_type, work_location_type)
SELECT DISTINCT job_id, job_type, work_location_type
FROM SEEK_DATA.PUBLIC.SEEK_RAW_DATA
WHERE job_type IS NOT NULL;


-- ========== 5. DIM_DATE ==========
CREATE OR REPLACE TABLE SEEK_DATA.PUBLIC.DIM_DATE (
    date_key DATE PRIMARY KEY,
    year INT,
    month INT,
    day INT,
    day_of_week STRING,
    week_of_year INT,
    is_weekend BOOLEAN
);

INSERT INTO SEEK_DATA.PUBLIC.DIM_DATE (date_key, year, month, day, day_of_week, week_of_year, is_weekend)
SELECT DISTINCT
    date_value AS date_key,
    EXTRACT(YEAR FROM date_value),
    EXTRACT(MONTH FROM date_value),
    EXTRACT(DAY FROM date_value),
    TO_CHAR(date_value, 'DY'),
    WEEK(date_value),
    CASE WHEN DAYOFWEEK(date_value) IN (1, 7) THEN TRUE ELSE FALSE END
FROM (
    SELECT snapshot_date AS date_value FROM SEEK_DATA.PUBLIC.SEEK_RAW_DATA
    UNION
    SELECT listing_date AS date_value FROM SEEK_DATA.PUBLIC.SEEK_RAW_DATA
) AS dates
WHERE date_value IS NOT NULL;


-- ========== 6. FACT_JOB_POSTINGS ==========
CREATE OR REPLACE TABLE SEEK_DATA.PUBLIC.FACT_JOB_POSTINGS (
    job_id STRING PRIMARY KEY,
    snapshot_date DATE,
    listing_date DATE,
    posted_ago STRING,
    job_title STRING,
    job_subtitle STRING,
    job_teaser STRING,
    job_benefits STRING,
    job_highlight_1 STRING,
    job_highlight_2 STRING,
    job_classification_slug STRING,
    job_processing_code STRING,
    advertiser_logo_url STRING,
    job_salary STRING,
    promoted_flag STRING,
    is_promoted BOOLEAN,
    job_listing_type STRING,
    listing_source STRING,
    industry_id STRING,
    is_expired_flag BOOLEAN,

    -- Foreign Keys
    advertiser_id STRING,
    location_id STRING,
    classification_id STRING,
    job_type STRING,
    scrape_date_key DATE,
    listing_date_key DATE,
    subclassification_name STRING
);

INSERT INTO SEEK_DATA.PUBLIC.FACT_JOB_POSTINGS (
    job_id,
    snapshot_date,
    listing_date,
    posted_ago,
    job_title,
    job_subtitle,
    job_teaser,
    job_benefits,
    job_highlight_1,
    job_highlight_2,
    job_classification_slug,
    job_processing_code,
    advertiser_logo_url,
    job_salary,
    promoted_flag,
    is_promoted,
    job_listing_type,
    listing_source,
    industry_id,
    is_expired_flag,
    advertiser_id,
    location_id,
    classification_id,
    job_type,
    scrape_date_key,
    listing_date_key,
    subclassification_name
)
SELECT
    job_id,
    snapshot_date,
    listing_date,
    posted_ago,
    job_title,
    job_subtitle,
    job_teaser,
    job_benefits,
    job_highlight_1,
    job_highlight_2,
    job_classification_slug,
    job_processing_code,
    advertiser_logo_url,
    job_salary,
    promoted_flag,
    TRY_CAST(is_promoted AS BOOLEAN),
    job_listing_type,
    listing_source,
    industry_id,
    is_expired_flag,
    advertiser_id,
    MD5(location_name || '-' || location_postcode || '-' || location_region),
    primary_classification_id,
    job_type,
    snapshot_date,
    listing_date,
    subclassification_name
FROM SEEK_DATA.PUBLIC.SEEK_RAW_DATA
WHERE job_id IS NOT NULL;
