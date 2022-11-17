--------------------------------
--D. Outside The Box Questions--
--------------------------------

/*
Note:
- I choose the year of 2020 to analyze because I already create the [payments] table in part C.
- If you want to incorporate the data in 2021 to see the whole picture (quarterly, 2020-2021 comparison, etc.), 
create a new [payments] table and change the conditions in part C to '2021-12-31'.
*/

--1.How would you calculate the rate of growth for Foodie-Fi?

WITH monthlyRevenue AS (
	SELECT 
		MONTH(payment_date) AS months,
		SUM(amount) AS revenue
	FROM payments
	GROUP BY MONTH(payment_date)
)

SELECT 
	months,
	revenue,
	(revenue-LAG(revenue) OVER(ORDER BY months))/revenue AS revenue_growth
FROM monthlyRevenue;


