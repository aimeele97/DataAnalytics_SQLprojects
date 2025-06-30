-- Summary: Number of postings, unique jobs, advertisers, locations, and date range
SELECT
    COUNT(*) AS total_posting,
    COUNT(DISTINCT job_id) AS total_job,
    COUNT(DISTINCT advertiser_id) AS total_company,
    COUNT(DISTINCT location_id) AS number_location,
    MIN(snapshot_date) AS min_date,
    MAX(snapshot_date) AS max_date
FROM
    SEEK_DATA.PUBLIC.fact_job_postings;
-- Daily listing trend
SELECT
    listing_date,
    COUNT(DISTINCT job_id) AS daily_postings
FROM
    seek_data.public.fact_job_postings
GROUP BY
    listing_date;
-- Duration (in days) each job was listed
    WITH latest_snapshot AS (
        SELECT
            job_id,
            MAX(snapshot_date) AS max_snapshot_date
        FROM
            seek_data.public.fact_job_postings
        GROUP BY
            job_id
    )
SELECT
    f.job_id,
    f.listing_date,
    l.max_snapshot_date,
    DATEDIFF('day', f.listing_date, l.max_snapshot_date) AS day_listing
FROM
    seek_data.public.fact_job_postings f
    JOIN latest_snapshot l ON f.job_id = l.job_id
WHERE
    f.snapshot_date != l.max_snapshot_date
ORDER BY
    day_listing DESC NULLS LAST;
-- Analyst jobs broken down by junior, senior, and total counts with percentages
SELECT
    COUNT(
        DISTINCT CASE
            WHEN (
                LOWER(job_title) LIKE '%junior%'
                AND LOWER(job_title) LIKE '%analyst%'
            )
            OR (
                LOWER(job_title) LIKE '%associate%'
                AND LOWER(job_title) LIKE '%analyst%'
            ) THEN job_id
        END
    ) AS junior_analyst_job,
    COUNT(
        DISTINCT CASE
            WHEN LOWER(job_title) LIKE '%senior%'
            AND LOWER(job_title) LIKE '%analyst%' THEN job_id
        END
    ) AS senior_analyst_job,
    COUNT(
        DISTINCT CASE
            WHEN LOWER(job_title) LIKE '%analyst%' THEN job_id
        END
    ) AS total_analyst_job
FROM
    SEEK_DATA.PUBLIC.fact_job_postings;
-- Top advertisers hiring for analyst positions
SELECT
    advertiser_name,
    COUNT(DISTINCT job_title) AS number_postings
FROM
    SEEK_DATA.PUBLIC.fact_job_postings f
    JOIN SEEK_DATA.PUBLIC.DIM_ADVERTISER a ON f.advertiser_id = a.advertiser_id
WHERE
    LOWER(f.job_title) LIKE '%analyst%'
GROUP BY
    advertiser_name
ORDER BY
    number_postings DESC;
-- Distribution of number of postings per advertiser
SELECT
    number_postings,
    COUNT(advertiser_name) AS number_advertisers,
    number_advertisers / SUM(number_advertisers) OVER() * 100 AS percent_total
FROM
    (
        SELECT
            advertiser_name,
            COUNT(DISTINCT job_title) AS number_postings
        FROM
            SEEK_DATA.PUBLIC.fact_job_postings f
            JOIN SEEK_DATA.PUBLIC.DIM_ADVERTISER a ON f.advertiser_id = a.advertiser_id
        WHERE
            LOWER(f.job_title) LIKE '%analyst%'
        GROUP BY
            advertiser_name
    ) temp
GROUP BY
    number_postings
ORDER BY
    number_postings DESC;
-- Analyst jobs marked as promoted (e.g., urgent hiring)
SELECT
    COUNT(
        DISTINCT CASE
            WHEN is_promoted = 'True' THEN job_id
        END
    ) AS analyst_job_promote,
    COUNT(DISTINCT job_id) AS total_analyst_job,
    COUNT(
        DISTINCT CASE
            WHEN is_promoted = 'True' THEN job_id
        END
    ) * 100.0 / COUNT(DISTINCT job_id) AS percent_total
FROM
    SEEK_DATA.PUBLIC.fact_job_postings f
    JOIN SEEK_DATA.PUBLIC.DIM_ADVERTISER a ON f.advertiser_id = a.advertiser_id
WHERE
    LOWER(job_title) LIKE '%analyst%';
