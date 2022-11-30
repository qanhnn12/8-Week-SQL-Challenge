-----------------------
--A. Digital Analysis--
-----------------------

--1. How many users are there?

SELECT COUNT(DISTINCT user_id) AS users_count
FROM users;


--2. How many cookies does each user have on average?

SELECT CAST(AVG(cookies_count) AS FLOAT) AS avg_cookies_per_user
FROM (
  SELECT 
    user_id,
    1.0*COUNT(cookie_id) AS cookies_count
  FROM users
  GROUP BY user_id) temp;


--3. What is the unique number of visits by all users per month?

SELECT 
  MONTH(event_time) AS months,
  COUNT(DISTINCT visit_id) AS visits_count
FROM events
GROUP BY MONTH(event_time)
ORDER BY months;


--4. What is the number of events for each event type?

SELECT 
  e.event_type,
  ei.event_name,
  COUNT(*) AS event_count
FROM events e
JOIN event_identifier ei
  ON e.event_type = ei.event_type
GROUP BY e.event_type, ei.event_name
ORDER BY e.event_type;


--5. What is the percentage of visits which have a purchase event?

SELECT 
  CAST(100.0 * COUNT(DISTINCT e.visit_id) 
       / (SELECT COUNT(DISTINCT visit_id) FROM events) AS decimal(10,2)) AS purchase_pct
FROM events e
JOIN event_identifier ei
  ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase';


--6. What is the percentage of visits which view the checkout page but do not have a purchase event?

WITH view_checkout AS (
  SELECT COUNT(e.visit_id) AS cnt
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy p ON e.page_id = p.page_id
  WHERE ei.event_name = 'Page View'
    AND p.page_name = 'Checkout'
)

SELECT CAST(100-(100.0 * COUNT(DISTINCT e.visit_id) 
		/ (SELECT cnt FROM view_checkout)) AS decimal(10, 2)) AS pct_view_checkout_not_purchase
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase'


--7. What are the top 3 pages by number of views?

SELECT 
  TOP 3 ph.page_name,
  COUNT(*) AS page_views
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE ei.event_name = 'Page View'
GROUP BY ph.page_name
ORDER BY page_views DESC;


--8. What is the number of views and cart adds for each product category?

SELECT 
  ph.product_category,
  SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY ph.product_category;


--9. What are the top 3 products by purchases?

SELECT 
  TOP 3 ph.product_id,
  ph.page_name,
  ph.product_category,
  COUNT(*) AS purchase_count
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE ei.event_name = 'Add to cart'
AND e.visit_id IN (
  SELECT e.visit_id
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  WHERE ei.event_name = 'Purchase')
GROUP BY ph.product_id,	ph.page_name, ph.product_category
ORDER BY purchase_count DESC;
