# 🐟 Case Study #6 - Clique Bait
## A. Digital Analysis
### 1. How many users are there?
```TSQL
SELECT COUNT(DISTINCT user_id) AS users_count
FROM users;
```
| users_count  |
|--------------|
| 500          |

---
### 2. How many cookies does each user have on average?
```TSQL
SELECT CAST(AVG(cookies_count) AS FLOAT) AS avg_cookies_per_user
FROM (
  SELECT 
    user_id,
    1.0*COUNT(cookie_id) AS cookies_count
  FROM users
  GROUP BY user_id) temp;
```
| avg_cookies_per_user  |
|-----------------------|
| 3.564                 |

---
### 3. What is the unique number of visits by all users per month?
```TSQL
SELECT 
  MONTH(event_time) AS months,
  COUNT(DISTINCT visit_id) AS visits_count
FROM events
GROUP BY MONTH(event_time)
ORDER BY months;
```
| months | visits_count  |
|--------|---------------|
| 1      | 876           |
| 2      | 1488          |
| 3      | 916           |
| 4      | 248           |
| 5      | 36            |

---
### 4. What is the number of events for each event type?
```TSQL
SELECT 
  e.event_type,
  ei.event_name,
  COUNT(*) AS event_count
FROM events e
JOIN event_identifier ei
  ON e.event_type = ei.event_type
GROUP BY e.event_type, ei.event_name
ORDER BY e.event_type;
```
| event_type | event_name    | event_count  |
|------------|---------------|--------------|
| 1          | Page View     | 20928        |
| 2          | Add to Cart   | 8451         |
| 3          | Purchase      | 1777         |
| 4          | Ad Impression | 876          |
| 5          | Ad Click      | 702          |

---
### 5. What is the percentage of visits which have a purchase event?
```TSQL
SELECT 
  CAST(100.0 * COUNT(DISTINCT e.visit_id) 
       / (SELECT COUNT(DISTINCT visit_id) FROM events) AS decimal(10,2)) AS purchase_pct
FROM events e
JOIN event_identifier ei
  ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase';
```
| purchase_pct  |
|---------------|
| 49.86         |

---
### 6. What is the percentage of visits which view the checkout page but do not have a purchase event?
```TSQL
WITH view_checkout AS (
  SELECT COUNT(e.visit_id) AS cnt
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  JOIN page_hierarchy p ON e.page_id = p.page_id
  WHERE ei.event_name = 'Page View'
    AND p.page_name = 'Checkout'
)

SELECT CAST(100-(100.0 * COUNT(DISTINCT e.visit_id) 
		/ (SELECT cnt FROM view_checkout)) AS decimal(10, 2)) AS pct_view_checkout_not_purchase
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type
WHERE ei.event_name = 'Purchase'
```
| pct_view_checkout_not_purchase  |
|---------------------------------|
| 15.50                           |

---
### 7. What are the top 3 pages by number of views?
```TSQL
SELECT 
  TOP 3 ph.page_name,
  COUNT(*) AS page_views
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type 
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE ei.event_name = 'Page View'
GROUP BY ph.page_name
ORDER BY page_views DESC;
```
| page_name    | page_views  |
|--------------|-------------|
| All Products | 3174        |
| Checkout     | 2103        |
| Home Page    | 1782        |

---
### 8. What is the number of views and cart adds for each product category?
```TSQL
SELECT 
  ph.product_category,
  SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
  SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type
JOIN page_hierarchy ph ON e.page_id = ph.page_id
WHERE ph.product_category IS NOT NULL
GROUP BY ph.product_category;
```
| product_category | page_views | cart_adds  |
|------------------|------------|------------|
| Fish             | 4633       | 2789       |
| Luxury           | 3032       | 1870       |
| Shellfish        | 6204       | 3792       |

---
### 9. What are the top 3 products by purchases?
```TSQL
SELECT 
  TOP 3 ph.product_id,
  ph.page_name,
  ph.product_category,
  COUNT(*) AS purchase_count
FROM events e
JOIN event_identifier ei ON e.event_type = ei.event_type
JOIN page_hierarchy ph ON e.page_id = ph.page_id
--1st layer: products are added to cart
WHERE ei.event_name = 'Add to cart'
--2nd layer: add-to-cart products are purchased
AND e.visit_id IN (
  SELECT e.visit_id
  FROM events e
  JOIN event_identifier ei ON e.event_type = ei.event_type
  WHERE ei.event_name = 'Purchase')
GROUP BY ph.product_id,	ph.page_name, ph.product_category
ORDER BY purchase_count DESC;
```
| product_id | page_name | product_category | purchase_count  |
|------------|-----------|------------------|-----------------|
| 7          | Lobster   | Shellfish        | 754             |
| 9          | Oyster    | Shellfish        | 726             |
| 8          | Crab      | Shellfish        | 719             |

---
My solution for **[B. Product Funnel Analysis](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution/B.%20Product%20Funnel%20Analysis.md)**.
