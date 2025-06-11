# Analyzing Bike Store Revenue - Sales trends analysis

![Bike Store Logo](https://github.com/Aimee-Le/BikeStoreAnalysis/blob/main/logomain.png)

__Problem Statement__:
In the competitive retail sector, making data-driven decisions is essential. This analysis focuses on sales trends at a bicycle store from 2016 to 2018 by identifying business problems and offering actionable insights into sales data to facilitate effective decision-making and foster growth.

## Objectives of the Analysis
- **Revenue Insights**: Analyze overall revenue trends, key growth drivers, and top-performing sales channels.
- **Product Performance**: Evaluate how different categories, brands, and individual products performed.
- **Customer Segmentation**: Identifying your most valuable customers, analyzing their behavior, and tailoring your approach to engage them more effectively, ultimately boosting customer engagement, retention, and profitability.

## The steps

- Data collection: Downloading and importing relevant CSV files into a database using Azure Data Studio.
- Define key questions: Identify business challenges, and formulate key analytical questions to guide the analysis.
- Data cleaning: Ensuring accuracy by correcting data types, handling null values, and removing irrelevant columns.
- Data Analysis: Answering business questions, provide the key insights. Also focusing on optimizing SQL queries performance.

## Dataset Information

The data used for this analysis comes from a sample provided in the [SQL Server Tutorial](http://www.sqlservertutorial.net/load-sample-database/).

## Business Questions 

The analysis focused on ten key business questions, including:

1. What were the total orders, quantity sold, and revenue generated each year?
2. How did the monthly revenue accumulate over the analysis period?
3. What were the monthly sales figures, and how did the growth rate fluctuate month-over-month?
4. Which states contributed the highest revenue each year?
5. What were the top three best-selling months for each state?
6. Which three months had the highest performance (in terms of revenue) for each state?
7. What are the sales patterns observed across different weekdays?
8. Which product categories performed the best in terms of sales?
9. What are the top three bikes sold in each product category?
10. How does customer segmentation (based on RFM analysis) impact overall sales performance?

## Sample SQL Queries Used in the Analysis

__What were the total orders, quantity sold, and revenue generated each year?__

```sql
SELECT 
    Year,
    COUNT(order_id) AS NumberOrders,
    SUM(quantity) AS Quantity,
    CAST(SUM(final_price) AS NUMERIC(10,2)) AS TotalRevenue
FROM tbl_combine
GROUP BY Year
ORDER BY Year;
```

__How did the monthly revenue accumulate over the analysis period?__

```sql
WITH monthly_sales AS (
    SELECT
        year,
        month,
        CAST(SUM(final_price) AS NUMERIC(10,2)) AS total_sales
    FROM tbl_combine
    GROUP BY year, month
)
SELECT 
    year, 
    month, 
    total_sales,
    CAST(SUM(total_sales) OVER (ORDER BY year, month) AS NUMERIC(10,2)) AS accumulative
FROM monthly_sales;
```

__How does customer segmentation (based on RFM analysis) impact overall sales performance?__

```sql
WITH tbl_rfm AS (
    SELECT 
        customer_id,
        DATEDIFF(day, MAX(order_date), '2018-12-28') AS recency,
        COUNT(order_id) AS frequency,
        ROUND(SUM(CAST(final_price AS FLOAT)), 2) AS monetary
    FROM tbl_combine
    GROUP BY customer_id
),
tbl_rank AS (
    SELECT *,
        PERCENT_RANK() OVER (ORDER BY recency) AS r_rank,
        PERCENT_RANK() OVER (ORDER BY frequency) AS f_rank,
        PERCENT_RANK() OVER (ORDER BY monetary) AS m_rank
    FROM tbl_rfm
),
tbl_tier AS (
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
SELECT 
    CONCAT(r_tier, f_tier, m_tier) AS rfm_score,
    COUNT(customer_id) AS NumberOfCustomer
FROM tbl_tier
GROUP BY rfm_score;
```

