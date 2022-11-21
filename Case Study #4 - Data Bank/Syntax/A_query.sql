---------------------------------
--A. Customer Nodes Exploration--
---------------------------------

--1. How many unique nodes are there on the Data Bank system?

SELECT COUNT(DISTINCT node_id) AS unique_nodes
FROM customer_nodes;


--2. What is the number of nodes per region?

SELECT 
  r.region_id,
  r.region_name,
  COUNT(n.node_id) AS nodes
FROM customer_nodes n
JOIN regions r
  ON n.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;


--3. How many customers are allocated to each region?

SELECT 
  r.region_id,
  r.region_name,
  COUNT(DISTINCT n.customer_id) AS customers
FROM customer_nodes n
JOIN regions r
  ON n.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;


--4. How many days on average are customers reallocated to a different node?

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


--5. What is the median, 80th and 95th percentile for this same reallocation days metric for each region?

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
    DATEDIFF(DAY, first_date, LEAD(first_date) OVER(PARTITION BY customer_id ORDER BY first_date)) AS moving_days
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
