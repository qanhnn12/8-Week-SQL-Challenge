-----------------------
--A. Digital Analysis--
-----------------------

--1. How many users are there?

SELECT COUNT(DISTINCT user_id) AS users_count
FROM users;


--2. How many cookies does each user have on average?

SELECT 
  CAST(AVG(cookies_count) AS FLOAT) AS avg_cookies_per_user
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
  --select distinct here because each visit can have multiple events
	/ (SELECT COUNT(DISTINCT visit_id) FROM events) AS decimal(10,2)) AS purchase_pct
FROM events e
JOIN event_identifier ei
ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase';


--6. What is the percentage of visits which view the checkout page but do not have a purchase event?

WITH view_checkout AS (
  SELECT COUNT(DISTINCT visit_id) AS cnt 
  FROM events
  WHERE event_type = 1
    AND page_id = 12
),
purchase_list AS (
  SELECT visit_id 
  FROM events
  WHERE event_type = 3)

SELECT 
  CAST(100.0*COUNT(visit_id)
	/ (SELECT cnt FROM view_checkout) AS decimal(10,2)) AS pct_view_checkout_not_purchase
FROM events
--view the checkout page
WHERE event_type = 1 AND page_id = 12
-- but not purchase
  AND visit_id NOT IN (SELECT visit_id FROM purchase_list);




