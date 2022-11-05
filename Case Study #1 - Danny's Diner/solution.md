# 🍜 Case Study #1 - Danny's Diner
<p align="center">
<img src="https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/IMG/1.png" align="center" width="400" height="400" >
  
  
## 📕 Table of Contents
* Bussiness task
* Entity relationship diagram
* Case study questions
* My solution
  
## 🛠️ Bussiness task
Danny wants to use the data to answer a few simple questions about his customers, especially about their visiting patterns, how much money they’ve spent and also which menu items are their favourite. Having this deeper connection with his customers will help him deliver a better and more personalised experience for his loyal customers.

## 🔐 Entity relationship diagram
<p align="center">
<img src="https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/IMG/e1.PNG" align="center" width="500" height="250" >

## ❓ Case study questions
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

## 🚀 My solution
View the complete syntax [here](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%231%20-%20Danny's%20Diner/query.sql).
  
---
### Q1. What is the total amount each customer spent at the restaurant?
```SQL:
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

  
