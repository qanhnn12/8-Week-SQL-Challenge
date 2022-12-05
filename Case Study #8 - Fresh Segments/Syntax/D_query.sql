---------------------
--D. Index Analysis--
---------------------

--1. What is the top 10 interests by the average composition for each month?

WITH avg_composition_rank AS (
  SELECT 
    metrics.interest_id,
    map.interest_name,
    metrics.month_year,
    ROUND(metrics.composition / metrics.index_value, 2) AS avg_composition,
    DENSE_RANK() OVER(PARTITION BY metrics.month_year ORDER BY metrics.composition / metrics.index_value DESC) AS rnk
  FROM interest_metrics metrics
  JOIN interest_map map 
    ON metrics.interest_id = map.id
  WHERE metrics.month_year IS NOT NULL
) 
SELECT *
FROM avg_composition_rank
--filter top 10 interests for each month
WHERE rnk <= 10; 


--2. For all of these top 10 interests - which interest appears the most often?

WITH avg_composition_rank AS (
  SELECT 
    metrics.interest_id,
    map.interest_name,
    metrics.month_year,
    ROUND(metrics.composition / metrics.index_value, 2) AS avg_composition,
    DENSE_RANK() OVER(PARTITION BY metrics.month_year ORDER BY metrics.composition / metrics.index_value DESC) AS rnk
  FROM interest_metrics metrics
  JOIN interest_map map 
    ON metrics.interest_id = map.id
  WHERE metrics.month_year IS NOT NULL
),
frequent_interests AS (
  SELECT 
    interest_id,
    interest_name,
    COUNT(*) AS freq
  FROM avg_composition_rank
  WHERE rnk <= 10	--filter top 10 interests for each month
  GROUP BY interest_id, interest_name
)

SELECT * 
FROM frequent_interests
WHERE freq IN (SELECT MAX(freq) FROM frequent_interests);


--3. What is the average of the average composition for the top 10 interests for each month?

WITH avg_composition_rank AS (
  SELECT 
    metrics.interest_id,
    map.interest_name,
    metrics.month_year,
    ROUND(metrics.composition / metrics.index_value, 2) AS avg_composition,
    DENSE_RANK() OVER(PARTITION BY metrics.month_year ORDER BY metrics.composition / metrics.index_value DESC) AS rnk
  FROM interest_metrics metrics
  JOIN interest_map map 
    ON metrics.interest_id = map.id
  WHERE metrics.month_year IS NOT NULL
)

SELECT 
  month_year,
  AVG(avg_composition) AS avg_of_avg_composition
FROM avg_composition_rank
WHERE rnk <= 10 --filter top 10 interests for each month
GROUP BY month_year;


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
