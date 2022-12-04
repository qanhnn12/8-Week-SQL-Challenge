------------------------
--B. Interest Analysis--
------------------------

--1. Which interests have been present in all month_year dates in our dataset?

-- Find how many unique month_year dates in our dataset
DECLARE @unique_month_year_cnt INT = (
  SELECT COUNT(DISTINCT month_year)
  FROM interest_metrics)

--Filter all interest_id that have the count = @unique_month_year_cnt
SELECT 
  interest_id,
  COUNT(month_year) AS cnt
FROM interest_metrics
GROUP BY interest_id
HAVING COUNT(month_year) = @unique_month_year_cnt;


--2. Using this same total_months measure - calculate the cumulative percentage of all records starting at 14 months 
-- which total_months value passes the 90% cumulative percentage value?

WITH interest_months AS (
  SELECT
    interest_id,
    COUNT(DISTINCT month_year) AS total_months
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
),
interest_count AS (
  SELECT
    total_months,
    COUNT(interest_id) AS cnt
  FROM interest_months
  GROUP BY total_months
)

SELECT *,
  CAST(100.0 * SUM(cnt) OVER(ORDER BY total_months DESC)
	/ SUM(cnt) OVER() AS decimal(10, 2)) AS cumulative_pct
FROM interest_count;


--3. If we were to remove all interest_id values which are lower than the total_months value we found in the previous question 
--- how many total data points would we be removing?

WITH interest_months AS (
  SELECT
    interest_id,
    COUNT(DISTINCT month_year) AS total_months
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
),
interest_count AS (
  SELECT
    total_months,
    COUNT(interest_id) AS cnt
  FROM interest_months
  GROUP BY total_months
)

SELECT SUM(cnt) AS interest_id_count
FROM interest_count
WHERE total_months < 6;


--4. Does this decision make sense to remove these data points from a business perspective? 
--Use an example where there are all 14 months present to a removed interest example for your arguments 
-- think about what it means to have less months present from a segment perspective.

--When total_months = 14
SELECT 
  month_year,
  COUNT(DISTINCT interest_id) interest_count,
  MIN(ranking) AS highest_rank,
  MAX(composition) AS composition_max,
  MAX(index_value) AS index_max
FROM interest_metrics metrics
WHERE interest_id IN (
  SELECT interest_id
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) = 14)
GROUP BY month_year
ORDER BY month_year, highest_rank;

--When total_months = 6
SELECT 
  month_year,
  COUNT(DISTINCT interest_id) interest_count,
  MIN(ranking) AS highest_rank,
  MAX(composition) AS composition_max,
  MAX(index_value) AS index_max
FROM interest_metrics metrics
WHERE interest_id IN (
  SELECT interest_id
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) = 6)
GROUP BY month_year
ORDER BY month_year, highest_rank;


--When total_months = 1
SELECT 
  month_year,
  COUNT(DISTINCT interest_id) interest_count,
  MIN(ranking) AS highest_rank,
  MAX(composition) AS composition_max,
  MAX(index_value) AS index_max
FROM interest_metrics metrics
WHERE interest_id IN (
  SELECT interest_id
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) = 1)
GROUP BY month_year
ORDER BY month_year, highest_rank;


--5. After removing these interests - how many unique interests are there for each month?

--Remove all interest_id that have total_months lower than 6
DELETE FROM interest_metrics
WHERE interest_id IN (
  SELECT interest_id
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) < 6 --total_months in Q3
  ); 

--Find the number of unique interests after removing step above
SELECT 
  month_year,
  COUNT(DISTINCT interest_id) AS unique_interests
FROM interest_metrics
WHERE month_year IS NOT NULL
GROUP BY month_year
ORDER BY month_year;
