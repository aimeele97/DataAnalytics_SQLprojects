-- P3: Customer Insights

-- 10. How does customer segmentation (based on RFM analysis) impact overall sales performance?

WITH tbl_rfm AS (
    SELECT 
        customer_id,
        DATEDIFF(day, MAX(order_date), '2018-12-28') AS recency,
        COUNT(order_id) AS frequency,
        ROUND(SUM(CAST(final_price AS FLOAT)), 2) AS monetary
    FROM tbl_combine
    GROUP BY customer_id
)
/* Calculate the percentile rank for each RFM metric */
, tbl_rank AS (
    SELECT *,
        PERCENT_RANK() OVER (ORDER BY recency) AS r_rank,
        PERCENT_RANK() OVER (ORDER BY frequency) AS f_rank,
        PERCENT_RANK() OVER (ORDER BY monetary) AS m_rank
    FROM tbl_rfm
)
/*  Categorize customers into tiers based on RFM scores */
, tbl_tier AS (
    SELECT *,
        CASE 
            WHEN r_rank <= 0.25 THEN 1
            WHEN r_rank <= 0.5 THEN 2
            WHEN r_rank <= 0.75 THEN 3
            ELSE 4 
        END AS r_tier,
        CASE 
            WHEN f_rank <= 0.25 THEN 1
            WHEN f_rank <= 0.5 THEN 2
            WHEN f_rank <= 0.75 THEN 3
            ELSE 4 
        END AS f_tier,
        CASE 
            WHEN m_rank <= 0.25 THEN 1
            WHEN m_rank <= 0.5 THEN 2
            WHEN m_rank <= 0.75 THEN 3
            ELSE 4 
        END AS m_tier
    FROM tbl_rank
)
/*Combine tiers to create an RFM score and segment customers*/
, tbl_score AS (
    SELECT *, 
        CONCAT(r_tier, f_tier, m_tier) AS rfm_score
    FROM tbl_tier
)
/* Segment customers based on their RFM score*/
, tbl_seg AS (
    SELECT 
        customer_id,
        CASE 
            WHEN rfm_score = '444' THEN 'Best customers'
            WHEN rfm_score LIKE '4[1-3][1-3]' THEN 'New customers'
            WHEN rfm_score LIKE '[1-3]4[1-3]' THEN 'Loyal customers'
            WHEN rfm_score LIKE '[1-3][1-3]4' THEN 'High paying customers'
            WHEN rfm_score LIKE '44[1-3]' THEN 'New and regular customers'
            WHEN rfm_score LIKE '[1-3]44' THEN 'Regular high paying customers'
            WHEN rfm_score LIKE '4[1-3]4' THEN 'New high paying customers'
            WHEN rfm_score = '111' THEN 'Low-value customers'
            ELSE 'Normal customers' 
        END AS cus_segment 
    FROM tbl_score
)
/* Aggregate and calculate the proportion of each customer segment*/
, tbl_segment AS (
    SELECT 
        cus_segment,
        COUNT(customer_id) AS NumberOfCustomer
    FROM tbl_seg
    GROUP BY cus_segment
)
/* Display the customer segments along with their ratio */
SELECT *,
    ROUND(CAST(NumberOfCustomer AS FLOAT) / SUM(NumberOfCustomer) OVER (), 2) AS Percentage
FROM tbl_segment;






