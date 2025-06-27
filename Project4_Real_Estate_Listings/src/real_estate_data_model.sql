-- Drop and create database
DROP DATABASE IF EXISTS real_estate_listings;
CREATE DATABASE IF NOT EXISTS real_estate_listings;
USE real_estate_listings;

-- Drop and create raw table
DROP TABLE IF EXISTS real_estate_listings.raw_tbl;
CREATE TABLE raw_tbl (
select *
from real_estate.fact_listing);


-- Drop existing tables (in dependency order)
DROP TABLE IF EXISTS daily_snapshot;
DROP TABLE IF EXISTS inspection_detail;
DROP TABLE IF EXISTS auction_detail;
DROP TABLE IF EXISTS listing_detail;
DROP TABLE IF EXISTS agent_detail;
DROP TABLE IF EXISTS office_detail;

-- Dimension: agent_detail
CREATE TABLE agent_detail (
    agent_id INT,
    agent_name TEXT,
    agent_phone TEXT,
    agent_job_title TEXT,
    agent_is_live INT,
    agent_inserted_at TEXT,
    agent_last_visible_date TEXT,
    agent_slug TEXT,
    agent_private_lister INT,
    agent_rei_membership TEXT,
    agent_selling_classification TEXT,
    agent_office_phone TEXT
);

-- Dimension: office_detail
CREATE TABLE office_detail (
    office_id INT,
    office_name TEXT,
    office_address TEXT,
    office_phone TEXT,
    office_logo TEXT,
    office_postcode TEXT,
    office_state TEXT,
    office_suburb TEXT,
    office_website_url TEXT,
    office_is_live INT,
    office_inserted_at TEXT,
    office_last_visible_date TEXT
);

-- Dimension: listing_detail
CREATE TABLE listing_detail (
    listing_id INT,
    listing_status TEXT,
    price_range_min INT,
    price_range_max INT,
    listing_price INT,
    listing_price_view TEXT,
    listing_created_at TEXT,
    listing_updated_at TEXT,
    listing_inserted_at TEXT,
    last_price_change TEXT,
    is_under_offer INT,
    is_price_display INT,
    under_offer_date TEXT,
    first_go_live TEXT,
    commercial_authority TEXT,
    authority TEXT,
    agent_id INT,
    bedrooms INT,
	bathrooms INT,
	parking INT,
	energy_rating DOUBLE,
	is_prestige INT,
	has_virtual_tour INT,
	has_study INT,
	is_furnished INT,
	is_private_listing INT,
	show_on_map INT,
	listing_area DOUBLE,
	area_unit TEXT,
	buildingdetails_area DOUBLE,
	buildingdetails_area_unit TEXT,
	listing_authority TEXT
);

-- Dimension: auction_detail
CREATE TABLE auction_detail (
    listing_id INT,
    auction_type TEXT,
    auction_date TEXT,
    auction_status TEXT
);

-- Dimension: inspection_detail
CREATE TABLE inspection_detail (
    listing_id INT,
    inspection_1_start_time TEXT,
    inspection_1_end_time TEXT,
    inspection_2_start_time TEXT,
    inspection_2_end_time TEXT
);

-- Fact: daily_snapshot
CREATE TABLE daily_snapshot (
    snapshot_date TEXT,
    listing_id INT,
	property_type TEXT,
    listing_price INT,
	price_range_min INT,
    price_range_max INT,
    listing_price_view TEXT,
    last_price_change TEXT,
    is_under_offer INT,
    is_price_display INT,
    under_offer_date TEXT,
    listing_created_at TEXT,
    listing_updated_at TEXT,
    listing_inserted_at TEXT,
    first_go_live TEXT,
    commercial_authority TEXT,
    authority TEXT,
    agent_id INT,
    office_id INT
);

-- Insert into agent_detail
INSERT INTO agent_detail (
    agent_id, agent_name, agent_phone, agent_job_title, agent_is_live,
    agent_inserted_at, agent_last_visible_date, agent_slug, agent_private_lister,
    agent_rei_membership, agent_selling_classification, agent_office_phone
)
SELECT DISTINCT
    agent_id, agent_name, agent_phone, agent_job_title, agent_is_live,
    agent_inserted_at, agent_last_visible_date, agent_slug, agent_private_lister,
    agent_rei_membership, agent_selling_classification, agent_office_phone
FROM raw_tbl
WHERE agent_id IS NOT NULL;

-- Insert into office_detail
INSERT INTO office_detail (
    office_id, office_name, office_address, office_phone, office_logo,
    office_postcode, office_state, office_suburb, office_website_url,
    office_is_live, office_inserted_at, office_last_visible_date
)
SELECT DISTINCT
    office_id, office_name, office_address, office_phone, office_logo,
    office_postcode, office_state, office_suburb, office_website_url,
    office_is_live, office_inserted_at, office_last_visible_date
FROM raw_tbl
WHERE office_id IS NOT NULL;

-- Insert into listing_detail
INSERT INTO listing_detail (
    listing_id, price_range_min, price_range_max, listing_price, listing_price_view,
    listing_created_at, listing_updated_at, listing_inserted_at, last_price_change,
    is_under_offer, is_price_display, under_offer_date, first_go_live,
    commercial_authority, authority, agent_id,listing_status, bedrooms, bathrooms,
	parking, energy_rating,is_prestige, has_virtual_tour, has_study, is_furnished,
	is_private_listing, show_on_map, listing_area,area_unit, buildingdetails_area, 
    buildingdetails_area_unit, listing_authority
)
SELECT DISTINCT
    listing_id, price_range_min, price_range_max, listing_price, listing_price_view,
    listing_created_at, listing_updated_at, listing_inserted_at, last_price_change,
    is_under_offer, is_price_display, under_offer_date, first_go_live,
    commercial_authority, authority, agent_id, listing_status,bedrooms, bathrooms,
	parking, energy_rating,is_prestige, has_virtual_tour, has_study, is_furnished,
	is_private_listing, show_on_map, listing_area,area_unit, buildingdetails_area, 
    buildingdetails_area_unit, listing_authority
FROM raw_tbl
WHERE listing_id IS NOT NULL;

-- Insert into auction_detail
INSERT INTO auction_detail (
    listing_id, auction_type, auction_date, auction_status
)
SELECT DISTINCT
    listing_id, auction_type, auction_date, auction_status
FROM raw_tbl
WHERE listing_id IS NOT NULL AND auction_type IS NOT NULL;

-- Insert into inspection_detail
INSERT INTO inspection_detail (
    listing_id, inspection_1_start_time, inspection_1_end_time,
    inspection_2_start_time, inspection_2_end_time
)
SELECT DISTINCT
    listing_id, inspection_1_start_time, inspection_1_end_time,
    inspection_2_start_time, inspection_2_end_time
FROM raw_tbl
WHERE listing_id IS NOT NULL;

-- Insert into daily_snapshot
INSERT INTO daily_snapshot (
    snapshot_date, listing_id, price_range_min, price_range_max, listing_price,
    listing_price_view, last_price_change, is_under_offer, is_price_display,
    under_offer_date, listing_created_at, listing_updated_at, listing_inserted_at,
    first_go_live, commercial_authority, authority, agent_id, office_id, property_type
)
SELECT
    distinct snapshot_date, listing_id, price_range_min, price_range_max, listing_price,
    listing_price_view, last_price_change, is_under_offer, is_price_display,
    under_offer_date, listing_created_at, listing_updated_at, listing_inserted_at,
    first_go_live, commercial_authority, authority, agent_id, office_id, property_type
FROM raw_tbl
WHERE listing_id IS NOT NULL AND snapshot_date IS NOT NULL;
