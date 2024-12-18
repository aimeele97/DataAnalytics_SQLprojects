-- P2: Product Performance

/* Create VIEW to aggregate product sales details*/
CREATE VIEW product_sales_details AS 
SELECT 
    pro.product_id,
    pro.product_name,
    cat.category_id,
    cat.category_name,
    bra.brand_id,
    bra.brand_name,
    pro.model_year,
    ite.list_price,
    SUM(ite.quantity) AS total_quantity,
    ROUND(CAST(SUM(final_price) AS FLOAT), 2) AS total_sales
FROM sales.order_items ite
JOIN production.products pro
    ON ite.product_id = pro.product_id
JOIN production.categories cat 
    ON cat.category_id = pro.category_id
JOIN production.brands bra 
    ON bra.brand_id = pro.brand_id
GROUP BY 
    pro.product_id,
    pro.product_name,
    cat.category_id,
    cat.category_name,
    bra.brand_id,
    bra.brand_name,
    pro.model_year,
    ite.list_price;

-- 8. Which product categories performed the best in terms of sales?
with tbl as (
    SELECT category_name, 
        SUM(total_quantity) total_quantity
    FROM product_sales_details
    GROUP BY category_name
)
select *,
cast(total_quantity as float) / sum(total_quantity) over ()
from tbl

-- 9. What are the top three bikes sold in each product category?
WITH quantity_ratio_per_category AS (
    SELECT 
        product_name,
        category_name,
        brand_name,
        total_quantity,
        CAST(100 * CAST(total_quantity AS FLOAT) / SUM(total_quantity) OVER (PARTITION BY category_name) as numeric(5,2)) ratio
    FROM dbo.product_sales_details
)
,ranked_quantity AS (
    SELECT 
        category_name, 
        product_name, 
        brand_name,
        total_quantity,
        ratio,
        ROW_NUMBER() OVER (PARTITION BY category_name ORDER BY ratio DESC) AS rank
    FROM quantity_ratio_per_category
)
SELECT category_name, product_name, brand_name, brand_name, total_quantity, concat(ratio, '%')
FROM ranked_quantity
WHERE rank <= 3;
