use real_estate;

DELETE FROM real_estate.fact_daily_listing
WHERE listing_price < 1000;

desc real_estate.fact_daily_listing;

# total properties, avg posted listings per day, total new listing
select 
    count(f.listing_id) as total_daily_listings_records,
    count(distinct f.listing_id) as total_unique_listings,
    round(
        count(distinct concat(f.snapshot_date, f.listing_id)) 
        / count(distinct date(f.snapshot_date))
    ) as avg_listing_per_day,
    count(distinct case 
        when date(f.first_go_live) between 
             (select min(snapshot_date) from real_estate.fact_daily_listing) and 
             (select max(snapshot_date) from real_estate.fact_daily_listing)
        then f.listing_id 
    end) as new_listings_live_within_snapshot_range,
    count(distinct agent_id) as number_agents,
    count(distinct snapshot_date) number_snapshop_day
from real_estate.fact_daily_listing f;

# number of sold listings

select count( distinct listing_id) number_sold
from real_estate.dim_listing 
where listing_status = 'archived';

# top 5 agent are actively listings

select agent_id,
	count(distinct listing_id) number_units
from real_estate.fact_daily_listing
group by agent_id
order by number_units desc
limit 10;

# median listing price

select 
	round(avg(listing_price)) as median_price
from (
select listing_price,
	row_number() over(order by
    listing_price asc, listing_id asc) rowasc,
    row_number() over(order by listing_price desc, listing_id desc) rowdesc
from real_estate.fact_daily_listing
order by listing_price) temp
where
   rowasc IN (rowdesc, rowdesc - 1, rowdesc + 1);

# number of inspections of property before sold

with cte as (
select fac.listing_id, lis.listing_status,
	count(distinct concat(fac.listing_id,inspection_1_start_time)) as number_inspection
from real_estate.fact_daily_listing fac
join real_estate.dim_listing lis
on fac.listing_id = lis.listing_id
group by fac.listing_id, lis.listing_status
having lis.listing_status = 'archived'
)
select number_inspection,
	count(distinct listing_id) as total_units,
    sum(count(distinct listing_id)) over () as total_sold
from cte
group by number_inspection
order by number_inspection;

# percent of total inspection 

with cte as (
select fac.listing_id, lis.listing_status,
	count(distinct concat(fac.listing_id,inspection_1_start_time)) as number_inspection
from real_estate.fact_daily_listing fac
join real_estate.dim_listing lis
on fac.listing_id = lis.listing_id
group by fac.listing_id, lis.listing_status
having lis.listing_status = 'archived'
)
, cte1 as (
select number_inspection,
	count(distinct listing_id) as total_units,
	sum(count(distinct listing_id)) over (order by number_inspection) running_total_inspection
from cte
group by number_inspection
order by number_inspection
)
select *,
	running_total_inspection / sum(total_units) over () * 100 per_total
from cte1;

-- more than 80% of property has at most 5 inspections prior to sold

# median price and day stay on the market by property types prior to sold

with cte as (
    select 
        lis.listing_suburb,
        lis.listing_id, 
        lis.listing_status,
        lis.property_type,
        lis.listing_price,
        datediff(lis.last_visible_date, lis.first_go_live) as day_on_market
    from real_estate.fact_daily_listing fac
    join real_estate.dim_listing lis
        on fac.listing_id = lis.listing_id
    where lis.listing_status = 'archived'
)
select 
    listing_suburb,
    property_type, 
    day_on_market,
    listing_price
from ( 
    select 
        listing_suburb,
        property_type,
        day_on_market,
        listing_price,
        row_number() over (
            partition by listing_suburb, property_type 
            order by day_on_market, listing_price, listing_id
        ) as rowasc,
        row_number() over (
            partition by listing_suburb, property_type 
            order by day_on_market desc, listing_price desc, listing_id desc
        ) as rowdesc
from cte) temp
where rowasc in (rowdesc, rowdesc - 1, rowdesc + 1)
group by listing_suburb,
    property_type, 
    day_on_market,
    listing_price
    order by listing_suburb, property_type;

-- houses sold fastest 

# number of auctions by status

select auction_status,
	count(distinct listing_id) as number_auctions,
    count(distinct listing_id) / sum(count(distinct listing_id)) over () *100 as per_total
from real_estate.dim_auction
group by auction_status;

# number of time that listing change price

select distinct time_price_change, count(distinct listing_id) number_unique_listings
from (
select listing_id, count(distinct last_price_change) time_price_change
from real_estate.fact_daily_listing
group by listing_id) temp
group by time_price_change
order by time_price_change;

# list of unique listings with price change over time

with cte as (
	select listing_id, agent_id,count(distinct listing_price_view) time_price_change
	from real_estate.fact_daily_listing
	group by listing_id, agent_id
    having count(distinct listing_price_view) > 1 
)
select cte.listing_id,f.agent_id, f.first_go_live, f.last_price_change ,f.listing_price_view
from real_estate.fact_daily_listing f 
join cte
on cte.listing_id = f.listing_id
group by cte.listing_id,f.agent_id, f.first_go_live, f.last_price_change, f.listing_price_view
order by cte.listing_id, first_go_live;


