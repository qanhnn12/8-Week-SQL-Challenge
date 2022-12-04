-----------------------
--C. Segment Analysis--
-----------------------

--1. Using our filtered dataset by removing the interests with less than 6 months worth of data, 
--which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
--Only use the maximum composition value for each interest but you must keep the corresponding month_year.

WITH composition_ranks AS (
  SELECT 
    month_year,
    interest_id,
    composition,
    MAX(composition) OVER (PARTITION BY month_year) AS largest_composition,
    DENSE_RANK() OVER(PARTITION BY month_year ORDER BY composition DESC) AS top_rnk,
    DENSE_RANK() OVER(PARTITION BY month_year ORDER BY composition) AS bottom_rnk
  FROM interest_metrics
  WHERE month_year IS NOT NULL
)

--Top 10 interests that have the largest composition values in each month_year
SELECT 
  DISTINCT cr.interest_id,
  im.interest_name
FROM composition_ranks cr
JOIN interest_map im ON cr.interest_id = im.id
WHERE cr.top_rnk <= 10;

--Bottom 10 interests that have the largest composition values in each month_year
SELECT 
  DISTINCT cr.interest_id,
  im.interest_name
FROM composition_ranks cr
JOIN interest_map im ON cr.interest_id = im.id
WHERE cr.bottom_rnk <= 10;

