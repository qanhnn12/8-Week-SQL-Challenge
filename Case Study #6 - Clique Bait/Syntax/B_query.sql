------------------------------
--3. Product Funnel Analysis--
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
FROM product_info pi
JOIN product_abandoned pa ON pi.product_id = pa.product_id
JOIN product_purchased pp ON pi.product_id = pp.product_id;
