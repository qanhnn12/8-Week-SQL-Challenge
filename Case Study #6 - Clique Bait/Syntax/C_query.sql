-------------------------
--C. Campaigns Analysis--
-------------------------


SELECT
	u.user_id,
	e.visit_id,
	MIN(event_time) AS visit_start_time,
	SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
	SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds,
	CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END AS purchase,
	c.campaign_name,
	SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression,
	SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click,
	STRING_AGG(CASE WHEN ei.event_name = 'Add to Cart' THEN ph.page_name END, ' ,') WITHIN GROUP (ORDER BY e.sequence_number) AS cart_products
FROM events e
JOIN users u 
	ON e.cookie_id = u.cookie_id
JOIN event_identifier ei 
	ON e.event_type = ei.event_type
JOIN page_hierarchy ph 
	ON e.page_id = ph.page_id
LEFT JOIN campaign_identifier c 
	ON e.event_time BETWEEN c.start_date AND c.end_date
GROUP BY u.user_id, e.visit_id, c.campaign_name, ei.event_name;
