-----------------------
--C. Product Analysis--
-----------------------

--1. What are the top 3 products by total revenue before discount?

SELECT 
  TOP 3 pd.product_name,
  SUM(s.qty * s.price) AS revenue_before_discount
FROM sales s
JOIN product_details pd 
  ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY SUM(s.qty * s.price) DESC;


--2. What is the total quantity, revenue and discount for each segment?

SELECT 
  pd.segment_name,
  SUM(s.qty) total_quantity,
  SUM(s.qty * s.price) AS total_revenue_before_discount,
  SUM(s.qty * s.price * discount) AS total_discount
FROM sales s
JOIN product_details pd 
  ON s.prod_id = pd.product_id
GROUP BY pd.segment_name;


--3. What is the top selling product for each segment?

WITH segment_sales AS (
SELECT 
  pd.segment_name,
  pd.product_name,
  SUM(s.qty) AS total_quantity,
  DENSE_RANK() OVER (PARTITION BY pd.segment_name ORDER BY SUM(s.qty) DESC) AS rnk
FROM sales s
JOIN product_details pd 
  ON s.prod_id = pd.product_id
GROUP BY pd.segment_name, pd.product_name
)

SELECT 
  segment_name,
  product_name AS top_selling_product,
  total_quantity
FROM segment_sales
WHERE rnk = 1;


--4. What is the total quantity, revenue and discount for each category?

SELECT 
  pd.category_name,
  SUM(s.qty) AS total_quantity,
  SUM(s.qty * s.price) AS total_revenue,
  SUM(s.qty * s.price * s.discount/100) AS total_discount
FROM sales s
JOIN product_details pd 
  ON s.prod_id = pd.product_id
GROUP BY pd.category_name;


--5. What is the top selling product for each category?

WITH category_sales AS (
  SELECT 
    pd.category_name,
    pd.product_name,
    SUM(s.qty) AS total_quantity,
    DENSE_RANK() OVER (PARTITION BY pd.category_name ORDER BY SUM(s.qty) DESC) AS rnk
  FROM sales s
  JOIN product_details pd 
    ON s.prod_id = pd.product_id
  GROUP BY pd.category_name, pd.product_name
)

SELECT 
  category_name,
  product_name AS top_selling_product,
  total_quantity
FROM category_sales
WHERE rnk = 1;


