------------------------------
--B. Data Analysis Questions--
------------------------------

--1. How many customers has Foodie-Fi ever had?

SELECT COUNT(DISTINCT customer_id)
FROM subscriptions;


--2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?

SELECT 
  MONTH(s.start_date) AS months,
  COUNT(*) AS distribution_values
FROM subscriptions s
JOIN plans p 
  ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY MONTH(s.start_date);


--3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?

SELECT 
  YEAR(s.start_date) AS events,
  p.plan_name,
  COUNT(*) AS counts
FROM subscriptions s
JOIN plans p 
  ON s.plan_id = p.plan_id
WHERE YEAR(s.start_date) > 2020
GROUP BY YEAR(s.start_date), p.plan_name;


--4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?

SELECT 
  SUM(CASE WHEN p.plan_name = 'churn' THEN 1 END) AS churn_count,
  CAST(100*SUM(CASE WHEN p.plan_name = 'churn' THEN 1 END) AS FLOAT) 
    / COUNT(DISTINCT customer_id) AS churn_pct
FROM subscriptions s
JOIN plans p 
  ON s.plan_id = p.plan_id;


--5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?

WITH customersPlan AS (
  SELECT 
    s.customer_id,
    s.start_date,
    p.plan_name,
    LEAD(p.plan_name) OVER(PARTITION BY s.customer_id 
			ORDER BY p.plan_id) AS next_plan
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
)

SELECT 
  COUNT(*) AS churn_after_trial,
  100*COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS pct
FROM customersPlan
WHERE plan_name = 'trial' 
  AND next_plan = 'churn';


--6. What is the number and percentage of customer plans after their initial free trial?

WITH nextPlan AS (
  SELECT 
    s.customer_id,
    s.start_date,
    p.plan_name,
    LEAD(p.plan_name) OVER(PARTITION BY s.customer_id 
			ORDER BY p.plan_id) AS next_plan
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
)

SELECT 
  next_plan,
  COUNT(*) AS customer_plan,
  CAST(100 * COUNT(*) AS FLOAT) 
      / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS percentage
FROM nextPlan
WHERE next_plan IS NOT NULL
  AND plan_name = 'trial'
GROUP BY next_plan;


--9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?

WITH trialPlan AS (
  SELECT 
    s.customer_id,
    s.start_date AS trial_date
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
  WHERE p.plan_name = 'trial'
)
,
annualPlan AS (
  SELECT 
    s.customer_id,
    s.start_date AS annual_date
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
  WHERE p.plan_name = 'pro annual'
)

SELECT 
  AVG(CAST(DATEDIFF(d, trial_date, annual_date) AS FLOAT)) AS avg_days_to_annual
FROM trialPlan t
JOIN annualPlan a 
ON t.customer_id = a.customer_id;
