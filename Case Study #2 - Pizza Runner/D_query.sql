--------------------------
--D. Pricing and Ratings--
--------------------------

--1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - 
--how much money has Pizza Runner made so far if there are no delivery fees?

SELECT
  SUM(CASE WHEN p.pizza_name = 'Meatlovers' THEN 12
        ELSE 10 END) AS money_earned
FROM #customer_orders_temp c
JOIN pizza_names p
  ON c.pizza_id = p.pizza_id
JOIN #runner_orders_temp r
  ON c.order_id = r.order_id
WHERE r.cancellation IS NULL;


-- 2.What if there was an additional $1 charge for any pizza extras?
-- Add cheese is $1 extra

DECLARE @basecost INT
SET @basecost = 138 	-- @basecost = result of the previous question

SELECT 
  @basecost + SUM(CASE WHEN p.topping_name = 'Cheese' THEN 2
		  ELSE 1 END) updated_money
FROM #extrasBreak e
JOIN pizza_toppings p
  ON e.extra_id = p.topping_id;


--3. --The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, 
--how would you design an additional table for this new dataset - generate a schema for this new table and 
--insert your own data for ratings for each successful customer order between 1 to 5.

DROP TABLE IF EXISTS ratings
CREATE TABLE ratings (
  order_id INT,
  rating INT);
INSERT INTO ratings (order_id, rating)
VALUES 
  (1,3),
  (2,5),
  (3,3),
  (4,1),
  (5,5),
  (7,3),
  (8,4),
  (10,3);
  
  
-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
-- customer_id, order_id, runner_id, rating, order_time, pickup_time, Time between order and pickup, Delivery duration, Average speed, Total number of pizzas

SELECT 
  c.customer_id,
  c.order_id,
  r.runner_id,
  c.order_time,
  r.pickup_time,
  DATEDIFF(MINUTE, c.order_time, r.pickup_time) AS mins_difference,
  r.duration,
  ROUND(AVG(r.distance/r.duration*60), 1) AS avg_speed,
  COUNT(c.order_id) AS pizza_count
FROM #customer_orders_temp c
JOIN #runner_orders_temp r 
  ON r.order_id = c.order_id
GROUP BY 
  c.customer_id,
  c.order_id,
  r.runner_id,
  c.order_time,
  r.pickup_time, 
  r.duration;


--5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras 
--and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

DECLARE @basecost INT
SET @basecost = 138

SELECT 
  @basecost AS revenue,
  SUM(distance)*0.3 AS runner_pay,
  @basecost - SUM(distance)*0.3 AS money_left
from #runner_orders_temp;
