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
JOIN interest_map map ON metrics.interest_id = map.id
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
FROM top_10_interests


--4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 
--and include the previous top ranking interests in the same output shown below.


