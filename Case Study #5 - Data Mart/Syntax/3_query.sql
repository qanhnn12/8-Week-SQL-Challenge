------------------------------
--3. Before & After Analysis--
------------------------------

--Find the week_number of '2020-06-15' (@weekNum)
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
FROM salesChanges

