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
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;


--5. What is the total count of transactions for each platform

SELECT 
  platform,
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;


--6. What is the percentage of sales for Retail vs Shopify for each month?

WITH sales_cte AS (
  SELECT 
    calendar_year, 
    month_number, 
    platform, 
    SUM(sales) AS monthly_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, month_number, platform
)

SELECT 
  calendar_year, 
  month_number, 
  CAST(100.0 * MAX(CASE WHEN platform = 'Retail' THEN monthly_sales ELSE 0 END)
	/ SUM(monthly_sales) AS decimal(5, 2)) AS pct_retail,
  CAST(100.0 * MAX(CASE WHEN platform = 'Shopify' THEN monthly_sales ELSE 0 END)
	/ SUM(monthly_sales) AS decimal(5, 2)) AS pct_shopify
  FROM sales_cte
  GROUP BY calendar_year,  month_number
  ORDER BY calendar_year, month_number;
