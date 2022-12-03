# 👕 Case Study #7 - Balanced Tree Clothing Co.
## C. Product Analysis
### 1. What are the top 3 products by total revenue before discount?
```TSQL
SELECT 
  TOP 3 pd.product_name,
  SUM(s.qty * s.price) AS revenue_before_discount
FROM sales s
JOIN product_details pd 
  ON s.prod_id = pd.product_id
GROUP BY pd.product_name
ORDER BY SUM(s.qty * s.price) DESC;
```
| product_name                 | revenue_before_discount  |
|------------------------------|--------------------------|
| Blue Polo Shirt - Mens       | 217683                   |
| Grey Fashion Jacket - Womens | 209304                   |
| White Tee Shirt - Mens       | 152000                   |

---
### 2. What is the total quantity, revenue and discount for each segment?
```TSQL
SELECT 
  pd.segment_name,
  SUM(s.qty) total_quantity,
  SUM(s.qty * s.price) AS total_revenue_before_discount,
  SUM(s.qty * s.price * discount) AS total_discount
FROM sales s
JOIN product_details pd 
  ON s.prod_id = pd.product_id
GROUP BY pd.segment_name;
```
| segment_name | total_quantity | total_revenue_before_discount | total_discount  |
|--------------|----------------|-------------------------------|-----------------|
| Jacket       | 11385          | 366983                        | 4427746         |
| Jeans        | 11349          | 208350                        | 2534397         |
| Shirt        | 11265          | 406143                        | 4959427         |
| Socks        | 11217          | 307977                        | 3701344         |

---
### 3. What is the top selling product for each segment?
```TSQL
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
```
| segment_name | top_selling_product           | total_quantity  |
|--------------|-------------------------------|-----------------|
| Jacket       | Grey Fashion Jacket - Womens  | 3876            |
| Jeans        | Navy Oversized Jeans - Womens | 3856            |
| Shirt        | Blue Polo Shirt - Mens        | 3819            |
| Socks        | Navy Solid Socks - Mens       | 3792            |

---
### 4. What is the total quantity, revenue and discount for each category?
```TSQL
SELECT 
  pd.category_name,
  SUM(s.qty) AS total_quantity,
  SUM(s.qty * s.price) AS total_revenue,
  SUM(s.qty * s.price * s.discount/100) AS total_discount
FROM sales s
JOIN product_details pd 
  ON s.prod_id = pd.product_id
GROUP BY pd.category_name;
```
| category_name | total_quantity | total_revenue | total_discount  |
|---------------|----------------|---------------|-----------------|
| Mens          | 22482          | 714120        | 83362           |
| Womens        | 22734          | 575333        | 66124           |

---
### 5. What is the top selling product for each category?
```TSQL
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
```
| category_name | top_selling_product          | total_quantity  |
|---------------|------------------------------|-----------------|
| Mens          | Blue Polo Shirt - Mens       | 3819            |
| Womens        | Grey Fashion Jacket - Womens | 3876            |

---
### 6. What is the percentage split of revenue by product for each segment?
```TSQL
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
```
| segment_name | product_name                     | segment_product_pct  |
|--------------|----------------------------------|----------------------|
| Jacket       | Grey Fashion Jacket - Womens     | 57.03                |
| Jacket       | Indigo Rain Jacket - Womens      | 19.45                |
| Jacket       | Khaki Suit Jacket - Womens       | 23.51                |
| Jeans        | Black Straight Jeans - Womens    | 58.15                |
| Jeans        | Cream Relaxed Jeans - Womens     | 17.79                |
| Jeans        | Navy Oversized Jeans - Womens    | 24.06                |
| Shirt        | Blue Polo Shirt - Mens           | 53.60                |
| Shirt        | Teal Button Up Shirt - Mens      | 8.98                 |
| Shirt        | White Tee Shirt - Mens           | 37.43                |
| Socks        | Navy Solid Socks - Mens          | 44.33                |
| Socks        | Pink Fluro Polkadot Socks - Mens | 35.50                |
| Socks        | White Striped Socks - Mens       | 20.18                |

