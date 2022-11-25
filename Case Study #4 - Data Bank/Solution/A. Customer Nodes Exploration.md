# 📊 Case Study #4 - Data Bank
## A. Customer Nodes Exploration
### 1. How many unique nodes are there on the Data Bank system?
```TSQL
SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;
```
| unique_nodes  |
|---------------|
| 5             |

---
### 2. What is the number of nodes per region?
```TSQL
SELECT 
  r.region_id,
  r.region_name,
  COUNT(n.node_id) AS nodes
FROM customer_nodes n
JOIN regions r
  ON n.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;
```
| region_id | region_name | nodes  |
|-----------|-------------|--------|
| 1         | Australia   | 770    |
| 2         | America     | 735    |
| 3         | Africa      | 714    |
| 4         | Asia        | 665    |
| 5         | Europe      | 616    |

---
### 3. How many customers are allocated to each region?
```TSQL
SELECT 
  r.region_id,
  r.region_name,
  COUNT(DISTINCT n.customer_id) AS customers
FROM customer_nodes n
JOIN regions r
  ON n.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;
```
| region_id | region_name | customers  |
|-----------|-------------|------------|
| 1         | Australia   | 110        |
| 2         | America     | 105        |
| 3         | Africa      | 102        |
| 4         | Asia        | 95         |
| 5         | Europe      | 88         |

---
### 4. How many days on average are customers reallocated to a different node?
  * Create a CTE ```customerDates``` containing the first date of every customer in each node
  * Create a CTE ```reallocation``` to calculate the difference in days between the first date in this node and the first date in next node
  * Take the average of those day differences
```TSQL
WITH customerDates AS (
  SELECT 
    customer_id,
    region_id,
    node_id,
    MIN(start_date) AS first_date
  FROM customer_nodes
  GROUP BY customer_id, region_id, node_id
),
reallocation AS (
  SELECT
    customer_id,
    node_id,
    region_id,
    first_date,
    DATEDIFF(DAY, first_date, 
             LEAD(first_date) OVER(PARTITION BY customer_id 
                                   ORDER BY first_date)) AS moving_days
  FROM customerDates
)

SELECT 
  AVG(CAST(moving_days AS FLOAT)) AS avg_moving_days
FROM reallocation;
```
| avg_moving_days  |
|------------------|
| 23.6889920424403 |

On average, it takes 24 days for a customer to reallocate to a different node.

---
### 5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?
Using 2 CTEs in the previous questions ```customerDates``` and ```reallocation``` to calculate the median, 80th and 95th percentile for reallocation days in each region.
```TSQL
WITH customerDates AS (
  SELECT 
    customer_id,
    region_id,
    node_id,
    MIN(start_date) AS first_date
  FROM customer_nodes
  GROUP BY customer_id, region_id, node_id
),
reallocation AS (
  SELECT
    customer_id,
    region_id,
    node_id,
    first_date,
    DATEDIFF(DAY, first_date, 
             LEAD(first_date) OVER(PARTITION BY customer_id 
                                   ORDER BY first_date)) AS moving_days
  FROM customerDates
)

SELECT 
  DISTINCT r.region_id,
  rg.region_name,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.moving_days) OVER(PARTITION BY r.region_id) AS median,
  PERCENTILE_CONT(0.8) WITHIN GROUP (ORDER BY r.moving_days) OVER(PARTITION BY r.region_id) AS percentile_80,
  PERCENTILE_CONT(0.95) WITHIN GROUP (ORDER BY r.moving_days) OVER(PARTITION BY r.region_id) AS percentile_95
FROM reallocation r
JOIN regions rg ON r.region_id = rg.region_id
WHERE moving_days IS NOT NULL;
```
| region_id | region_name | median | percentile_80 | percentile_95  |
|-----------|-------------|--------|---------------|----------------|
| 1         | Australia   | 22     | 31            | 54             |
| 2         | America     | 21     | 33.2          | 57             |
| 3         | Africa      | 21     | 33.2          | 58.8           |
| 4         | Asia        | 22     | 32.4          | 49.85          |
| 5         | Europe      | 22     | 31            | 54.3           |

---
My solution for **[B. Customer Transactions](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%234%20-%20Data%20Bank/Solution/B.%20Customer%20Transactions.md)**.
