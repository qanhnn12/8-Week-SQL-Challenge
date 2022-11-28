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
  i.event_name,
  COUNT(*) AS event_count
FROM events e
JOIN event_identifier i
  ON e.event_type = i.event_type
GROUP BY e.event_type, i.event_name
ORDER BY e.event_type;

