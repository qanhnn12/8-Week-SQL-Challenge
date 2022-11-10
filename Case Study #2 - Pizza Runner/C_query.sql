-- 1. What are the standard ingredients for each pizza?

SELECT 
	p.pizza_name,
	STRING_AGG(t.topping_name, ', ') AS ingredients
FROM #toppingsBreak t
JOIN pizza_names p 
	ON t.pizza_id = p.pizza_id
GROUP BY p.pizza_name


--2. What was the most commonly added extra?

SELECT 
	p.topping_name,
	COUNT(*) AS extra_count
FROM #extrasBreak e
JOIN pizza_toppings p
	ON e.extra_id = p.topping_id
GROUP BY p.topping_name
ORDER BY COUNT(*) DESC;


--3. What was the most common exclusion?

SELECT 
	p.topping_name,
	COUNT(*) AS exclusion_count
FROM #exclusionsBreak e
JOIN pizza_toppings p
	ON e.exclusion_id = p.topping_id
GROUP BY p.topping_name
ORDER BY COUNT(*) DESC;


--4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

WITH cteExtras AS (
	SELECT 
		e.record_id,
		'Extra ' + STRING_AGG(t.topping_name, ', ') AS record_options
	FROM #extrasBreak e
	JOIN pizza_toppings t
	ON e.extra_id = t.topping_id
	GROUP BY e.record_id
), 
cteExclusions AS (
	SELECT 
		e.record_id,
		'Exclusion ' + STRING_AGG(t.topping_name, ', ') AS record_options
	FROM #exclusionsBreak e
	JOIN pizza_toppings t
	ON e.exclusion_id = t.topping_id
	GROUP BY e.record_id
), 
cteUnion AS (
	SELECT * FROM cteExtras
	UNION
	SELECT * FROM cteExclusions
)

SELECT 
	c.record_id,
	c.order_id,
	c.customer_id,
	c.pizza_id,
	c.order_time,
	CONCAT_WS(' - ', p.pizza_name, STRING_AGG(u.record_options, ' - ')) AS pizza_info
FROM #customer_orders_temp c
LEFT JOIN cteUnion u
	ON c.record_id = u.record_id
JOIN pizza_names p
	ON c.pizza_id = p.pizza_id
GROUP BY
	c.record_id, 
	c.order_id,
	c.customer_id,
	c.pizza_id,
	c.order_time,
	p.pizza_name
ORDER BY record_id;
