-------------------------
--C. Campaigns Analysis--
-------------------------
/*Generate a table that has 1 single row for every unique visit_id record and has the following columns:
- user_id
- visit_id
- visit_start_time: the earliest event_time for each visit
- page_views: count of page views for each visit
- cart_adds: count of product cart add events for each visit
- purchase: 1/0 flag if a purchase event exists for each visit
- campaign_name: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
- impression: count of ad impressions for each visit
- click: count of ad clicks for each visit
- (Optional column) cart_products: a comma separated text value with products added to the cart 
sorted by the order they were added to the cart (hint: use the sequence_number)
*/

SELECT
  u.user_id,
  e.visit_id,
  MIN(event_time) AS visit_start_time,
  SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds,
  SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase,
  c.campaign_name,
  SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression,
  SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click,
  STRING_AGG(CASE WHEN ei.event_name = 'Add to Cart' THEN ph.page_name END, ', ') 
    WITHIN GROUP (ORDER BY e.sequence_number) AS cart_products
INTO #campaign_summary
FROM events e
JOIN users u 
  ON e.cookie_id = u.cookie_id
JOIN event_identifier ei 
  ON e.event_type = ei.event_type
JOIN page_hierarchy ph 
  ON e.page_id = ph.page_id
LEFT JOIN campaign_identifier c 
  ON e.event_time BETWEEN c.start_date AND c.end_date
GROUP BY u.user_id, e.visit_id, c.campaign_name;


/*
- Identifying users who have received impressions during each campaign period 
and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus 
users who do not receive an impression? What if we compare them with users who have just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to each other?
*/

--1. Calculate the number of users in each group

--Number of users received impressions during campaign periods = 417
SELECT COUNT(DISTINCT user_id) AS received_impressions
FROM #campaign_summary
WHERE impression > 0
AND campaign_name IS NOT NULL;

--Number of users received impressions but didn't click on the ad = 127
SELECT COUNT(DISTINCT user_id) AS received_impressions_not_clicked
FROM #campaign_summary
WHERE impression > 0
AND click = 0
AND campaign_name IS NOT NULL;

--Number of users didn't receive impressions during campaign periods = 56
SELECT COUNT(DISTINCT user_id) AS received_impressions
FROM #campaign_summary
WHERE campaign_name IS NOT NULL
AND user_id NOT IN (
	SELECT user_id
	FROM #campaign_summary
	WHERE impression > 0)


--2. Compare the average views, average cart adds and average purchases of users received impressions and not received impressions
/* Since the number of users received impressions was higher than those who not received impressions, 
the total views, total cart adds and total purchases of the prior group are definitely higher than the latter. 
Therefore in this case, I compare the average rate between two groups (instead of the total) to see 
if running ads could increase the number of views, cart_adds, and purchases.*/

--For received impressions group
DECLARE @received int 
SET @received = 417

SELECT 
	CAST(1.0*SUM(click) / @received AS decimal(10,1)) AS avg_click,
	CAST(1.0*SUM(page_views) / @received AS decimal(10,1)) AS avg_view,
	CAST(1.0*SUM(cart_adds) / @received AS decimal(10,1)) AS avg_cart_adds,
	CAST(1.0*SUM(purchase) / @received AS decimal(10,1)) AS avg_purchase
FROM #campaign_summary
WHERE impression > 0
AND campaign_name IS NOT NULL;

--For not received impressions group
DECLARE @not_received int 
SET @not_received = 56

SELECT 
	CAST(1.0*SUM(click) / @received AS decimal(10,1)) AS avg_click,
	CAST(1.0*SUM(page_views) / @not_received AS decimal(10,1)) AS avg_view,
	CAST(1.0*SUM(cart_adds) / @not_received AS decimal(10,1)) AS avg_cart_adds,
	CAST(1.0*SUM(purchase) / @not_received AS decimal(10,1)) AS avg_purchase
FROM #campaign_summary
WHERE campaign_name IS NOT NULL
AND user_id NOT IN (
	SELECT user_id
	FROM #campaign_summary
	WHERE impression > 0);

/* Combine table
|                             | avg_click | avg_view | avg_cart_adds | avg_purchase  |
|-----------------------------|-----------|----------|---------------|---------------|
| Received impressions        | 1.4       | 15.3     | 9             | 1.5           |
| Not received impressions    | 0         | 19.4     | 5.8           | 1.2           |
| % Increase by campaigns     | n/a       | No       | Yes           | Yes           |
*/


--3. Compare the average purchases of users received impressions and received impressions but not clicked

--For users received impressions but not clicked
DECLARE @received_not_clicked int 
SET @received_not_clicked = 127

SELECT
	CAST(1.0*SUM(purchase) / @received_not_clicked AS decimal(10,1)) AS avg_purchase
FROM #campaign_summary
WHERE impression > 0
AND click = 0
AND campaign_name IS NOT NULL;

/*Combine table                        | avg_purchase  |
|--------------------------------------|---------------|
| Received impressions                 | 1.5           |
| Received impressions but not clicked | 0.8           |
| Increase by clicking to the ads      | Yes           |
*/
