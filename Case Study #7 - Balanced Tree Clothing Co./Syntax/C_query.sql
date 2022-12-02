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

WITH segment_product_quantity AS (
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
FROM segment_product_quantity
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

WITH category_product_quantity AS (
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
FROM category_product_quantity
WHERE rnk = 1;


--6. What is the percentage split of revenue by product for each segment?

WITH segment_product_revenue AS (
  SELECT 
    pd.segment_name,
    pd.product_name,
    SUM(s.qty * s.price) AS product_revenue
  FROM sales s
  JOIN product_details pd 
    ON s.prod_id = pd.product_id
  GROUP BY pd.segment_name, pd.product_name
)

SELECT 
  segment_name,
  product_name,
  CAST(100.0 * product_revenue 
	/ SUM(product_revenue) OVER (PARTITION BY segment_name) 
    AS decimal (10, 2)) AS segment_product_pct
FROM segment_product_revenue;


--7. What is the percentage split of revenue by segment for each category?

WITH segment_category_revenue AS (
  SELECT 
    pd.segment_name,
    pd.category_name,
    SUM(s.qty * s.price) AS category_revenue
  FROM sales s
  JOIN product_details pd 
    ON s.prod_id = pd.product_id
  GROUP BY pd.segment_name, pd.category_name
)

SELECT 
  segment_name,
  category_name,
  CAST(100.0 * category_revenue 
	/ SUM(category_revenue) OVER (PARTITION BY category_name) 
    AS decimal (10, 2)) AS segment_category_pct
FROM segment_category_revenue;


--8. What is the percentage split of total revenue by category?

WITH category_revenue AS (
  SELECT 
    pd.category_name,
    SUM(s.qty * s.price) AS revenue
  FROM sales s
  JOIN product_details pd 
    ON s.prod_id = pd.product_id
  GROUP BY pd.category_name
)

SELECT 
  category_name,
  CAST(100.0 * revenue / SUM(revenue) OVER () AS decimal (10, 2)) AS category_pct
FROM category_revenue;


--9. What is the total transaction “penetration” for each product? 
--(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)

WITH product_transations AS (
  SELECT 
    DISTINCT s.prod_id, pd.product_name,
    COUNT(DISTINCT s.txn_id) AS product_txn,
    (SELECT COUNT(DISTINCT txn_id) FROM sales) AS total_txn
  FROM sales s
  JOIN product_details pd 
    ON s.prod_id = pd.product_id
  GROUP BY prod_id, pd.product_name
)

SELECT 
  *,
  CAST(100.0 * product_txn / total_txn AS decimal(10,2)) AS penetration_pct
FROM product_transations;


--10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?

--Count the number of products in each transaction
WITH products_per_transaction AS (
  SELECT 
    s.txn_id,
    pd.product_id,
    pd.product_name,
    s.qty,
    COUNT(pd.product_id) OVER (PARTITION BY txn_id) AS cnt
  FROM sales s
  JOIN product_details pd 
  ON s.prod_id = pd.product_id
),

--Filter transactions that have the 3 products and group them to a cell
combinations AS (
  SELECT 
    STRING_AGG(product_id, ', ') AS products_id,
    STRING_AGG(product_name, ', ') AS products_name
  FROM products_per_transaction
  WHERE cnt = 3
  GROUP BY txn_id
),

--Count the number of times each combination appears
combination_count AS (
  SELECT 
    products_id,
    products_name,
    COUNT (*) AS common_combinations
  FROM combinations
  GROUP BY products_id, products_name
)

--Filter the most common combinations
SELECT 
  products_id,
  products_name
FROM combination_count
WHERE common_combinations = (SELECT MAX(common_combinations) 
			     FROM combination_count);
