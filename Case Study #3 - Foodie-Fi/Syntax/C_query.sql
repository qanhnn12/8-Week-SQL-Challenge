---------------------------------
--C. Challenge Payment Question--
---------------------------------

/*
The Foodie-Fi team wants you to create a new payments table for the year 2020 that includes amounts paid 
by each customer in the subscriptions table with the following requirements:
- monthly payments always occur on the same day of month as the original start_date of any monthly paid plan
- upgrades from basic to monthly or pro plans are reduced by the current paid amount in that month and start immediately
- upgrades from pro monthly to pro annual are paid at the end of the current billing period and also starts at the end of the month period
- once a customer churns they will no longer make payments
*/


--Copy the column definition from table [subscriptions] and [plans] and paste them to table [payments]

SELECT 
  s.customer_id, 
  s.plan_id, 
  p.plan_name, 
  s.start_date AS payment_date, 
  p.price AS amount, 
  ROW_NUMBER() OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS payment_order
INTO payments
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE 1=0;


--Use CTE recursive to add 1 month for all paid plans in 2020 except 'pro annual'

WITH dateRecursion AS (
  SELECT 
    s.customer_id,
    s.plan_id,
    p.plan_name,
    s.start_date AS payment_date,
    p.price AS amount
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
  WHERE p.plan_name NOT IN ('trial', 'churn')
  AND YEAR(start_date) = 2020

  UNION ALL

  SELECT 
    customer_id,
    plan_id,
    plan_name,
    DATEADD(MONTH, 1, payment_date) AS payment_date,
    amount
  FROM dateRecursion

  WHERE DATEDIFF(MONTH, DATEADD(MONTH, 1, payment_date), '2020-12-31') >= 0
    AND plan_name != 'pro annual'
)


--Insert values to table [payments]

INSERT INTO payments 
  (customer_id, plan_id, plan_name, payment_date, amount, payment_order)
  
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) AS payment_order
  FROM dateRecursion
  ORDER BY customer_id
  OPTION (MAXRECURSION 365);
