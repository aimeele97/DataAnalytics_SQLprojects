-- P1: Sales Trends, State Performance and Sales Patterns

-- 1. What were the total orders, quantity sold, and revenue generated each year?

/* Create VIEW for table combine */
DROP VIEW tbl_combine
CREATE VIEW tbl_combine AS 
    SELECT ord.order_id, ord.customer_id, ord.order_date, Month(ord.order_date) as Month, Year(ord.order_date) as Year, product_id, staff_id, quantity, list_price, discount, final_price, sto.store_id, store_name, city, [state], zip_code
    FROM sales.orders ord
    JOIN sales.order_items ite
        ON ite.order_id = ord.order_id
    JOIN sales.stores sto 
        ON sto.store_id = ord.store_id 

SELECT 
    Year,
    COUNT(order_id) NumberOrders,
    SUM(quantity) Quantity,
    CAST(SUM(final_price) AS NUMERIC(10,2)) TotalRevenue
FROM tbl_combine
GROUP BY Year
ORDER BY Year;

-- 2. How did the monthly revenue accumulate over the analysis period?
WITH monthly_sales AS (
    SELECT
        year,
        month,
        CAST(SUM(final_price) AS NUMERIC (10,2)) total_sales
    FROM tbl_combine
    GROUP BY year, month
)
SELECT 
    year, 
    month, 
    total_sales,
    CAST(SUM(total_sales) OVER (ORDER BY year, month) AS NUMERIC(10,2)) AS accumulative
FROM monthly_sales;

-- 3. What were the monthly sales figures, and how did the growth rate fluctuate month-over-month?
    Month,
    Year,
    CAST(SUM(final_price)AS DECIMAL(10,2)) recent_sale,
    CAST(SUM(final_price) - LAG(SUM(final_price)) OVER (ORDER BY year, Month) AS DECIMAL(10,2)) sale_growth,
    CAST(100 *(SUM(final_price) - LAG(SUM(final_price)) OVER (ORDER BY year, month)) / (SUM(final_price) + LAG(SUM(final_price)) OVER (ORDER BY year, month)) AS DECIMAL(5,2)) growth_rate
FROM tbl_combine
GROUP BY Month, Year
ORDER BY year, growth_rate, month;

-- 4. Which states contributed the highest revenue each year?
WITH group_tbl AS (
    SELECT 
        Year,
        state,
        count(distinct order_id) NumberOrders,
        sum(quantity) Quantity,
        round(sum(final_price), 2) TotalRevenue
    FROM tbl_combine
    GROUP BY state, Year
)
SELECT *,
    ROUND(TotalRevenue / SUM(TotalRevenue) OVER (PARTITION BY year), 2) AS Ratio
FROM group_tbl
ORDER BY year, TotalRevenue desc

-- 5. What were the top three best-selling months for each state?
WITH group_tbl AS (
    SELECT 
        Month,
        Year,
        State,
        COUNT(distinct order_id) NumberOrders,
        SUM(quantity) Quantity,
        CAST(SUM(final_price) AS NUMERIC (10,2)) TotalRevenue
    FROM tbl_combine
    GROUP BY state, Year, Month
)
, tbl_rank AS (
    SELECT * ,
        CAST(TotalRevenue / SUM(TotalRevenue) OVER (PARTITION BY year) AS NUMERIC (2,2)) AS Ratio,
        RANK() OVER (PARTITION BY year ORDER BY TotalRevenue desc) rank
    FROM group_tbl
)
SELECT *
FROM tbl_rank
WHERE rank <=3

-- 6. Which three months had the highest performance (in terms of revenue) for each state?
WITH ranked_orders AS (
    SELECT state, Month, Year,
           COUNT(DISTINCT order_id) AS NumberOrders,
           SUM(quantity) AS Quantity,
           ROUND(SUM(final_price), 2) AS TotalRevenue,
           ROW_NUMBER() OVER (PARTITION BY year, state ORDER BY SUM(final_price) DESC) AS row_number
    FROM tbl_combine
    GROUP BY state, Year, Month
)
SELECT state, Month, Year, NumberOrders, Quantity, TotalRevenue
FROM ranked_orders
WHERE row_number < 4
ORDER BY state, year;

-- 7. What are the sales patterns observed across different weekdays?
WITH tbl_row AS (
SELECT year,
    State,
    DATENAME(weekday, order_date) AS Date,
    COUNT(DISTINCT order_id) AS num_orders,
    ROUND(CAST(SUM(final_price) AS FLOAT), 2) AS total_sales,
    ROW_NUMBER() OVER (PARTITION BY year, state ORDER BY SUM(final_price) desc) row_number
FROM tbl_combine
GROUP BY DATENAME(weekday, order_date), year, State
)
SELECT YEAR, state, Date, num_orders, total_sales
FROM tbl_row 
WHERE row_number < 4
order by state, year;