-- Number of analyst jobs by Australian state
SELECT
    SUBSTRING(
        region,
        LEN(region) - CHARINDEX(' ', REVERSE(region)) + 2
    ) AS state,
    COUNT(DISTINCT job_id) AS number_postings,
    COUNT(DISTINCT job_id) * 100.0 / SUM(COUNT(DISTINCT job_id)) OVER() AS percent_total
FROM
    SEEK_DATA.PUBLIC.fact_job_postings f
    JOIN SEEK_DATA.PUBLIC.dim_location l ON f.location_id = l.location_id
WHERE
    LOWER(job_title) LIKE '%analyst%'
GROUP BY
    state
ORDER BY
    number_postings DESC;
-- Top posting regions in each state (regions with above-average postings)
    WITH region_postings AS (
        SELECT
            SUBSTRING(
                region,
                LEN(region) - CHARINDEX(' ', REVERSE(region)) + 2
            ) AS state,
            region,
            COUNT(DISTINCT job_id) AS number_postings
        FROM
            SEEK_DATA.PUBLIC.fact_job_postings f
            JOIN SEEK_DATA.PUBLIC.dim_location l ON f.location_id = l.location_id
        WHERE
            LOWER(job_title) LIKE '%analyst%'
        GROUP BY
            SUBSTRING(
                region,
                LEN(region) - CHARINDEX(' ', REVERSE(region)) + 2
            ),
            region
    ),
    region_with_avg AS (
        SELECT
            *,
            AVG(number_postings) OVER (PARTITION BY state) AS avg_postings,
            COUNT(number_postings) OVER (PARTITION BY state) AS total_regions,
            number_postings * 100.0 / SUM(number_postings) OVER (PARTITION BY state) AS percent_total_state
        FROM
            region_postings
    )
SELECT
    *
FROM
    region_with_avg
WHERE
    number_postings >= avg_postings
ORDER BY
    state,
    number_postings DESC;
-- Total and average new postings per day for analyst jobs
    WITH snapshot_range AS (
        SELECT
            MIN(snapshot_date) AS min_snapshot,
            MAX(snapshot_date) AS max_snapshot
        FROM
            seek_data.public.fact_job_postings
    )
SELECT
    COUNT(DISTINCT job_id) AS job_count,
    ROUND(
        COUNT(DISTINCT job_id) / COUNT(DISTINCT listing_date)
    ) AS avg_postings_per_day
FROM
    seek_data.public.fact_job_postings f
    JOIN snapshot_range s ON f.listing_date BETWEEN s.min_snapshot
    AND s.max_snapshot
WHERE
    LOWER(job_title) LIKE '%analyst%';
-- Job counts by contract type and working model
SELECT
    job_type AS category,
    COUNT(DISTINCT job_id) AS job_count,
    'job_type' AS category_type
FROM
    seek_data.public.dim_job_type
GROUP BY
    job_type
UNION ALL
SELECT
    work_location_type AS category,
    COUNT(DISTINCT job_id) AS job_count,
    'work_location_type' AS category_type
FROM
    seek_data.public.dim_job_type
GROUP BY
    work_location_type;
-- Average job postings on each weekday
SELECT
    TO_CHAR(listing_date, 'DY') AS weekday,
    ROUND(
        COUNT(DISTINCT job_id) / COUNT(DISTINCT snapshot_date)
    ) AS avg_postings
FROM
    seek_data.public.fact_job_postings
GROUP BY
    weekday
ORDER BY
    avg_postings DESC;
-- Job postings by industry (classification)
SELECT
    classification_name AS industry,
    COUNT(DISTINCT job_id) AS number_postings
FROM
    seek_data.public.fact_job_postings f
    JOIN seek_data.public.dim_classification c ON f.classification_id = c.classification_id
WHERE
    LOWER(job_title) LIKE '%analyst%'
GROUP BY
    classification_name,
    subclassification_name
ORDER BY
    number_postings DESC;
-- Job postings by field (subclassification)
SELECT
    subclassification_name AS field,
    COUNT(DISTINCT job_id) AS number_postings
FROM
    seek_data.public.fact_job_postings f
    JOIN seek_data.public.dim_classification c ON f.classification_id = c.classification_id
WHERE
    LOWER(job_title) LIKE '%analyst%'
GROUP BY
    field
ORDER BY
    number_postings DESC;