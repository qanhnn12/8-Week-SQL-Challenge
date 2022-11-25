---------------------
--D. Bonus Question--
---------------------

-- Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?

--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15'
  AND calendar_year =2020)


--1. Sales changes by [regions]
WITH regionChanges AS (
  SELECT
    region,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY region
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM regionChanges;


--2. Sales changes by [platform]
WITH platformChanges AS (
  SELECT
    platform,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY platform
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM platformChanges;


--3. Sales changes by [age_band]
WITH ageBandChanges AS (
  SELECT
    age_band,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY age_band
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM ageBandChanges;


--4. Sales changes by [demographic]
WITH demographicChanges AS (
  SELECT
    demographic,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY demographic
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM demographicChanges;


--5. Sales changes by [customer_type]
WITH customerTypeChanges AS (
  SELECT
    customer_type,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY customer_type
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM customerTypeChanges;
