# 🍕 Case Study #2 - Pizza Runner
## A. Pizza Metrics
### Data cleaning
  
  * Create a temporary table ```#customer_orders_temp``` from ```customer_orders``` table:
  	* Convert ```null``` values and ```'null'``` text values in ```exclusions``` and ```extras``` into blank ```''```.
  
  ```TSQL
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
  
  SELECT *
  FROM #customer_orders_temp;
  ```
| order_id | customer_id | pizza_id | exclusions | extras | order_time               |
|----------|-------------|----------|------------|--------|--------------------------|
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02.000  |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52.000  |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23.000  |
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23.000  |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000  |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000  |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46.000  |
| 5        | 104         | 1        |            | 1      | 2020-01-08 21:00:29.000  |
| 6        | 101         | 2        |            |        | 2020-01-08 21:03:13.000  |
| 7        | 105         | 2        |            | 1      | 2020-01-08 21:20:29.000  |
| 8        | 102         | 1        |            |        | 2020-01-09 23:54:33.000  |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59.000  |
| 10       | 104         | 1        |            |        | 2020-01-11 18:34:49.000  |
  
  
  * Create a temporary table ```#runner_orders_temp``` from ```runner_orders``` table:
  	* Convert ```'null'``` text values in ```pickup_time```, ```duration``` and ```cancellation``` into ```null``` values. 
	* Cast ```pickup_time``` to DATETIME.
	* Cast ```distance``` to FLOAT.
	* Cast ```duration``` to INT.
  
  ```TSQL
  SELECT 
    order_id,
    runner_id,
    CAST(
    	CASE WHEN pickup_time LIKE 'null' THEN NULL ELSE pickup_time END 
	    AS DATETIME) AS pickup_time,
    CAST(
    	CASE WHEN distance LIKE 'null' THEN NULL
	      WHEN distance LIKE '%km' THEN TRIM('km' FROM distance)
	      ELSE distance END
      AS FLOAT) AS distance,
    CAST(
    	CASE WHEN duration LIKE 'null' THEN NULL
	      WHEN duration LIKE '%mins' THEN TRIM('mins' FROM duration)
	      WHEN duration LIKE '%minute' THEN TRIM('minute' FROM duration)
	      WHEN duration LIKE '%minutes' THEN TRIM('minutes' FROM duration)
	      ELSE duration END
      AS INT) AS duration,
    CASE WHEN cancellation IN ('null', 'NaN', '') THEN NULL 
        ELSE cancellation
        END AS cancellation
INTO #runner_orders_temp
FROM runner_orders;
  
SELECT *
FROM #runner_orders_temp;

```
| order_id | runner_id | pickup_time             | distance | duration | cancellation             |
|----------|-----------|-------------------------|----------|----------|--------------------------|
| 1        | 1         | 2020-01-01 18:15:34.000 | 20       | 32       | NULL                     |
| 2        | 1         | 2020-01-01 19:10:54.000 | 20       | 27       | NULL                     |
| 3        | 1         | 2020-01-03 00:12:37.000 | 13.4     | 20       | NULL                     |
| 4        | 2         | 2020-01-04 13:53:03.000 | 23.4     | 40       | NULL                     |
| 5        | 3         | 2020-01-08 21:10:57.000 | 10       | 15       | NULL                     |
| 6        | 3         | NULL                    | NULL     | NULL     | Restaurant Cancellation  |
| 7        | 2         | 2020-01-08 21:30:45.000 | 25       | 25       | NULL                     |
| 8        | 2         | 2020-01-10 00:15:02.000 | 23.4     | 15       | NULL                     |
| 9        | 2         | NULL                    | NULL     | NULL     | Customer Cancellation    |
  
--- 
### Q1. How many pizzas were ordered?
```TSQL
SELECT COUNT(order_id) AS pizza_count
FROM #customer_orders_temp;
```
| pizza_count  |
|--------------|
| 14           |

---
### Q2. How many pizzas were ordered?
```TSQL
SELECT COUNT(DISTINCT order_id) AS order_count
FROM #customer_orders_temp;
```
| order_count  |
|--------------|
| 10           |

