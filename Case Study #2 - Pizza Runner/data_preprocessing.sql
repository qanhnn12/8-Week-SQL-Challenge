----------------------
--DATA PREPROCESSING--
----------------------


-- Create a new temporary table: #customer_orders_temp

SELECT 
    order_id,
    customer_id,
    pizza_id,
    CASE 
    	WHEN exclusions IS NULL OR exclusions LIKE 'null' THEN ''
      	ELSE exclusions 
      	END AS exclusions,
    CASE 
    	WHEN extras IS NULL OR extras LIKE 'null' THEN ''
      	ELSE extras 
      	END AS extras,
    order_time
INTO #customer_orders_temp
FROM customer_orders;


-- Create a new temporary table: #runner_orders_temp

SELECT 
    order_id,
    runner_id,
    CAST(
    	CASE WHEN pickup_time LIKE 'null' THEN NULL ELSE pickup_time END 
	AS DATETIME) AS pickup_time,
    CAST(
    	CASE 
	    WHEN distance LIKE 'null' THEN null
	    WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
	    ELSE distance END
        AS FLOAT) AS distance,
    CAST(
    	CASE 
	    WHEN duration LIKE 'null' THEN NULL
	    WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
	    WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
	    WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
	    ELSE duration END
        AS INT) AS duration,
    CASE
        WHEN cancellation IN ('null', 'NaN', '') THEN NULL 
        ELSE cancellation
        END AS cancellation
INTO #runner_orders_temp
FROM runner_orders;