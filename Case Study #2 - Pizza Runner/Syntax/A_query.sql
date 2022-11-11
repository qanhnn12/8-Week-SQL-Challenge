--------------------
--A. Pizza Metrics--
--------------------

-- 1. How many pizzas were ordered?

SELECT COUNT(order_id) AS pizza_count
FROM #customer_orders_temp;


-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS order_count
FROM #customer_orders_temp;


-- 3. How many successful orders were delivered by each runner?

SELECT 
  runner_id,
  COUNT(order_id) AS successful_orders
FROM #runner_orders_temp
WHERE cancellation IS NULL
GROUP BY runner_id;


-- 4. How many of each type of pizza was delivered?

-- Approach 1:
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

-- Aproach 2:

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


-- 5. How many Vegetarian and Meatlovers were ordered by each customer?

SELECT 
  customer_id,
  SUM(CASE WHEN pizza_id = 1 THEN 1 ELSE 0 END) AS Meatlovers,
  SUM(CASE WHEN pizza_id = 2 THEN 1 ELSE 0 END) AS Vegetarian
FROM #customer_orders_temp
GROUP BY customer_id;


-- 6. What was the maximum number of pizzas delivered in a single order?

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


-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

SELECT 
  c.customer_id,
  SUM(CASE WHEN exclusions != '' OR extras != '' THEN 1 ELSE 0 END) AS has_change,
  SUM(CASE WHEN exclusions = '' AND extras = '' THEN 1 ELSE 0 END) AS no_change
FROM #customer_orders_temp c
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
WHERE r.cancellation IS NULL
GROUP BY c.customer_id;


-- 8. How many pizzas were delivered that had both exclusions and extras?

SELECT 
  SUM(CASE WHEN exclusions != '' AND extras != '' THEN 1 ELSE 0 END) AS change_both
FROM #customer_orders_temp c
JOIN #runner_orders_temp r 
  ON c.order_id = r.order_id
WHERE r.cancellation IS NULL;


-- 9.What was the total volume of pizzas ordered for each hour of the day?

SELECT 
  DATEPART(HOUR, order_time) AS hour_of_day,
  COUNT(order_id) AS pizza_volume
FROM #customer_orders_temp
GROUP BY DATEPART(HOUR, order_time)
ORDER BY hour_of_day;


-- 10. What was the volume of orders for each day of the week?

SELECT 
  DATENAME(weekday, order_time) AS week_day,
  COUNT(order_id) AS order_volume
FROM #customer_orders_temp
GROUP BY DATENAME(weekday, order_time);
