# 🐟 Case Study #6 - Clique Bait
## B. Product Funnel Analysis
Using a single SQL query - create a new output table which has the following details:
  * How many times was each product viewed?
  * How many times was each product added to cart?
  * How many times was each product added to a cart but not purchased (abandoned)?
  * How many times was each product purchased?

### Solution

The output table will look like:

| Columns          | Description                                                               |
|------------------|---------------------------------------------------------------------------|
| product_id       | Id of each product                                                        |
| product_name     | Name of each product                                                      |
| product_category | Category of each product                                                  |
| views            | Number of times each product viewed                                       |
| cart_adds        | Number of times each product added to cart                                |
| abondoned        | Number of times each product added to cart but not purchased (abandoned)  |
| purchases        | Number of times each product purchased                                    |

* Create a CTE `product_info`: calculate the number of `views` and number of `cart_adds` for each product using `CASE` and `SUM`
* Create a CTE `product_abandoned`: calculate the number of abandoned products (replace `IN` by `NOT IN` in the solution for Question 9 in part A). 
* Create a CTE `product_purchased`: calculate the number of purchased products (solution for Question 9 in part A)
* `JOIN` 3 CTEs using `product_id`, `product_name` and `product_category` of each product
* Store the result in a temporary table `product_summary` for further analysis

```TSQL
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
  --1st layer: products are added to cart
  WHERE ei.event_name = 'Add to cart'
  --2nd layer: add-to-cart products are NOT purchased
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
  --1st layer: products are added to cart
  WHERE ei.event_name = 'Add to cart'
  --2nd layer: add-to-cart products are purchased
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

SELECT *
FROM #product_summary;
```
| product_id | product_name   | product_category | views | cart_adds | abandoned | purchases  |
|------------|----------------|------------------|-------|-----------|-----------|------------|
| 1          | Salmon         | Fish             | 1559  | 938       | 227       | 711        |
| 2          | Kingfish       | Fish             | 1559  | 920       | 213       | 707        |
| 3          | Tuna           | Fish             | 1515  | 931       | 234       | 697        |
| 4          | Russian Caviar | Luxury           | 1563  | 946       | 249       | 697        |
| 5          | Black Truffle  | Luxury           | 1469  | 924       | 217       | 707        |
| 6          | Abalone        | Shellfish        | 1525  | 932       | 233       | 699        |
| 7          | Lobster        | Shellfish        | 1547  | 968       | 214       | 754        |
| 8          | Crab           | Shellfish        | 1564  | 949       | 230       | 719        |
| 9          | Oyster         | Shellfish        | 1568  | 943       | 217       | 726        |

---
Additionally, create another table which further aggregates the data for the above points but this time for each product category instead of individual products.

### Solution
Simply remove `product_id` and `product_name` in each CTE table above.

```TSQL
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
```
| product_category | views | cart_adds | abandoned | purchases  |
|------------------|-------|-----------|-----------|------------|
| Fish             | 4633  | 2789      | 674       | 2115       |
| Luxury           | 3032  | 1870      | 466       | 1404       |
| Shellfish        | 6204  | 3792      | 894       | 2898       |

---
Use 2 new output tables - answer the following questions:

#### 1. Which product had the most views, cart adds and purchases?
```TSQL
SELECT TOP 1 *
FROM #product_summary
ORDER BY views DESC;
```

| product_id | product_name | product_category | views | cart_adds | abandoned | purchases  |
|------------|--------------|------------------|-------|-----------|-----------|------------|
| 9          | Oyster       | Shellfish        | 1568  | 943       | 217       | 726        |

```TSQL
SELECT TOP 1 *
FROM #product_summary
ORDER BY cart_adds DESC;
```
| product_id | product_name | product_category | views | cart_adds | abandoned | purchases  |
|------------|--------------|------------------|-------|-----------|-----------|------------|
| 7          | Lobster      | Shellfish        | 1547  | 968       | 214       | 754        |

```TSQL
SELECT TOP 1 *
FROM #product_summary
ORDER BY purchases DESC;
```
| product_id | product_name | product_category | views | cart_adds | abandoned | purchases  |
|------------|--------------|------------------|-------|-----------|-----------|------------|
| 7          | Lobster      | Shellfish        | 1547  | 968       | 214       | 754        |


#### 2. Which product was most likely to be abandoned?
```TSQL
SELECT TOP 1 *
FROM #product_summary
ORDER BY abandoned DESC;
```
| product_id | product_name   | product_category | views | cart_adds | abandoned | purchases  |
|------------|----------------|------------------|-------|-----------|-----------|------------|
| 4          | Russian Caviar | Luxury           | 1563  | 946       | 249       | 697        |

#### 3. Which product had the highest view to purchase percentage?
```TSQL
SELECT 
  TOP 1 product_name,
  product_category,
  CAST(100.0 * purchases / views AS decimal(10, 2)) AS purchase_per_view_pct
FROM #product_summary
ORDER BY purchase_per_view_pct DESC;
```
| product_name | product_category | purchase_per_view_pct  |
|--------------|------------------|------------------------|
| Lobster      | Shellfish        | 48.74                  |


#### 4. What is the average conversion rate from view to cart add?
```TSQL
SELECT 
  CAST(AVG(100.0*cart_adds/views) AS decimal(10, 2)) AS avg_view_to_cart
FROM #product_summary;
```
| avg_view_to_cart  |
|-------------------|
| 60.95              |

#### 5. What is the average conversion rate from cart add to purchase?
```TSQL
SELECT 
  CAST(AVG(100.0*purchases/cart_adds) AS decimal(10, 2)) AS avg_cart_to_purchase
FROM #product_summary;
```
| avg_cart_to_purchase  |
|-----------------------|
| 75.93                  |

---
My solution for **[C. Campaigns Analysis](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%236%20-%20Clique%20Bait/Solution/C.%20Campaigns%20Analysis.md)**.
