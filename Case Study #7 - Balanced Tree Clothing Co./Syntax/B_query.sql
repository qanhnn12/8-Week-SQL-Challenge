---------------------------
--B. Transaction Analysis--
---------------------------

--1. How many unique transactions were there?

SELECT COUNT(DISTINCT txn_id) AS unique_transactions
FROM sales;


--2.What is the average unique products purchased in each transaction?

SELECT AVG(product_count) AS avg_unique_products
FROM (
  SELECT 
    txn_id,
    COUNT(DISTINCT prod_id) AS product_count
  FROM sales 
  GROUP BY txn_id
) temp;


--3. What are the 25th, 50th and 75th percentile values for the revenue per transaction?

WITH transaction_revenue AS (
  SELECT 
    txn_id,
    SUM(qty*price) AS revenue
  FROM sales
  GROUP BY txn_id)

SELECT 
  DISTINCT 
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY revenue) OVER () AS pct_25th,
  PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY revenue) OVER () AS pct_50th,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY revenue) OVER () AS pct_75th
FROM transaction_revenue;


--4. What is the average discount value per transaction?

SELECT CAST(AVG(total_discount) AS decimal(5, 1)) AS avg_discount_per_transaction
FROM (
  SELECT 
    txn_id,
    SUM(qty*price*discount/100.0) AS total_discount
  FROM sales
  GROUP BY txn_id
) temp;


--5. What is the percentage split of all transactions for members vs non-members?

SELECT 
  CAST(100.0*COUNT(DISTINCT CASE WHEN member = 1 THEN txn_id END) 
		/ COUNT(DISTINCT txn_id) AS FLOAT) AS members_pct,
  CAST(100.0*COUNT(DISTINCT CASE WHEN member = 0 THEN txn_id END)
		/ COUNT(DISTINCT txn_id) AS FLOAT) AS non_members_pct
FROM sales;


--6. What is the average revenue for member transactions and non-member transactions?

WITH member_revenue AS (
  SELECT 
    member,
    txn_id,
    SUM(qty*price) AS revenue
  FROM sales
  GROUP BY member, txn_id
) 

SELECT 
  member,
  CAST(AVG(1.0*revenue) AS decimal(10,2)) AS avg_revenue
FROM member_revenue
GROUP BY member;
