-- NOTE: 
-- Try to use both Subquery & With to solve these questions
-- Step by step. Thinking about the way & flow of doing before coding. 
-- Try to break down the big question into small ones then join them together at the end.
-- Using Superstore database

-- 1. Return the list of all unique products in each Sub-Category that have
-- - Product ID, Product Sub category, Product Price
-- 	Product price = sales/quantity 
-- - Avg sub-category product price using unique product prices from above results in each sub-category (Not sales)
-- - A column saying that if product price is greater or less than AVG Sub-category price 
-- * Note: Check discounts because they affect the Sales values. We need the original Sales Price. Use Round() function if needed
-- Example outcome

use superstore;

with price as (
	select Product_ID, Sub_Category, 
		round((Sales/(1-discount))/ Quantity, 2) as price
	from superstore.orders
)
, price_unique as (
	select distinct Product_ID, Sub_Category, price
    from price 
)
, avg_price as (
	select Sub_Category, 
		avg(price) as avg_price
	from price_unique
	group by Sub_Category
)
select *,	
	case when un.price < av.avg_price then 'lower'
    when un.price > av.avg_price then 'higher'
    end as categorize
from price_unique un
left join avg_price av
on un.Sub_Category = av.Sub_Category;

-- 2. Using Orders table. Return the list of all unique customer in each region that have
-- - Segment, Customer ID, Customer Name, Total Orders, Total Technology Sales, Total Office Supply Sales, Total Furniture Sales, Total Sales
-- - AVG Number Orders per customer, and AVG Total Sales per Customer in each region
-- - Max & Min Total Number Orders per customer
-- - Max & Min Total Sales per Customer in each region
-- - only keep customers that have either ONE of these condition
-- 	+ Total Number Orders = Min/Max Total Number Orders per customer in each region
-- 	+ Total Sales within the range of +/- 10% of AVG Total Sales per Customer in each region  
-- * Guide:
-- We would need to aggregate per region and per customer first
-- Use Where to filter data
-- Final result would be just a list of Customers with a bunch of other columns. One customer, one row.

use superstore;
with customer_details as (
	select  Segment, 
			Customer_ID, 
			Customer_Name, 
			Order_ID,
			case when Category = 'Technology' then Sales end as tech,
			case when Category = 'Office Supplies' then Sales end as ofi,
			case when Category = 'Furniture' then Sales end as furn,
			Sales
	from superstore.orders
 )
 , cus_info as (
	select distinct Customer_ID, Country
    from superstore.orders
)
 , customer_sale as (
	 select Segment, 
			Customer_ID, 
			Customer_Name, 
			count(distinct Order_ID) total_orders,
			sum(tech) te_sale,
			sum(ofi) of_sale,
			sum(furn) fu_sale,
			sum(Sales) total_sale
	 from customer_details
	 group by Segment, 
			Customer_ID, 
			Customer_Name
)
, segment_cus as (
select segment,
	avg(total_orders) as avg_order,
    avg(total_sale) as avg_sale,
    min(total_orders) as min_order,
    max(total_orders) as max_order,
    min(total_sale) as min_sale,
    max(total_sale) as max_sale
from customer_sale
group by segment
)
select *
from cus_info i
left join customer_sale c
on i.Customer_ID = c.Customer_ID
left join segment_cus s
on c.segment = s.segment
where (total_orders = min_order or total_orders = max_order) or (total_sale between avg_sale*0.9 and avg_sale * 1.1);

-- Using Classicmodel database
-- Spend some time to understand each table first and find the connections between them.
-- Drawing a connection diagram similar to a Bookshop Diagram would be helpful. This one is called ERD (Entity Relationship Diagram)

-- 3. Get list of all customers with following information 
-- - Sales Rep details + Sales Manager details
-- - Office Details
-- - Customer full details
-- - Latest order Date
-- - Latest order value
-- - Number of Orders
-- - Total Sales
-- - AVG Sales Per customer in of Each Sales Rep
-- - Compare Customer Total Sales with AVG Sales per Customer and flag them
-- 	+ Upper Class if Total sales greater than AVG + 10%
-- 	+ Middle Class if Total sales between AVG +/- 10%
-- 	+ Lower Class if Total sales less than AVG - 10%

with cus_info as (
	select 
		c.*,
		-- employee (sales rep) columns
		e.employeeNumber   as rep_employeeNumber,
		e.lastName         as rep_lastName,
		e.firstName        as rep_firstName,
		e.extension        as rep_extension,
		e.email            as rep_email,
		e.jobTitle         as rep_jobTitle,
        e.officeCode       as rep_officeCode,
		-- rep office columns
        o.city as office_city,
        o.phone as office_phone,
        o.addressLine1 as office_add1,
        o.addressLine2 as office_add2,
        o.state as office_state,
        o.country as office_country,
        o.postalCode as office_postcode,
        o.territory as office_territory,
		-- manager columns
		e.reportsTo        as rep_reportsTo,
        m.employeeNumber   as mgr_employeeNumber,
		m.lastName         as mgr_lastName,
		m.firstName        as mgr_firstName,
		m.extension        as mgr_extension,
		m.email            as mgr_email,
		m.officeCode       as mgr_officeCode,
		m.reportsTo        as mgr_reportsTo,
		m.jobTitle         as mgr_jobTitle
	from classicmodels.customers c 
	left join classicmodels.employees e
		on e.employeeNumber = c.salesRepEmployeeNumber
	left join classicmodels.offices o 
		on o.officeCode = e.officeCode
	left join classicmodels.employees m
		on e.reportsTo = m.employeeNumber
)
, max_ord_date as (
	select customerNumber, max(orderDate) as max_order_date
	from classicmodels.orders
    group by customerNumber
)
, order_date_no as (
	select m.customerNumber, m.max_order_date, o.orderNumber
    from max_ord_date m
    left join classicmodels.orders o
    on m.customerNumber = o.customerNumber and m.max_order_date = o.orderDate
)
, latest_order as ( 
	select da.customerNumber, da.orderNumber as lastest_order_number,da.max_order_date as latest_order_date,  sum(quantityOrdered*priceEach) as lastest_order_value
	from order_date_no da
	left join classicmodels.orderdetails de
	on da.orderNumber = de.orderNumber
	group by da.customerNumber, latest_order_date, da.orderNumber
)
, total_sale as (
	select ord.customerNumber, count(distinct ord.orderNumber) as total_order, sum(de.quantityOrdered*de.priceEach) as total_sale
	from classicmodels.orders ord
	left join classicmodels.orderdetails de
		on ord.orderNumber = de.orderNumber
	group by ord.customerNumber
)
, rep_sale as (
	select c.rep_employeeNumber, avg(total_sale) avg_sale_perCus
	from cus_info c
	left join total_sale t
	on c.customerNumber = t.customerNumber 
	group by c.rep_employeeNumber
) 
select *,
	case when total_sale > avg_sale_perCus*1.1 then 'upper class'
		when total_sale < avg_sale_perCus*0.9 then 'lower class'
        when avg_sale_perCus*0.9 < total_sale < avg_sale_perCus*1.1 then 'middle class'
        end as cus_segment
from cus_info c
left join latest_order l
	on c.customerNumber = l.customerNumber 
left join total_sale s
	on s.customerNumber = l.customerNumber 
left join rep_sale rs 
	on rs.rep_employeeNumber = c.rep_employeeNumber
order by c.rep_employeeNumber desc, c.customerNumber
;
