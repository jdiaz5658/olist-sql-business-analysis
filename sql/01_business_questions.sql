-- Project: Olist SQL Business Analysis (MySQL8) 
-- Goal: Show I can answer practical business questions using joins, aggregation, and time series logic. 
-- Data: Olist public ecommerce dataset (Kaggle). All anaysis uses analytics_order_fact for consistency. 

-- Q1. How does revenue trend over time 
-- Why this matters: Leaders want to know if the business is growing or shrinking. 
-- Approach: Use delivered orders only, group by month, sum order level payment totals. 

select 
	order_month, 
    sum(order_payment_value) as revenue 
from analytics_order_fact
where order_status = 'delivered' 
group by order_month
order by order_month; 

-- Q2. Which product categories drive the most revenue 
-- Why this matters: Helps prioritize inventory, marketing, and partnerships. 
-- Approach: Group by product category and rank by total revenue. 


select 
	product_category_name, 
    sum(order_payment_value) as revenue 
from analytics_order_fact 
where order_status = 'delivered' 
	and product_category_name is not null 
group by product_category_name 
order by revenue desc 
limit 20; 

-- Q3. Who are the highest value customers
-- Why this matters: Shows revenue concentration and helps target retention. 
-- Approach: Aggregate revenue by unique customer, show top spenders. 

select 
	customer_unique_id, 
    sum(order_payment_value) as total_spend, 
    count(distinct order_id) as orders 
from analytics_order_fact
where order_status = 'delivered' 
group by customer_unique_id 
order by total_spend desc 
limit 20; 

-- Q4. What is the average order value by month
-- Why this matters: AOV shifts signal pricing changes, product mix shifts, or promo impact. 
-- Approach: Use one row per order to avoid double counting items, then average by month. 

with order_level as (
	select 
		order_id, 
        order_month, 
        max(order_payment_value) as order_value
	from analytics_order_fact 
    where order_status = 'delivered' 
    group by order_id, order_month
)
select 
	order_month, 
    avg(order_value) as avg_order_value
from order_level
group by order_month
order by order_month; 

-- Q5. Which sellers generated the most revenue 
-- Why this matters: Identifies top partners and where performance risk sits. 
-- Approach: Group revenue by seller, include seller_state for a quick geographic cut. 

select 
	seller_id, 
    seller_state, 
    sum(order_payment_value) as revenue, 
    count(distinct order_id) as orders 
from analytics_order_fact 
where order_status = 'delivered' 
	and seller_id is not null 
group by seller_id, seller_state
order by revenue desc 
limit 20; 

-- Q6. Does late delivery correlate with lower review scores 
-- Why this matters: Delivery issues often drive churn and refunds. 
-- Approach: Bucket orders as on_time or late using actual vs estimated delivery date, then compare average review score. 

select 
	case 
		when delivered_customer_ts is null then 'not delivered' 
        when delivered_customer_ts <= estimated_delivery_ts then 'on_time' 
        else 'late' 
	end as delivery_bucket, 
    avg (review_score) as avg_review_score, 
    count(distinct order_id) as orders
from analytics_order_fact
where order_status = 'delivered' 
group by delivery_bucket 
order by delivery_bucket; 

-- Q7. How concentrated is revenue among top customers 
-- Why this matters: Heavy concentration increases risk if top customers leave. 
-- Approach: Compute revenue per customer, split into deciles, and measure the share from the top decile. 

with customer_rev as (
	select
		customer_unique_id, 
        sum(order_payment_value) as revenue 
	from analytics_order_fact
    where order_status = 'delivered' 
    group by customer_unique_id 
), 
ranked as ( 
	select 
		customer_unique_id, 
		revenue, 
		ntile(10) over (order by revenue desc) as decile
    from customer_rev 
) 
select 
	sum(case when decile = 1 then revenue else 0 end) / sum(revenue) as top_10pct_revenue_share
from ranked; 

-- Q8. Which customers look inactive based on last purchase date 
-- Why this matters: Inactive customers are the easiest win for re engagement. 
-- Approach: Find each customer's last purchase and compare it to the latest purchase date in the dataset. 

with last_purchase as ( 
	select 
		customer_unique_id, 
        max(order_purchase_ts) as last_order_ts 
	from analytics_order_fact 
    where order_status = 'delivered' 
    group by customer_unique_id
),
dataset_max as (
	select max(order_purchase_ts) as max_ts
    from analytics_order_fact 
    where order_status = 'delivered' 
)
select 
	lp.customer_unique_id, 
    lp.last_order_ts, 
    datediff(dm.max_ts, lp.last_order_ts) as days_inactive 
from last_purchase lp 
cross join dataset_max dm 
where datediff(dm.max_ts, lp.last_order_ts) >= 90
order by days_inactive desc 
limit 50; 
