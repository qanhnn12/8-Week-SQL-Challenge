---------------------------------------------
--C. Data Cleaning: Ingredient Optimisation--
---------------------------------------------

-- 1. Create a new temporary table to separate [toppings] into multiple rows: #toppingsBreak

SELECT 
  pr.pizza_id,
  TRIM(value) AS topping_id,
  pt.topping_name
INTO #toppingsBreak
FROM pizza_recipes pr
  CROSS APPLY STRING_SPLIT(toppings, ',') AS t
JOIN pizza_toppings pt
  ON TRIM(t.value) = pt.topping_id;
  
  
-- 2. Add a new column [record_id] to select each ordered pizza more easily

ALTER TABLE #customer_orders_temp
ADD record_id INT IDENTITY(1,1);


-- 3. Create a new temporary table to separate [extras] into multiple rows: #extrasBreak
SELECT 
  c.record_id,
  TRIM(e.value) AS extra_id
INTO #extrasBreak 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(extras, ',') AS e;
  
-- 4. Create a new temporary table to separate [exclusions] into multiple rows: #exclusionsBreak
 
SELECT 
  c.record_id,
  TRIM(e.value) AS exclusion_id
INTO #exclusionsBreak 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(exclusions, ',') AS e;


--5. Generate an alphabetically ordered comma separated ingredient list for each pizza order 
--from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"


-- Create a CTE: Each line displays an ingredient for an ordered pizza (add 2x for extras and remove exclusions as well)
WITH ingredients AS (
  SELECT 
    c.*,
    p.pizza_name,

    -- Add a 2x in front of topping_names if their topping_id appear in the #extrasBreak table
    CASE WHEN t.topping_id IN (
        SELECT extra_id 
        FROM #extrasBreak e 
        WHERE e.record_id = c.record_id)
      THEN '2x' + t.topping_name
      ELSE t.topping_name
    END AS topping

  FROM #customer_orders_temp c
  JOIN #toppingsBreak t
    ON t.pizza_id = c.pizza_id
  JOIN pizza_names p
    ON p.pizza_id = c.pizza_id

  -- Exclude toppings if their topping_id appear in the #exclusionBreak table
  WHERE t.topping_id NOT IN (
    SELECT exclusion_id 
    FROM #exclusionsBreak e 
    WHERE c.record_id = e.record_id)
)

SELECT 
  record_id,
  order_id,
  customer_id,
  pizza_id,
  order_time,
  CONCAT(pizza_name + ': ', STRING_AGG(topping, ', ')) AS ingredients_list
FROM ingredients
GROUP BY 
  record_id, 
  record_id,
  order_id,
  customer_id,
  pizza_id,
  order_time,
  pizza_name
ORDER BY record_id;
