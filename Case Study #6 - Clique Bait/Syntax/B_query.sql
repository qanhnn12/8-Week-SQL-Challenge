------------------------------
--B. Product Funnel Analysis--
------------------------------

/*
Using a single SQL query - create a new output table which has the following details:
- How many times was each product viewed?
- How many times was each product added to cart?
- How many times was each product added to a cart but not purchased (abandoned)?
- How many times was each product purchased?
*/

WITH product_info AS (
  SELECT 
    ph.product_id,
    ph.page_name AS product_name,
    ph.product_category,
    SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS views,
    SUM(CASE WHEN ei.event_name = 'Add To Cart' THEN 1 ELSE 0 END) AS cart_adds
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy ph ON e.page_id = ph.page_id
  WHERE ph.product_id IS NOT NULL
  GROUP BY ph.product_id, ph.page_name, ph.product_category 
),
product_abandoned AS (
  SELECT 
    ph.product_id,
    ph.page_name AS product_name,
    ph.product_category,
    COUNT(*) AS abandoned
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy ph ON e.page_id = ph.page_id
  WHERE ei.event_name = 'Add to cart'
  AND e.visit_id NOT IN (
    SELECT e.visit_id
    FROM events e
    JOIN event_identifier ei ON e.event_type = ei.event_type
    WHERE ei.event_name = 'Purchase')
    GROUP BY ph.product_id, ph.page_name, ph.product_category
),
product_purchased AS (
  SELECT 
    ph.product_id,
    ph.page_name AS product_name,
    ph.product_category,
    COUNT(*) AS purchases
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy ph ON e.page_id = ph.page_id
  WHERE ei.event_name = 'Add to cart'
  AND e.visit_id IN (
    SELECT e.visit_id
    FROM events e
    JOIN event_identifier ei ON e.event_type = ei.event_type
    WHERE ei.event_name = 'Purchase')
    GROUP BY ph.product_id, ph.page_name, ph.product_category
)

SELECT 
  pi.*,
  pa.abandoned,
  pp.purchases
INTO #product_summary
FROM product_info pi
JOIN product_abandoned pa ON pi.product_id = pa.product_id
JOIN product_purchased pp ON pi.product_id = pp.product_id;


/*
Additionally, create another table which further aggregates the data for the above points 
but this time for each product category instead of individual products.
*/

WITH category_info AS (
  SELECT 
    ph.product_category,
    SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS views,
    SUM(CASE WHEN ei.event_name = 'Add To Cart' THEN 1 ELSE 0 END) AS cart_adds
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy ph ON e.page_id = ph.page_id
  WHERE ph.product_id IS NOT NULL
  GROUP BY ph.product_category 
),
category_abandoned AS (
  SELECT 
    ph.product_category,
    COUNT(*) AS abandoned
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy ph ON e.page_id = ph.page_id
  WHERE ei.event_name = 'Add to cart'
  AND e.visit_id NOT IN (
    SELECT e.visit_id
    FROM events e
    JOIN event_identifier ei ON e.event_type = ei.event_type
    WHERE ei.event_name = 'Purchase')
    GROUP BY ph.product_category
),
category_purchased AS (
  SELECT 
    ph.product_category,
    COUNT(*) AS purchases
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy ph ON e.page_id = ph.page_id
  WHERE ei.event_name = 'Add to cart'
  AND e.visit_id IN (
    SELECT e.visit_id
    FROM events e
    JOIN event_identifier ei ON e.event_type = ei.event_type
    WHERE ei.event_name = 'Purchase')
    GROUP BY ph.product_category
)

SELECT 
  ci.*,
  ca.abandoned,
  cp.purchases
FROM category_info ci
JOIN category_abandoned ca ON ci.product_category = ca.product_category
JOIN category_purchased cp ON ci.product_category = cp.product_category;


--Use your 2 new output tables - answer the following questions:
--1. Which product had the most views, cart adds and purchases?

SELECT TOP 1 *
FROM #product_summary
ORDER BY views DESC;
--> Oyster has the most views.

SELECT TOP 1 *
FROM #product_summary
ORDER BY cart_adds DESC;
--> Lobster had the most cart adds.

SELECT TOP 1 *
FROM #product_summary
ORDER BY purchases DESC;
--> Lobster had the most purchases.


--2. Which product was most likely to be abandoned?
SELECT TOP 1 *
FROM #product_summary
ORDER BY abandoned DESC;
--> Russian Caviar was most likely to be abandoned.


--3. Which product had the highest view to purchase percentage?
SELECT 
  TOP 1 product_name,
  product_category,
  CAST(100.0 * purchases / views AS decimal(10, 2)) AS purchase_per_view_pct
FROM #product_summary
ORDER BY purchase_per_view_pct DESC;
--> Lobster had the highest view to purchase percentage?


--4. What is the average conversion rate from view to cart add?
SELECT 
  CAST(AVG(100.0*cart_adds/views) AS decimal(10, 2)) AS avg_view_to_cart
FROM #product_summary;


--5. What is the average conversion rate from cart add to purchase?
SELECT 
  CAST(AVG(100.0*purchases/cart_adds) AS decimal(10, 2)) AS avg_cart_to_purchase
FROM #product_summary;
