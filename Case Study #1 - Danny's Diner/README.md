# 🍜 Case Study #1 - Danny's Diner
<p align="center">
<img src="https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/IMG/1.png" align="center" width="400" height="400" >
  
## 📕 Table of Contents
* [Bussiness Task](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#%EF%B8%8F-bussiness-task)
* [Entity Relationship Diagram](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#-entity-relationship-diagram)
* [Case Study Questions](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#-case-study-questions)
* [Bonus Questions](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#%EF%B8%8F-bonus-questions)  
* [My Solution](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%231%20-%20Danny's%20Diner#-my-solution)

---
## 🛠️ Bussiness Task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

---
## 🔐 Entity Relationship Diagram
<p align="center">
<img src="https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/IMG/e1.PNG" align="center" width="500" height="250" >

---
## ❓ Case Study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
  not just sushi - how many points do customer A and B have at the end of January?

---
## 🗒️ Bonus Questions
* Join All The Things - Create a table that has these columns: customer_id, order_date, product_name, price, member (Y/N).
* Rank All The Things - Based on the table above, add one column: ranking.  

---
## 🚀 My Solution
*View the complete syntax [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/query.sql).*
  
### Q1. What is the total amount each customer spent at the restaurant?
```TSQL
SELECT 
  s.customer_id,
  SUM(m.price) AS total_pay
FROM sales s
JOIN menu m
  ON s.product_id = m.product_id
GROUP BY s.customer_id
ORDER BY s.customer_id;
```
|  customer_id | total_pay  |
|---|---|
|A	|76|
|B	|74|
|C	|36|

  
---
### Q2. How many days has each customer visited the restaurant?
```TSQL
SELECT 
  customer_id,
  COUNT(DISTINCT order_date) AS visit_count
FROM sales 
GROUP BY customer_id;
```
|  customer_id | visit_count  |
|---|---|
|A	|4|
|B	|6|
|C	|2|

  
---
### Q3. What was the first item from the menu purchased by each customer?
```TSQL
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
GROUP BY o.customer_id, o.order_date, m.product_name;
```
| customer_id | order_date | product_name |
|---|------------|-------|
| A | 2021-01-01 | curry |
| A | 2021-01-01 | sushi |
| B | 2021-01-01 | curry |
| C | 2021-01-01 | ramen |
  
  
---
### Q4. What is the most purchased item on the menu and how many times was it purchased by all customers?
```SQL
SELECT
  TOP 1 s.product_id,
  m.product_name,
  COUNT(*) AS most_purch
FROM sales s
JOIN menu m 
  ON s.product_id = m.product_id
GROUP BY s.product_id, m.product_name;

```
| product_id | product_name | most_purch |
|------------|--------------|------------|
| 3          | ramen        | 8          |
  
  
---
### Q5. Which item was the most popular for each customer?
```TSQL
WITH freqRank AS (
  SELECT
    customer_id,
    product_id,
    COUNT(*) AS purch_freq,
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS rnk
  FROM sales
  GROUP BY customer_id, product_id
)

SELECT 
  f.customer_id,
  m.product_name,
  f.purch_freq
FROM freqRank f
JOIN menu m 
  ON f.product_id = m.product_id
WHERE f.rnk = 1
ORDER BY f.customer_id;
```
| customer_id | product_name | purch_freq |
|-------------|--------------|------------|
| A           | ramen        | 3          |
| B           | sushi        | 2          |
| B           | curry        | 2          |
| B           | ramen        | 2          |
| C           | ramen        | 3          |
  
  
---
### Q6. Which item was purchased first by the customer after they became a member?
```TSQL
WITH orderAfterMember AS (
  SELECT 
    s.customer_id,
    mn.product_name,
    s.order_date,
    m.join_date,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date) AS rnk
  FROM sales s
  JOIN members m 
    ON s.customer_id = m.customer_id
  JOIN menu mn 
    ON s.product_id = mn.product_id
  WHERE s.order_date >= m.join_date
)

SELECT 
  customer_id,
  product_name,
  order_date,
  join_date
FROM orderAfterMember
WHERE rnk = 1;

```
| customer_id | product_name | order_date | join_date  |
|-------------|--------------|------------|------------|
| A           | curry        | 2021-01-07 | 2021-01-07 |
| B           | sushi        | 2021-01-11 | 2021-01-09 |


---
### Q7. Which item was purchased just before the customer became a member?
```TSQL
WITH orderBeforeMember AS (
  SELECT 
    s.customer_id,
    mn.product_name,
    s.order_date,
    m.join_date,
    DENSE_RANK() OVER(PARTITION BY s.customer_id ORDER BY s.order_date DESC) AS rnk
  FROM sales s
  JOIN members m 
    ON s.customer_id = m.customer_id
  JOIN menu mn 
    ON s.product_id = mn.product_id
  WHERE s.order_date < m.join_date
)

SELECT 
  customer_id,
  product_name,
  order_date,
  join_date
FROM orderBeforeMember
WHERE rnk = 1;
```  
| customer_id | product_name | order_date | join_date  |
|-------------|--------------|------------|------------|
| A           | sushi        | 2021-01-01 | 2021-01-07 |
| A           | curry        | 2021-01-01 | 2021-01-07 |
| B           | sushi        | 2021-01-04 | 2021-01-09 |

                                  
---
### Q8. What is the total items and amount spent for each member before they became a member?
```TSQL
SELECT 
  s.customer_id,
  COUNT(s.product_id) AS total_items,
  SUM(mn.price) AS total_spend
FROM sales s
JOIN members m 
  ON s.customer_id = m.customer_id
JOIN menu mn 
  ON s.product_id = mn.product_id
WHERE s.order_date < m.join_date
GROUP BY s.customer_id;
```
| customer_id | total_items | total_spend |
|-------------|-------------|-------------|
| A           | 2           | 25          |
| B           | 3           | 40          |

  
---
### Q9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
Note: Only customers who are members receive points when purchasing items
```TSQL
WITH CustomerPoints AS (
  SELECT 
    s.customer_id,
    CASE 
      WHEN s.customer_id IN (SELECT customer_id FROM members) AND mn.product_name = 'sushi' THEN mn.price*20
      WHEN s.customer_id IN (SELECT customer_id FROM members) AND mn.product_name != 'sushi' THEN mn.price*10 
    ELSE 0 END AS points
  FROM menu mn 
  JOIN sales s
    ON mn.product_id = s.product_id
)

SELECT 
  customer_id,
  SUM(points) AS total_points
FROM CustomerPoints
GROUP BY customer_id;
```
| customer_id | total_points |
|-------------|--------------|
| A           | 860          |
| B           | 940          |
| C           | 0            |
  
--- 
### Q10. In the first week after a customer joins the program (including their join date), they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
```TSQL
WITH programDates AS (
  SELECT 
    customer_id, 
    join_date,
    DATEADD(d, 6, join_date) AS valid_date, 
    EOMONTH('2021-01-01') AS last_date
  FROM members
)

SELECT 
  p.customer_id,
  SUM(CASE 
      	WHEN s.order_date BETWEEN p.join_date AND p.valid_date THEN m.price*20
      	WHEN m.product_name = 'sushi' THEN m.price*20
      ELSE m.price*10 END) AS total_points
FROM sales s
JOIN programDates p 
  ON s.customer_id = p.customer_id
JOIN menu m 
  ON s.product_id = m.product_id
WHERE s.order_date <= last_date
GROUP BY p.customer_id;
```
| customer_id | total_points |
|-------------|--------------|
| A           | 1370         |
| B           | 820          |          
                              
---
### Join All The Things 
```TSQL
SELECT 
  s.customer_id,
  s.order_date,
  mn.product_name,
  mn.price,
  CASE WHEN s.order_date >= m.join_date THEN 'Y'
    ELSE 'N' END AS member
FROM sales s
JOIN menu mn 
  ON s.product_id = mn.product_id
LEFT JOIN members m 
  ON s.customer_id = m.customer_id;
```
| customer_id | order_date | product_name | price | member |
|-------------|------------|--------------|-------|--------|
| A           | 2021-01-01 | sushi        | 10    | N      |
| A           | 2021-01-01 | curry        | 15    | N      |
| A           | 2021-01-07 | curry        | 15    | Y      |
| A           | 2021-01-10 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| A           | 2021-01-11 | ramen        | 12    | Y      |
| B           | 2021-01-01 | curry        | 15    | N      |
| B           | 2021-01-02 | curry        | 15    | N      |
| B           | 2021-01-04 | sushi        | 10    | N      |
| B           | 2021-01-11 | sushi        | 10    | Y      |
| B           | 2021-01-16 | ramen        | 12    | Y      |
| B           | 2021-02-01 | ramen        | 12    | Y      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-01 | ramen        | 12    | N      |
| C           | 2021-01-07 | ramen        | 12    | N      |

---
### Rank All The Things

```TSQL
WITH customerStatus AS(
SELECT 
  s.customer_id,
  s.order_date,
  mn.product_name,
  mn.price,
  CASE WHEN s.order_date >= m.join_date THEN 'Y'
    ELSE 'N' END AS member
FROM sales s
JOIN menu mn 
  ON s.product_id = mn.product_id
LEFT JOIN members m 
  ON s.customer_id = m.customer_id
)

SELECT *,
  CASE WHEN member = 'Y' 
  	THEN DENSE_RANK() OVER(PARTITION BY customer_id, member ORDER BY order_date)
  ELSE null END AS ranking
FROM customerStatus;
```
| customer_id | order_date | product_name | price | member | ranking |
|-------------|------------|--------------|-------|--------|---------|
| A           | 2021-01-01 | sushi        | 10    | N      | NULL    |
| A           | 2021-01-01 | curry        | 15    | N      | NULL    |
| A           | 2021-01-07 | curry        | 15    | Y      | 1       |
| A           | 2021-01-10 | ramen        | 12    | Y      | 2       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| A           | 2021-01-11 | ramen        | 12    | Y      | 3       |
| B           | 2021-01-01 | curry        | 15    | N      | NULL    |
| B           | 2021-01-02 | curry        | 15    | N      | NULL    |
| B           | 2021-01-04 | sushi        | 10    | N      | NULL    |
| B           | 2021-01-11 | sushi        | 10    | Y      | 1       |
| B           | 2021-01-16 | ramen        | 12    | Y      | 2       |
| B           | 2021-02-01 | ramen        | 12    | Y      | 3       |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-01 | ramen        | 12    | N      | NULL    |
| C           | 2021-01-07 | ramen        | 12    | N      | NULL    |
