-----------------------
--2. Data Exploration--
-----------------------

--1. What day of the week is used for each week_date value?

SELECT DISTINCT(DATENAME(dw, week_date)) AS week_date_value
FROM clean_weekly_sales;

--2. What range of week numbers are missing from the dataset?

WITH allWeeks AS (
  SELECT 1 AS pos
  UNION ALL
  SELECT pos+1
  FROM allWeeks
  WHERE pos+1 <= 52)

SELECT 
  DISTINCT a.pos, 
  c.week_number
FROM allWeeks a
LEFT JOIN clean_weekly_sales c
  ON a.pos = c.week_number
ORDER BY a.pos;

