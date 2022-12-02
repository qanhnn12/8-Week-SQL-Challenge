--------------------------------
--A. High Level Sales Analysis--
--------------------------------

--1. What was the total quantity sold for all products?

SELECT SUM(qty) AS total_quantity
FROM sales;


--2. What is the total generated revenue for all products before discounts?

SELECT SUM(qty * price) AS revenue_before_discounts
FROM sales;


--3. What was the total discount amount for all products?

SELECT CAST(SUM(qty * price * discount/100.0) AS FLOAT) AS total_discount
FROM sales;
