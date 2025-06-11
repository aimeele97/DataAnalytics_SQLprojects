-- USE SUPERSTORE DATA
-- 1. Top 10 products with the highest number of returned products?

use superstore;

select Product_ID,  Product_Name, 
	sum(Quantity) as total_returned_products
from superstore.Orders o
join superstore.Returns r 
on o.Order_ID = r.Order_ID 
group by Product_ID, Product_Name
order by total_returned_products desc
limit 10;

-- 2. Top 10 cities with highest Sales per returned order?

select o.City,
	sum(Sales) as total_refund,
    count(distinct r.Order_ID) as no_return_orders,
    round(sum(Sales) / count(distinct r.Order_ID), 2) as sale_per_rorders
from superstore.Orders o
join superstore.Returns r 
on o.Order_ID = r.Order_ID 
group by o.City
order by sale_per_rorders desc
limit 10;

-- 3. Get a list of all customers that have returned at least 1 order. In this list, we need following information
-- Name
-- Customer ID
-- Segment
-- Number of returned orders
-- Total Sales of Returned orders

select o.Customer_Name, Customer_ID, o.Segment,
	count(distinct r.Order_ID) as total_returned_orders,
    sum(o.Sales) as total_sale_returned_orders
from superstore.Orders o
join superstore.Returns r 
on o.Order_ID = r.Order_ID 
group by o.Customer_Name, Customer_ID, o.Segment;

-- Use Bookshop database
-- 1. Get AVG Rating and Number of Rating per Book

use bookshop;

select bo.BookID, bo.Title,
	round(avg(ra.Rating), 1) as avg_rating,
    count(distinct ra.ReviewID) as number_reviews
from bookshop.rating ra
right join bookshop.books bo 
on ra.BookID = bo.BookID
group by bo.BookID, bo.Title;

-- 2. Get AVG rating and Number of Rating per Author

select au.AuthID, au.`First Name`,
	round(avg(ra.Rating), 1) as avg_rating
from bookshop.rating ra
right join bookshop.books bo 
on ra.BookID = bo.BookID
right join bookshop.authors au
on bo.AuthID = au.AuthID
group by au.AuthID, au.`First Name`;

-- 3. Get Number of Books (items) Sold and Total Sales Q1 of all books

select count(distinct q1.ItemID) total_item_sold,
	concat('$', round(sum(ed.Price * (1-q1.Discount)), 1)) total_sale
from  bookshop.sales_q1 q1
join bookshop.edition ed
on q1.ISBN = ed.ISBN;

-- 4. How many copies of AWARDED books have been sold in Q1 and total sales of each book?

SELECT 
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bookshop';

select bo.BookID, bo.Title,
	count(distinct q1.ItemID) as number_sold,
	concat('$', round(sum(ed.Price * (1-q1.Discount)), 1)) total_sale
from  bookshop.sales_q1 q1
join bookshop.edition ed
on q1.ISBN = ed.ISBN
join bookshop.books bo
on ed.BookID = bo.BookID
join bookshop.award aw
on bo.Title = aw.Title
group by bo.BookID, bo.Title;

-- 5. Top 3 Book Genre each month in Q1 in terms of number of book sold.

with cte as (
select 
	distinct MONTH(STR_TO_DATE(q1.`Sale Date`, '%d/%m/%Y')) as mon,
    inf.genre,
    count( distinct q1.ItemID) as number_of_sold,
    dense_rank() over (partition by MONTH(STR_TO_DATE(q1.`Sale Date`, '%d/%m/%Y')) order by count(distinct q1.ItemID) desc) top
from bookshop.info inf
join bookshop.books bo
on concat(inf.BookID1,inf.BookID2) = bo.BookID
join edition ed
on bo.BookID = ed.BookID
join sales_q1 q1 
on q1.ISBN = ed.ISBN
group by mon, inf.genre
)
select *
from cte 
where top <= 3








