------------------------------
--3. Before & After Analysis--
------------------------------

--1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?

--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15')

--Find the total sales of 4 weeks before and after @weekNum
WITH packageChanges AS (
  SELECT 
    week_number,
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE week_number BETWEEN @weekNum-4 AND @weekNum+3
  AND calendar_year = 2020
  GROUP BY week_number
),
--Sepatate sales before and after @weekNum
salesChanges AS (
  SELECT
    SUM(CASE WHEN week_number BETWEEN @weekNum-4 AND @weekNum-1 THEN total_sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+3 THEN total_sales END) AS after_changes
  FROM packageChanges
)

SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges;


--2. What about the entire 12 weeks before and after?

--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15')

--Find the total sales of 12 weeks before and after @weekNum
WITH packageChanges AS (
  SELECT 
    week_number,
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE week_number BETWEEN @weekNum-12 AND @weekNum+11
  AND calendar_year = 2020
  GROUP BY week_number
),
--Sepatate sales before and after @weekNum
salesChanges AS (
  SELECT
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN total_sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN total_sales END) AS after_changes
  FROM packageChanges
)

SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges;


--3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?

--Part 1: How do the sales metrics for 4 weeks before and after compared with the previous years in 2018 and 2019
--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15')

--Find the total sales of 4 weeks before and after @weekNum
WITH packageChanges AS (
  SELECT 
    calendar_year,
    week_number,
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE week_number BETWEEN @weekNum-4 AND @weekNum+3
  GROUP BY calendar_year, week_number
),
--Sepatate sales before and after @weekNum
salesChanges AS (
  SELECT
    calendar_year,
    SUM(CASE WHEN week_number BETWEEN @weekNum-3 AND @weekNum-1 THEN total_sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+3 THEN total_sales END) AS after_sales
  FROM packageChanges
  GROUP BY calendar_year
)

SELECT *,
  CAST(100.0 * (after_sales-before_sales)/before_sales AS decimal(5,2)) AS pct_change
FROM salesChanges;

--Part 2: How do the sales metrics for 12 weeks before and after compared with the previous years in 2018 and 2019
--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15')

--Find the total sales of 12 weeks before and after @weekNum
WITH packageChanges AS (
  SELECT 
    calendar_year,
    week_number,
    SUM(sales) AS total_sales
  FROM clean_weekly_sales
  WHERE week_number BETWEEN @weekNum-12 AND @weekNum+11
  GROUP BY calendar_year, week_number
),
--Sepatate sales before and after @weekNum
salesChanges AS (
  SELECT
    calendar_year,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN total_sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN total_sales END) AS after_sales
  FROM packageChanges
  GROUP BY calendar_year
)

SELECT *,
  CAST(100.0 * (after_sales-before_sales)/before_sales AS decimal(5,2)) AS pct_change
FROM salesChanges;
