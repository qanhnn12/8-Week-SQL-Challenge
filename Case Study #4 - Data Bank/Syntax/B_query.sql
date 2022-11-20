----------------------------
--B. Customer Transactions--
----------------------------

--1. What is the unique count and total amount for each transaction type?

SELECT 
	txn_type,
	COUNT(*) AS unique_count,
	SUM(txn_amount) AS total_amount
FROM customer_transactions
GROUP BY txn_type;

