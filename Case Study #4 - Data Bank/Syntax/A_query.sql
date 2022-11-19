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

