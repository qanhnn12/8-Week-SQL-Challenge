-----------------------
--A. Digital Analysis--
-----------------------

--1. How many users are there?

SELECT COUNT(DISTINCT user_id) AS users_count
FROM users;


--2. How many cookies does each user have on average?

SELECT AVG(cookies_count) AS avg_cookies_per_user
FROM (
	SELECT 
		user_id,
		COUNT(cookie_id) AS cookies_count
	FROM users
	GROUP BY user_id
) temp;

--3. What is the unique number of visits by all users per month?