---
### 7. What is the percentage split of revenue by segment for each category?
```TSQL
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
```
| segment_name | category_name | segment_category_pct  |
|--------------|---------------|-----------------------|
| Shirt        | Mens          | 56.87                 |
| Socks        | Mens          | 43.13                 |
| Jacket       | Womens        | 63.79                 |
| Jeans        | Womens        | 36.21                 |

---
### 8. What is the percentage split of total revenue by category?
```TSQL
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
```
| category_name | category_pct  |
|---------------|---------------|
| Mens          | 55.38         |
| Womens        | 44.62         |

---
### 9. What is the total transaction “penetration” for each product? 
(hint: penetration = number of transactions where at least 1 quantity of a product was purchased divided by total number of transactions)
```TSQL
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
```
| prod_id | product_name                     | product_txn | total_txn | penetration_pct  |
|---------|----------------------------------|-------------|-----------|------------------|
| c4a632  | Navy Oversized Jeans - Womens    | 1274        | 2500      | 50.96            |
| 2a2353  | Blue Polo Shirt - Mens           | 1268        | 2500      | 50.72            |
| e31d39  | Cream Relaxed Jeans - Womens     | 1243        | 2500      | 49.72            |
| 9ec847  | Grey Fashion Jacket - Womens     | 1275        | 2500      | 51.00            |
| c8d436  | Teal Button Up Shirt - Mens      | 1242        | 2500      | 49.68            |
| e83aa3  | Black Straight Jeans - Womens    | 1246        | 2500      | 49.84            |
| 5d267b  | White Tee Shirt - Mens           | 1268        | 2500      | 50.72            |
| d5e9a6  | Khaki Suit Jacket - Womens       | 1247        | 2500      | 49.88            |
| f084eb  | Navy Solid Socks - Mens          | 1281        | 2500      | 51.24            |
| 2feb6b  | Pink Fluro Polkadot Socks - Mens | 1258        | 2500      | 50.32            |
| b9a74d  | White Striped Socks - Mens       | 1243        | 2500      | 49.72            |
| 72f5d4  | Indigo Rain Jacket - Womens      | 1250        | 2500      | 50.00            |

---
### 10. What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?
```TSQL
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
    STRING_AGG(product_id, ', ') WITHIN GROUP (ORDER BY product_id)  AS product_ids,
    STRING_AGG(product_name, ', ') WITHIN GROUP (ORDER BY product_id) AS product_names
  FROM products_per_transaction
  WHERE cnt = 3
  GROUP BY txn_id
),

--Count the number of times each combination appears
combination_count AS (
  SELECT 
    product_ids,
    product_names,
    COUNT (*) AS common_combinations
  FROM combinations
  GROUP BY product_ids, product_names
)

--Filter the most common combinations
SELECT 
    product_ids,
    product_names
FROM combination_count
WHERE common_combinations = (SELECT MAX(common_combinations) 
			     FROM combination_count);
```
| product_ids            | product_names                                                                              |
|------------------------|--------------------------------------------------------------------------------------------|
| 2a2353, 2feb6b, c4a632 | Blue Polo Shirt - Mens, Pink Fluro Polkadot Socks - Mens, Navy Oversized Jeans - Womens    |
| c4a632, c8d436, e83aa3 | Navy Oversized Jeans - Womens, Teal Button Up Shirt - Mens, Black Straight Jeans - Womens  |
| b9a74d, c4a632, d5e9a6 | White Striped Socks - Mens, Navy Oversized Jeans - Womens, Khaki Suit Jacket - Womens      |
| 5d267b, c4a632, e83aa3 | White Tee Shirt - Mens, Navy Oversized Jeans - Womens, Black Straight Jeans - Womens       |
| 5d267b, c4a632, e31d39 | White Tee Shirt - Mens, Navy Oversized Jeans - Womens, Cream Relaxed Jeans - Womens        |

---
My solution for **[D. Bonus Question](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./Solution/D.%20Bonus%20Question.md)**.
