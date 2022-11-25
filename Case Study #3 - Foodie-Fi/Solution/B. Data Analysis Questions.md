# 🥑 Case Study #3 - Foodie-Fi
## B. Data Analysis Questions
### 1. How many customers has Foodie-Fi ever had?
```TSQL
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM subscriptions;
```
| unique_customers  |
|-------------------|
| 1000              |

---
### 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value?
```TSQL
SELECT 
  MONTH(s.start_date) AS months,
  COUNT(*) AS distribution_values
FROM subscriptions s
JOIN plans p 
  ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
GROUP BY MONTH(s.start_date);
```
| months | distribution_values  |
|--------|----------------------|
| 1      | 88                   |
| 2      | 68                   |
| 3      | 94                   |
| 4      | 81                   |
| 5      | 88                   |
| 6      | 79                   |
| 7      | 89                   |
| 8      | 88                   |
| 9      | 87                   |
| 10     | 79                   |
| 11     | 75                   |
| 12     | 84                   |

---
### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name?
```TSQL
SELECT 
  YEAR(s.start_date) AS events,
  p.plan_name,
  COUNT(*) AS counts
FROM subscriptions s
JOIN plans p 
  ON s.plan_id = p.plan_id
WHERE YEAR(s.start_date) > 2020
GROUP BY YEAR(s.start_date), p.plan_name;
```
| events | plan_name     | counts  |
|--------|---------------|---------|
| 2021   | basic monthly | 8       |
| 2021   | churn         | 71      |
| 2021   | pro annual    | 63      |
| 2021   | pro monthly   | 60      |

---
### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
```TSQL
SELECT 
  SUM(CASE WHEN p.plan_name = 'churn' THEN 1 END) AS churn_count,
  CAST(100*SUM(CASE WHEN p.plan_name = 'churn' THEN 1 END) AS FLOAT(1)) 
    / COUNT(DISTINCT customer_id) AS churn_pct
FROM subscriptions s
JOIN plans p 
  ON s.plan_id = p.plan_id;
```
| churn_count | churn_pct   |
|-------------|-------------|
| 307         | 30.7        |

---
### 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
```TSQL
WITH nextPlan AS (
  SELECT 
    s.customer_id,
    s.start_date,
    p.plan_name,
    LEAD(p.plan_name) OVER(PARTITION BY s.customer_id ORDER BY p.plan_id) AS next_plan
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
)

SELECT 
  COUNT(*) AS churn_after_trial,
  100*COUNT(*) / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS pct
FROM nextPlan
WHERE plan_name = 'trial' 
  AND next_plan = 'churn';
```
| churn_after_trial | pct         |
|-------------------|-------------|
| 92                | 9           |

---
### 6. What is the number and percentage of customer plans after their initial free trial?
```TSQL
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
```
| next_plan     | customer_plan | percentage  |
|---------------|---------------|-------------|
| basic monthly | 546           | 54.6        |
| churn         | 92            | 9.2         |
| pro annual    | 37            | 3.7         |
| pro monthly   | 325           | 32.5        |

---
### 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
```TSQL
WITH plansDate AS (
  SELECT 
    s.customer_id,
    s.start_date,
	p.plan_id,
    p.plan_name,
    LEAD(s.start_date) OVER(PARTITION BY s.customer_id ORDER BY s.start_date) AS next_date
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
)

SELECT 
  plan_id,
  plan_name,
  COUNT(*) AS customers,
  CAST(100*COUNT(*) AS FLOAT) 
      / (SELECT COUNT(DISTINCT customer_id) FROM subscriptions) AS conversion_rate
FROM plansDate
WHERE (next_date IS NOT NULL AND (start_date < '2020-12-31' AND next_date > '2020-12-31'))
  OR (next_date IS NULL AND start_date < '2020-12-31')
GROUP BY plan_id, plan_name
ORDER BY plan_id;
```
| plan_id | plan_name     | customers | conversion_rate  |
|---------|---------------|-----------|------------------|
| 0       | trial         | 19        | 1.9              |
| 1       | basic monthly | 224       | 22.4             |
| 2       | pro monthly   | 326       | 32.6             |
| 3       | pro annual    | 195       | 19.5             |
| 4       | churn         | 235       | 23.5             |

