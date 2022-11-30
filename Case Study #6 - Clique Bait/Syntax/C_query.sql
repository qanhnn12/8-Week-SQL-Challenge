-------------------------
--C. Campaigns Analysis--
-------------------------
/*
Generate a table that has 1 single row for every unique visit_id record and has the following columns:
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
Identifying users who have received impressions during each campaign period 
and comparing each metric with other users who did not have an impression event
*/

WITH metrics AS (
SELECT 
	SUM(CASE WHEN impression = 0 THEN page_views END) AS normal_views,
	SUM(CASE WHEN impression > 0 THEN page_views END) AS campaign_views,
	SUM(CASE WHEN impression = 0 THEN cart_adds END) AS normal_cart_adds,
	SUM(CASE WHEN impression > 0 THEN cart_adds END) AS campaign_cart_adds,
	SUM(CASE WHEN impression = 0 THEN click END) AS no_ad_click,
	SUM(CASE WHEN impression > 0 THEN click END) AS campaign_ad_click,
	SUM(CASE WHEN impression = 0 THEN purchase END) AS normal_purchase,
	SUM(CASE WHEN impression > 0 THEN purchase END) AS campaign_purchase
FROM #campaign_summary
)

SELECT 
	CAST(100.0 * (campaign_views - normal_views)
		/ normal_views AS decimal(10,2)) AS views_increase_pct,
	CAST(100.0 * (campaign_cart_adds - normal_cart_adds)
		/ normal_cart_adds AS decimal(10,2)) AS cart_adds_increase_pct,
	CAST(100.0 * (campaign_purchase - normal_purchase)
		/ normal_purchase AS decimal(10,2)) AS purchase_increase_pct
FROM metrics;
