# 📊 Case Study #4 - Data Bank
## B. Customer Transactions
### 1. What is the unique count and total amount for each transaction type?
```TSQL
SELECT 
  txn_type,
  COUNT(*) AS unique_count,
  SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;
```
| txn_type   | unique_count | total_amount  |
|------------|--------------|---------------|
| withdrawal | 1580         | 793003        |
| deposit    | 2671         | 1359168       |
| purchase   | 1617         | 806537        |

---
### 2. What is the average total historical deposit counts and amounts for all customers?
```TSQL
WITH customerDeposit AS (
  SELECT 
    customer_id,
    txn_type,
    COUNT(*) AS dep_count,
    SUM(txn_amount) AS dep_amount
  FROM customer_transactions
  WHERE txn_type = 'deposit'
  GROUP BY customer_id, txn_type
)

SELECT
  AVG(dep_count) AS avg_dep_count,
  AVG(dep_amount) AS avg_dep_amount
FROM customerDeposit;
```
| avg_dep_count | avg_dep_amount  |
|---------------|-----------------|
| 5             | 2718            |

---
### 3. For each month - how many Data Bank customers make more than 1 deposit and either 1 purchase or 1 withdrawal in a single month?
```TSQL
WITH cte_transaction AS (
  SELECT 
    customer_id,
    MONTH(txn_date) AS months,
    SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
    SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count,
    SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count
  FROM customer_transactions
  GROUP BY customer_id, MONTH(txn_date)
)

SELECT 
  months,
  COUNT(customer_id) AS customer_count
FROM cte_transaction
WHERE deposit_count > 1
  AND (purchase_count = 1 OR withdrawal_count = 1)
GROUP BY months;
```
| months | customer_count  |
|--------|-----------------|
| 1      | 115             |
| 2      | 108             |
| 3      | 113             |
| 4      | 50              |

---
### 4. What is the closing balance for each customer at the end of the month?
Closing balance of at the end of this month = closing balance in the previous month + total transaction in this month. 
If the outflow (withdrawal and purchase) > inflow (deposit), the transaction is negative.
  * Create a CTE ```monthly_transaction``` to find the SUM of all transactions in every month for each customer.
  * Create a CTE ```recursive_date``` to make a list of last days in each month for each customer. 
  * ```LEFT JOIN``` from ```recursive_dates``` to ```monthly_transactions``` to display all end dates of every month for each customer.
  * Calculate the monthly closing balance by taking the SUM of all transactions between the preceding row and current row.

```TSQL
--End date in the month of the max date of our dataset
DECLARE @maxDate DATE;
SET @maxDate = (SELECT EOMONTH(MAX(txn_date)) FROM customer_transactions);

--CTE 1: Monthly transactions of each customer
WITH monthly_transactions AS (
  SELECT
    customer_id,
    EOMONTH(txn_date) AS end_date,
    SUM(CASE WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
             ELSE txn_amount END) AS transactions
  FROM customer_transactions
  GROUP BY customer_id, EOMONTH(txn_date)
),

--CTE 2: Increment last days of each month till they are equal to @maxDate 
recursive_dates AS (
  SELECT
    DISTINCT customer_id,
    CAST('2020-01-31' AS DATE) AS end_date
  FROM customer_transactions
  UNION ALL
  SELECT 
    customer_id,
    EOMONTH(DATEADD(MONTH, 1, end_date)) AS end_date
  FROM recursive_dates
  WHERE EOMONTH(DATEADD(MONTH, 1, end_date)) <= @maxDate
)

SELECT 
  r.customer_id,
  r.end_date,
  COALESCE(m.transactions, 0) AS transactions,
  SUM(m.transactions) OVER (PARTITION BY r.customer_id ORDER BY r.end_date 
      ROWS UNBOUNDED PRECEDING) AS closing_balance
FROM recursive_dates r
LEFT JOIN  monthly_transactions m
  ON r.customer_id = m.customer_id
  AND r.end_date = m.end_date;
```
A part of the result (2000 rows):