---
### 8. How many customers have upgraded to an annual plan in 2020?
```TSQL
SELECT 
  COUNT(DISTINCT customer_id) AS customer_count
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE p.plan_name = 'pro annual'
  AND YEAR(s.start_date) = 2020;
```
| customer_count  |
|-----------------|
| 195             |

---
### 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
```TSQL
WITH trialPlan AS (
  SELECT 
    s.customer_id,
    s.start_date AS trial_date
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
  WHERE p.plan_name = 'trial'
),
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
```
| avg_days_to_annual  |
|---------------------|
| 104.62015503876     |

On average, it takes 105 days for a customer to an annual plan from the day they join Foodie-Fi.

---
### 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)?
To solve this question: 
* Utilize 2 CTEs in the previous question: ```trialPlan``` and ```annualPlan``` to calculate the number of days between ```trial_date``` and ```annual_date```, then put that to new CTE named ```datesDiff```
* Create a recursive CTE named ```daysRecursion``` to generate 30-day periods (i.e. 0-30 days, 31-60 days etc)
* Left join from ```daysRecursion``` to ```datesDiff``` 
    
```TSQL
WITH trialPlan AS (
  SELECT 
    s.customer_id,
    s.start_date AS trial_date
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
  WHERE p.plan_name = 'trial'
),
annualPlan AS (
  SELECT 
    s.customer_id,
    s.start_date AS annual_date
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
  WHERE p.plan_name = 'pro annual'
),
datesDiff AS (
  SELECT 
    t.customer_id,
    DATEDIFF(d, trial_date, annual_date) AS diff
  FROM trialPlan t
  JOIN annualPlan a ON t.customer_id = a.customer_id
),
daysRecursion AS (
  SELECT 
    0 AS start_period, 
    30 AS end_period
  UNION ALL
  SELECT 
    end_period + 1 AS start_period,
    end_period + 30 AS end_period
  FROM daysRecursion
  WHERE end_period < 360
)

SELECT 
  dr.start_period,
  dr.end_period,
  COUNT(*) AS customer_count
FROM daysRecursion dr
LEFT JOIN datesDiff dd 
  ON (dd.diff >= dr.start_period AND dd.diff <= dr.end_period)
GROUP BY dr.start_period, dr.end_period;
```
| start_period | end_period | customer_count  |
|--------------|------------|-----------------|
| 0            | 30         | 49              |
| 31           | 60         | 24              |
| 61           | 90         | 34              |
| 91           | 120        | 35              |
| 121          | 150        | 42              |
| 151          | 180        | 36              |
| 181          | 210        | 26              |
| 211          | 240        | 4               |
| 241          | 270        | 5               |
| 271          | 300        | 1               |
| 301          | 330        | 1               |
| 331          | 360        | 1               |

---
### 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
```TSQL
WITH nextPlan AS (
  SELECT 
    s.customer_id,
    s.start_date,
    p.plan_name,
    LEAD(p.plan_name) OVER(PARTITION BY s.customer_id ORDER BY p.plan_id) AS next_plan
  FROM subscriptions s
  JOIN plans p ON s.plan_id = p.plan_id
)

SELECT COUNT(*) AS pro_to_basic_monthly
FROM nextPlan
WHERE plan_name = 'pro monthly'
  AND next_plan = 'basic monthly'
  AND YEAR(start_date) = 2020;
```
| pro_to_basic_monthly|
|---------------------|
| 0                   |

There were no customers downgrading from a pro monthly to a basic monthly plan in 2020.

---
My solution for **[C. Challenge Payment Question](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/C.%20Challenge%20Payment%20Question.md)**.
