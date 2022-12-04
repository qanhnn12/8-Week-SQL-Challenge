---------------------
--D. Index Analysis--
---------------------

--1. What is the top 10 interests by the average composition for each month?

SELECT 
  temp.*, map.interest_name
FROM (
  SELECT
    interest_id, month_year,
    AVG(composition) AS avg_composition,
    DENSE_RANK() OVER(PARTITION BY month_year ORDER BY AVG(composition) DESC) AS rnk_avg_composition
  FROM interest_metrics
  WHERE month_year IS NOT NULL
  GROUP BY interest_id, month_year
  ) temp
JOIN interest_map map 
  ON temp.interest_id = map.id
WHERE temp.rnk_avg_composition <= 10;


--2. For all of these top 10 interests - which interest appears the most often?

--Query in Q1
WITH top_interest_composition AS (
  SELECT 
    temp.*, map.interest_name
  FROM (
    SELECT
      interest_id, month_year,
      AVG(composition) AS avg_composition,
      DENSE_RANK() OVER(PARTITION BY month_year ORDER BY AVG(composition) DESC) AS rnk_avg_composition
    FROM interest_metrics
    WHERE month_year IS NOT NULL
    GROUP BY interest_id, month_year
  ) temp
  JOIN interest_map map ON temp.interest_id = map.id
  WHERE temp.rnk_avg_composition <= 10
),

--Count the number of times each interest_id appears
interest_frequency AS (
  SELECT
    interest_id,
    COUNT(interest_id) AS freq
  FROM top_interest_composition
  GROUP BY interest_id
)

SELECT 
  interest_id,
  freq AS most_freq
FROM interest_frequency
WHERE freq IN (SELECT MAX(freq) FROM interest_frequency);


--3. What is the average of the average composition for the top 10 interests for each month?

--Query in Q1
WITH top_interest_composition AS (
  SELECT 
    temp.*, map.interest_name
  FROM (
    SELECT
      interest_id, month_year,
      AVG(composition) AS avg_composition,
      DENSE_RANK() OVER(PARTITION BY month_year ORDER BY AVG(composition) DESC) AS rnk_avg_composition
    FROM interest_metrics
    WHERE month_year IS NOT NULL
    GROUP BY interest_id, month_year
  ) temp
  JOIN interest_map map ON temp.interest_id = map.id
  WHERE temp.rnk_avg_composition <= 10
)

SELECT 
  DISTINCT month_year,
  ROUND(AVG(avg_composition) OVER (PARTITION BY month_year),2) AS avg_of_avg_composition
FROM top_interest_composition
ORDER BY month_year;
