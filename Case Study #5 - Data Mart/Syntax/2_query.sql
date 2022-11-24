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
  SELECT pos+1 FROM allWeeks
  WHERE pos+1 <= 52)

SELECT 
  DISTINCT a.pos, 
  c.week_number
FROM allWeeks a
LEFT JOIN clean_weekly_sales c
  ON a.pos = c.week_number
ORDER BY a.pos;


--3. How many total transactions were there for each year in the dataset?

SELECT 
  calendar_year,
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;


--4. What is the total sales for each region for each month?

SELECT 
  region, 
  month_number, 
  -- Cast to 'bigint' because the SUM exceeds the maximum of 'int'
  SUM(CAST(sales AS bigint)) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
