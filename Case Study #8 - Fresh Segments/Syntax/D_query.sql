---------------------
--D. Index Analysis--
---------------------

--1. What is the top 10 interests by the average composition for each month?

SELECT 
  TOP 10 metrics.interest_id,
  map.interest_name,
  ROUND(metrics.composition / metrics.index_value, 2) AS avg_composition
FROM interest_metrics metrics
JOIN interest_map map ON metrics.interest_id = map.id
ORDER BY avg_composition DESC;


--2. For all of these top 10 interests - which interest appears the most often?

WITH top_10_interests AS (
  SELECT 
    TOP 10 metrics.interest_id,
    map.interest_name,
    ROUND(metrics.composition / metrics.index_value, 2) AS avg_composition
FROM interest_metrics metrics
JOIN interest_map map 
  ON metrics.interest_id = map.id
ORDER BY avg_composition DESC
)

SELECT
  TOP 1 interest_id,
  interest_name,
  COUNT(interest_id) AS freq
FROM top_10_interests
GROUP BY interest_id, interest_name
ORDER BY freq;


--3. What is the average of the average composition for the top 10 interests for each month?

WITH top_10_interests AS (
  SELECT 
    TOP 10 metrics.interest_id,
    map.interest_name,
    metrics.composition / metrics.index_value AS avg_composition
FROM interest_metrics metrics
JOIN interest_map map ON metrics.interest_id = map.id
ORDER BY avg_composition DESC
)

SELECT ROUND(AVG(avg_composition), 2) AS avg_of_avg_composition
FROM top_10_interests;


--4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 
--and include the previous top ranking interests in the same output shown below.

WITH avg_compositions AS (
  SELECT 
    month_year,
    interest_id,
    ROUND(composition / index_value, 2) AS avg_comp,
    ROUND(MAX(composition / index_value) OVER(PARTITION BY month_year), 2) AS max_avg_comp
  FROM interest_metrics
  WHERE month_year IS NOT NULL
),
max_avg_compositions AS (
  SELECT *
  FROM avg_compositions
  WHERE avg_comp = max_avg_comp
),
moving_avg_compositions AS (
  SELECT 
    mac.month_year,
    im.interest_name,
    mac.max_avg_comp AS max_index_composition,
    ROUND(AVG(mac.max_avg_comp) 
	  OVER(ORDER BY mac.month_year 
	       ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS '3_month_moving_avg',
    LAG(im.interest_name) OVER (ORDER BY mac.month_year) + ': ' +
	CAST(LAG(mac.max_avg_comp) OVER (ORDER BY mac.month_year) AS VARCHAR(4)) AS '1_month_ago',
    LAG(im.interest_name, 2) OVER (ORDER BY mac.month_year) + ': ' +
	CAST(LAG(mac.max_avg_comp, 2) OVER (ORDER BY mac.month_year) AS VARCHAR(4)) AS '2_month_ago'
  FROM max_avg_compositions mac 
  JOIN interest_map im 
    ON mac.interest_id = im.id
)

SELECT *
FROM moving_avg_compositions
WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01';


--5. Provide a possible reason why the max average composition might change from month to month? 
--Could it signal something is not quite right with the overall business model for Fresh Segments?
