-----------------------
--B. Data Exploration--
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
WHERE c.week_number IS NULL
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
  CAST(100.0 * MAX(CASE WHEN platform = 'Retail' THEN monthly_sales END)
	/ SUM(monthly_sales) AS decimal(5, 2)) AS pct_retail,
  CAST(100.0 * MAX(CASE WHEN platform = 'Shopify' THEN monthly_sales END)
	/ SUM(monthly_sales) AS decimal(5, 2)) AS pct_shopify
FROM sales_cte
GROUP BY calendar_year,  month_number
ORDER BY calendar_year, month_number;


--7. What is the percentage of sales by demographic for each year in the dataset?

WITH sales_by_demographic AS (
  SELECT 
    calendar_year,
    demographic,
    SUM(sales) AS sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, demographic)

SELECT 
  calendar_year,
  CAST(100.0 * MAX(CASE WHEN demographic = 'Families' THEN sales END)
	/ SUM(sales) AS decimal(5, 2)) AS pct_families,
  CAST(100.0 * MAX(CASE WHEN demographic = 'Couples' THEN sales END) 
	/ SUM(sales) AS decimal(5, 2)) AS pct_couples,
  CAST(100.0 * MAX(CASE WHEN demographic = 'unknown' THEN sales END)
	/ SUM(sales) AS decimal(5, 2)) AS pct_unknown
FROM sales_by_demographic
GROUP BY calendar_year;


--8. Which age_band and demographic values contribute the most to Retail sales?

DECLARE @retailSales bigint = (
  SELECT SUM(sales)
  FROM clean_weekly_sales
  WHERE platform = 'Retail')
				
SELECT 
  age_band,
  demographic,
  SUM(sales) AS sales,
  CAST(100.0 * SUM(sales)/@retailSales AS decimal(5, 2)) AS contribution
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY contribution DESC;


--9.Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?

SELECT 
  calendar_year,
  platform,
  ROUND(AVG(avg_transaction), 0) AS avg_transaction_row,
  SUM(sales) / SUM(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
