------------------------
----A. Pizza Metrics---- 
------------------------

-- 1. How many pizzas were ordered?

SELECT COUNT(order_id) AS pizza_count
FROM #customer_orders_temp;


-- 2. How many unique customer orders were made?

SELECT COUNT(DISTINCT order_id) AS order_count
FROM #customer_orders_temp;


-- 3. How many successful orders were delivered by each runner?

SELECT 
  runner_id,
  COUNT(order_id) AS sucessful_orders
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
  DATEPART(WEEKDAY, order_time) AS week_day,
  COUNT(order_id) AS pizza_volume
FROM #customer_orders_temp
GROUP BY DATEPART(WEEKDAY, order_time);


-------------------------------------
--B. Runner and Customer Experience--
-------------------------------------

--1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

SELECT 
  DATEPART(week, registration_date) AS week_period,
  COUNT(*) AS runner_count
FROM runners
GROUP BY DATEPART(week, registration_date);


-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

WITH runners_pickup AS (
  SELECT
    r.runner_id,
    c.order_id, 
    c.order_time, 
    r.pickup_time, 
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS pickup_minutes
  FROM #customer_orders_temp AS c
  JOIN #runner_orders_temp AS r
    ON c.order_id = r.order_id
  WHERE r.pickup_time IS NOT NULL   --exclude cancelled orders
  GROUP BY r.runner_id, c.order_id, c.order_time, r.pickup_time
)

SELECT 
  runner_id,
  AVG(pickup_minutes) AS average_time
FROM runners_pickup
GROUP BY runner_id;


-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

WITH pizzaPrepration AS (
  SELECT
    c.order_id, 
    c.order_time, 
    r.pickup_time,
    DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS prep_time,
    COUNT(c.pizza_id) AS pizza_count
  FROM #customer_orders_temp AS c
  JOIN #runner_orders_temp AS r
    ON c.order_id = r.order_id
  WHERE r.pickup_time IS NOT NULL
  GROUP BY c.order_id, c.order_time, r.pickup_time, 
           DATEDIFF(MINUTE, c.order_time, r.pickup_time)
)

SELECT 
  pizza_count,
  AVG(prep_time) AS avg_prep_time
FROM pizzaPrepration
GROUP BY pizza_count;


-- 4. What was the average distance travelled for each customer?

SELECT
  c.customer_id,
  ROUND(AVG(r.distance), 1) AS average_distance
FROM #customer_orders_temp AS c
JOIN #runner_orders_temp AS r
  ON c.order_id = r.order_id
GROUP BY c.customer_id;


-- 5. What was the difference between the longest and shortest delivery times for all orders?

SELECT MAX(duration) - MIN(duration) AS difference
FROM #runner_orders_temp;


-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

SELECT 
  r.runner_id,
  c.order_id,
  r.distance,
  r.duration AS duration_min,
  COUNT(c.order_id) AS pizza_count, 
  ROUND(AVG(r.distance/r.duration*60), 1) AS avg_speed
FROM #runner_orders_temp r
JOIN #customer_orders_temp c
  ON r.order_id = c.order_id
WHERE r.distance IS NOT NULL
GROUP BY r.runner_id, c.order_id, r.distance, r.duration;


-- 7. What is the successful delivery percentage for each runner?

SELECT 
  runner_id,
  COUNT(distance) AS delivered,
  COUNT(order_id) AS total,
  100 * COUNT(distance) / COUNT(order_id) AS successful_pct
FROM #runner_orders_temp
GROUP BY runner_id;
