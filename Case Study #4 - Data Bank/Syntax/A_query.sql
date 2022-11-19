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
  COUNT(n.customer_id) AS nodes
FROM customer_nodes n
JOIN regions r
  ON n.region_id = r.region_id
GROUP BY r.region_id, r.region_name
ORDER BY r.region_id;


--4. How many days on average are customers reallocated to a different node?

WITH customerDates AS (
  SELECT 
    customer_id,
    node_id,
    MIN(start_date) AS start_date
  FROM customer_nodes
  GROUP BY customer_id, node_id
),
reallocation AS (
  SELECT
    customer_id,
    node_id,
    start_date,
    DATEDIFF(DAY, start_date, LEAD(start_date) OVER(PARTITION BY customer_id ORDER BY start_date)) AS moving_days
  FROM customerDates
)

SELECT 
  AVG(CAST(moving_days AS FLOAT)) AS avg_moving_days
FROM reallocation;