| customer_id | end_date   | transactions | closing_balance  |
|-------------|------------|--------------|------------------|
| 1           | 2020-01-31 | 312          | 312              |
| 1           | 2020-02-29 | 0            | 312              |
| 1           | 2020-03-31 | -952         | -640             |
| 1           | 2020-04-30 | 0            | -640             |
| 2           | 2020-01-31 | 549          | 549              |
| 2           | 2020-02-29 | 0            | 549              |
| 2           | 2020-03-31 | 61           | 610              |
| 2           | 2020-04-30 | 0            | 610              |
| 3           | 2020-01-31 | 144          | 144              |
| 3           | 2020-02-29 | -965         | -821             |
| 3           | 2020-03-31 | -401         | -1222            |
| 3           | 2020-04-30 | 493          | -729             |
| 4           | 2020-01-31 | 848          | 848              |
| 4           | 2020-02-29 | 0            | 848              |
| 4           | 2020-03-31 | -193         | 655              |
| 4           | 2020-04-30 | 0            | 655              |
| 5           | 2020-01-31 | 954          | 954              |
| 5           | 2020-02-29 | 0            | 954              |
| 5           | 2020-03-31 | -2877        | -1923            |

---
### 5. What is the percentage of customers who increase their closing balance by more than 5%?
This question is not clear. It should be "*calculate the percentage of customers who increase their closing balance by more than 5% compared to the previous month*".
  * Copy 2 CTEs in the previous question.
  * Create a CTE ```customers_balance```by using the calculation for the closing balance in the previous question. 
  * Create a new CTE ```customers_next_balance``` to calculate the closing balance next month: ```next_balance```.
  * The percentage increase of the closing balance = 100 * (next balance - closing balance) / closing balance. 
  * Exclude ```closing_balance``` rows that are 0 (prevent *divide by 0 error*) and ```next_balance``` rows that are NULL (last row of each partition in ```LEAD```)
  * Create a temporary table ```#temp``` to prevent the error *"Warning: Null value is eliminated by an aggregate or other SET operation"*.
  * Count the number of customers increasing their closing balance by more than 5%, then divide that by the total number of customers.
  
```TSQL
--End date in the month of the max date of our dataset (Q4)
DECLARE @maxDate DATE;
SET @maxDate = (SELECT EOMONTH(MAX(txn_date)) FROM customer_transactions);

--CTE 1: Monthly transactions of each customer (Q4)
WITH monthly_transactions AS (
  SELECT
    customer_id,
    EOMONTH(txn_date) AS end_date,
    SUM(CASE WHEN txn_type IN ('withdrawal', 'purchase') THEN -txn_amount
             ELSE txn_amount END) AS transactions
  FROM customer_transactions
  GROUP BY customer_id, EOMONTH(txn_date)
),

--CTE 2: Increment last days of each month till they are equal to @maxDate (Q4)
recursive_dates AS (
  SELECT
    DISTINCT customer_id,
    CAST('2020-01-31' AS DATE) AS end_date
  FROM customer_transactions
  UNION ALL
  SELECT 
    customer_id,
    EOMONTH(DATEADD(MONTH, 1, end_date)) AS end_date
  FROM recursive_dates
  WHERE EOMONTH(DATEADD(MONTH, 1, end_date)) <= @maxDate
),

-- CTE 3: Closing balance of each customer by monthly (Q4)
customers_balance AS (
  SELECT 
    r.customer_id,
    r.end_date,
    COALESCE(m.transactions, 0) AS transactions,
    SUM(m.transactions) OVER (PARTITION BY r.customer_id ORDER BY r.end_date 
        ROWS UNBOUNDED PRECEDING) AS closing_balance
    FROM recursive_dates r
    LEFT JOIN  monthly_transactions m
      ON r.customer_id = m.customer_id
      AND r.end_date = m.end_date
),

--CTE 4: CTE 3 & next_balance
customers_next_balance AS (
  SELECT *,
    LEAD(closing_balance) OVER(PARTITION BY customer_id ORDER BY end_date) AS next_balance
  FROM customers_balance
),

--CTE 5: Calculate the increase percentage of closing balance for each customer
pct_increase AS (
  SELECT *,
    100.0*(next_balance-closing_balance)/closing_balance AS pct
  FROM customers_next_balance
  WHERE closing_balance ! = 0 AND next_balance IS NOT NULL
)

--Create a temporary table because of the error: Null value is eliminated by an aggregate or other SET operation
SELECT *
INTO #temp
FROM pct_increase;

--Calculate the percentage of customers whose closing balance increasing 5% compared to the previous month
SELECT CAST(100.0*COUNT(DISTINCT customer_id) AS FLOAT)
      / (SELECT COUNT(DISTINCT customer_id) FROM customer_transactions) AS pct_customers
FROM #temp
WHERE pct > 5;
```
| pct_customers  |
|----------------|
| 75.8           |

75.8% of customers increasing their closing balance by more than 5% compared to the previous month.