---
### Q3. How many successful orders were delivered by each runner?
```TSQL
SELECT 
  runner_id,
  COUNT(order_id) AS successful_orders
FROM #runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;
```
| runner_id | successful_orders  |
|-----------|--------------------|
| 1         | 4                  |
| 2         | 3                  |

---
### Q4. How many successful orders were delivered by each runner?
Approach 1: Use subquery.
```TSQL
SELECT 
  p.pizza_name,
  COUNT(*) AS deliver_count
FROM #customer_orders_temp c
JOIN pizza_names p 
  ON c.pizza_id = p.pizza_id
WHERE c.order_id IN (
    SELECT order_id 
    FROM #runner_orders_temp
    WHERE cancellation IS NULL)
GROUP BY p.pizza_name;
```

Approach 2: Use JOIN.
```TSQL
SELECT 
  p.pizza_name,
  COUNT(*) AS deliver_count
FROM #customer_orders_temp c
JOIN pizza_names p 
  ON c.pizza_id = p.pizza_id
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY p.pizza_name;
```

| pizza_name | deliver_count  |
|------------|----------------|
| Meatlovers | 9              |
| Vegetarian | 3              |

---
### Q5. How many Vegetarian and Meatlovers were ordered by each customer?
```TSQL
SELECT 
  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian
FROM #customer_orders_temp
GROUP BY customer_id;
```
| customer_id | Meatlovers | Vegetarian  |
|-------------|------------|-------------|
| 101         | 2          | 1           |
| 102         | 2          | 1           |
| 103         | 3          | 1           |
| 104         | 3          | 0           |
| 105         | 0          | 1           |

---
### Q6. What was the maximum number of pizzas delivered in a single order?
```TSQL
SELECT MAX(pizza_count) AS max_count
FROM (
  SELECT 
    c.order_id,
    COUNT(c.pizza_id) AS pizza_count
  FROM #customer_orders_temp c
  JOIN #runner_orders_temp r 
    ON c.order_id = r.order_id
  WHERE r.cancellation IS NULL
  GROUP BY c.order_id
) tmp;
```
| max_count  |
|------------|
| 3          |

---
### Q7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
```TSQL
SELECT 
  c.customer_id,
  SUM(CASE WHEN exclusions != '' OR extras != '' THEN 1 ELSE 0 END) AS has_change,
  SUM(CASE WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0 END) AS no_change
FROM #customer_orders_temp c
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;
```
| customer_id | has_change | no_change  |
|-------------|------------|------------|
| 101         | 0          | 2          |
| 102         | 0          | 3          |
| 103         | 3          | 0          |
| 104         | 2          | 1          |
| 105         | 1          | 0          |

---
### Q8. How many pizzas were delivered that had both exclusions and extras?
```TSQL
SELECT 
  SUM(CASE WHEN exclusions != '' AND extras != '' THEN 1 ELSE 0 END) AS change_both
FROM #customer_orders_temp c
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
WHERE r.cancellation IS NULL;
```
| change_both  |
|--------------|
| 1            |

---
### Q9. What was the total volume of pizzas ordered for each hour of the day?
```TSQL
SELECT 
  DATEPART(HOUR, order_time) AS hour_of_day,
  COUNT(order_id) AS pizza_volume
FROM #customer_orders_temp
GROUP BY DATEPART(HOUR, order_time)
ORDER BY hour_of_day;
```
| hour_of_day | pizza_volume  |
|-------------|---------------|
| 11          | 1             |
| 13          | 3             |
| 18          | 3             |
| 19          | 1             |
| 21          | 3             |
| 23          | 3             |

---
### Q10. What was the volume of orders for each day of the week?
```TSQL
SELECT 
  DATENAME(weekday, order_time) AS week_day,
  COUNT(order_id) AS order_volume
FROM #customer_orders_temp
GROUP BY DATENAME(weekday, order_time);
```
| week_day  | order_volume  |
|-----------|---------------|
| Friday    | 1             |
| Saturday  | 5             |
| Thursday  | 3             |
| Wednesday | 5             |

---
My solution for **[B. Runner and Customer Experience](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Solution/B.%20Runner%20and%20Customer%20Experience.md)**.
