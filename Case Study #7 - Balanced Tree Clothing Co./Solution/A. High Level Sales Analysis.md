# 👕 Case Study #7 - Balanced Tree Clothing Co.
## A. High Level Sales Analysis
### 1. What was the total quantity sold for all products?
```TSQL
SELECT SUM(qty) AS total_quantity
FROM sales;
```
| total_quantity  |
|-----------------|
| 45216           |

---
### 2. What is the total generated revenue for all products before discounts?
```TSQL
SELECT SUM(qty * price) AS revenue_before_discounts
FROM sales;
```
| revenue_before_discounts  |
|---------------------------|
| 1289453                   |

---
### 3. What was the total discount amount for all products?
```TSQL
SELECT CAST(SUM(qty * price * discount/100.0) AS FLOAT) AS total_discount
FROM sales;
```
| total_discount  |
|-----------------|
| 156229.14       |

---
My solution for **[B. Transaction Analysis](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%237%20-%20Balanced%20Tree%20Clothing%20Co./Solution/B.%20Transaction%20Analysis.md)**.
