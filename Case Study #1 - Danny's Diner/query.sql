--------------------------------
--CASE STUDY #1: DANNY'S DINER--
--------------------------------

--Author: Anh Nguyen
--Date: 05/11/2022
--Tool used: MS SQL Server

CREATE SCHEMA dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');

SELECT *
FROM dbo.members;

SELECT *
FROM dbo.menu;

SELECT *
FROM dbo.sales;

------------------------
--CASE STUDY QUESTIONS--
------------------------

-- 1. What is the total amount each customer spent at the restaurant?

SELECT 
  s.customer_id,
  SUM(m.price) AS total_pay
FROM sales s
JOIN menu m
	ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;

-- 2. How many days has each customer visited the restaurant?

SELECT 
	customer_id,
	COUNT(DISTINCT order_date) AS visit_count
FROM sales 
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

WITH orderRank AS (
	SELECT 
		customer_id,
		product_id,
		order_date,
		DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY order_date) AS rnk
	FROM sales
)

SELECT 
	o.customer_id,
	o.order_date,
	m.product_name
FROM orderRank o
JOIN menu m 
	ON o.product_id = m.product_id
WHERE o.rnk = 1
GROUP BY o.customer_id, o.order_date, m.product_name


