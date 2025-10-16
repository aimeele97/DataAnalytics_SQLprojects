## 🏘️ Real Estate Listings Project (1 Month Data)

--- 
## 🔗 Quick Access

- 💬 [LinkedIn Project Post](https://www.linkedin.com/feed/update/urn:li:activity:7339201532086689795/)
- 📊 [Dashboard on Tableau Public](https://public.tableau.com/app/profile/tien.le2550/viz/real_estate_dashboard_17476316458810_17490860210760/DashboardKPI)
- 🧾 [SQL Data Model Code](src/real_estate_data_model.sql)
- 🧾 [SQL Data Analysis Code](src/Data%20Analysis.sql)
- 📁 [Raw Dataset CSV](src/raw_tbl.csv)

---

<details>
<summary><strong>📚  Table of Contents</strong></summary>  
  
- [Overview](#overview)  
- [Tools & Techniques](#tools--techniques)  
- [Data Collection & Overview](#data-collection--overview)  
- [Data Modeling Approach](#data-modeling-approach)  
- [Data Exploration](#sql-based-data-exploration)  
- [Dashboard Highlights](#dashboard-highlights)  
- [Key Insights](#key-insights)  
    - [Balanced Market Activity](#balanced-market-activity)  
    - [29 Days to Sell](#29-days-to-sell)  
    - [Market Dominated by Houses](#market-dominated-by-houses)  
    - [Buyer Behavior from Inspections](#buyer-behavior-from-inspections)  
    - [Private Treaty Over Auctions](#private-treaty-over-auctions)  
- [Final Thoughts](#final-thoughts)

</details>

---
## Overview

This project dives into real-world property listings, taking raw, messy data and transforming it into structured insights using SQL and Tableau. More than just a technical exercise, it's a reflection of how data, when shaped the right way, can tell powerful stories about markets, people, and places.

Key findings include a 29-day average selling window, strong buyer preference for houses, peak inspection activity on weekends, and a clear dominance of private treaty over auction sales. These insights can help real estate agents, sellers, and market analysts make data-informed decisions around pricing strategies, listing timing, and property type focus.

--- 

## Tools & Techniques

> Data Modeling, and Analysis: **MySQL**  
> Data Visualization: **Tableau**

## Data Collection & Overview

- Collected real-world real estate listing data and transformed it into clean, analysis-ready models using SQL.  
- Built structured datasets to enable exploratory analysis and visualization of market trends.  

__Note:__ Data used strictly for educational and training purposes only

[Raw data can be found here](src/raw_tbl.csv)

The dataset includes: **71 columns** and **10,682 records**

![alt text](img/image-12.png)
![alt text](img/image-4.png)

Raw data overview

![alt text](img/image-14.png)

--- 
## Data Modeling Approach

Created SQL queries to split the data into:

* **Fact table** — transactional data that changes over time (e.g. daily_snapshot)
* **Dimension tables** — descriptive fields that add context (e.g. agent_detail, office_detail)  
- [SQL quote can be found here](./real_estate_data_model.sql)

This structure follows best practices for scalable, reliable analytics.

![alt text](img/image-15.png)

--- 

## SQL-Based Data Exploration

Once modeled, I used SQL to dive deep into the data using:

* `SELECT`, `FROM`, `JOIN`,`WHERE`, `GROUP BY`, `HAVING`
* Subqueries, CTE, window functions, basic calculations

Insights explored:

* Total number of properties
* Average daily listings
* New vs. sold listings
* Top 5 most active agents
* Median listing price
* Number of inspections before sale
* Inspection conversion rate
* Median sale price & time on market by property type
* Fastest-selling homes
* Listings with price changes over time

[SQL code can be found here](src/Data%20Analysis.sql)

Example SQL syntax:

```sql
--list of unique listings with price change over time

with cte as (
	select listing_id, agent_id,
        count(distinct listing_price_view) time_price_change
	from real_estate.fact_daily_listing
	group by listing_id, agent_id
    having count(distinct listing_price_view) > 1 
)
select cte.listing_id,
    f.agent_id, 
    f.first_go_live, 
    f.last_price_change,
    f.listing_price_view
from real_estate.fact_daily_listing f 
join cte
    on cte.listing_id = f.listing_id
group by cte.listing_id,f.agent_id, f.first_go_live, 
    f.last_price_change, f.listing_price_view
order by cte.listing_id, first_go_live;
```
--- 

## Dashboard Highlights

Using Tableau, I created a dashboard with 3 interactive tabs:

1. **Executive Summary** – Listings trends and key KPIs
2. **Property Insights** – Price comparisons by location and hotspot areas
3. **Auction & Inspection** – Calendar view of market activity

🔗 [View on LinkedIn Post](https://www.linkedin.com/feed/update/urn:li:activity:7339201532086689795/)

🔗 [View on Tableau Public](https://public.tableau.com/app/profile/tien.le2550/viz/real_estate_dashboard_17476316458810_17490860210760/DashboardKPI)

--- 

## Key Insights

![alt text](img/image-6.png)

### Balanced Market Activity

Out of 1,077 listings, **429 were new** and **432 were sold**, showing a well-aligned supply and demand dynamic.

### 29 Days to Sell

Most properties were sold within **29 days** — a valuable benchmark for turnover expectations.

![alt text](img/image-9.png)
![alt text](img/image-10.png)

### Market Dominated by Houses

Houses led in volume, followed by apartments and townhouses — together making up **88% of listings** and **91% of sales**.

![alt text](img/image-11.png)

### Buyer Behavior from Inspections

Most listings had **1–2 inspections**, peaking on weekends. One standout property had **10 inspections**, pointing to either high interest or slower conversion.

### Private Treaty Over Auctions

Only **8%** of inspections were linked to auctions — confirming **private treaty** as the dominant method in this market.

## Recommendations based on the insights

#### **For Buyers**

* **Time Inspections Strategically:** Focus on weekend inspections when market activity is highest to compare multiple options efficiently.
* **Property Type Awareness:** Prioritize houses, as they dominate market availability and sales, but also explore apartments and townhouses for niche opportunities.
* **Benchmark Expectations:** Use the 29-day average selling window as a reference for negotiating offers and planning purchase timing.
* **Private Treaty Advantage:** Consider properties sold via private treaty, as they represent the majority of transactions and may offer faster closure than auctions.

#### **For Listing Agents / Sellers**

* **Optimize Listing Duration:** Aim to sell properties within the 29-day average by aligning pricing, marketing, and inspection schedules.
* **Highlight Property Type Strengths:** Focus on houses for broader appeal while tailoring strategies for apartments and townhouses.
* **Schedule Inspections Wisely:** Maximize engagement by promoting viewings during peak weekend activity.
* **Monitor Buyer Behavior & Pricing:** Track properties with frequent price changes or high inspection counts to adjust strategies and anticipate market interest.
* **Leverage Private Treaty Sales:** Use private treaty as the preferred method for predictable and timely transactions.
* **Location-Based Marketing:** Target hotspot areas identified in analysis for higher visibility and engagement.

--- 

## Final Thoughts

This project reminded me that data isn’t just numbers, it’s movement, intention, and behavior captured in rows and columns. Turning this raw dataset into insights was both a technical challenge and a creative process.

From modeling to visualization, every step helped sharpen my ability to think like a data professional, and tell a story with the numbers.

If you're curious to dive deeper, feel free to explore the SQL code, check out the dashboard, or connect with me.

📬 [Let’s connect on LinkedIn](https://www.linkedin.com/in/aimeele97/)
