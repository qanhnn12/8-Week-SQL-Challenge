-----------------------
--2. Data Exploration--
-----------------------

--1. What day of the week is used for each week_date value?

SELECT 
	DISTINCT(DATENAME(dw, week_date)) AS week_date_value
FROM clean_weekly_sales;

