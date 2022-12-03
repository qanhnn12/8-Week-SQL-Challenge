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


