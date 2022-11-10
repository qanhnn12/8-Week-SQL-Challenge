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
  c.*,
  TRIM(e.value) AS extra_id
INTO #extrasBreak 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(extras, ',') AS e;
  
-- 4. Create a new temporary table to separate [exclusions] into multiple rows: #exclusionsBreak
 
SELECT 
  c.*,
  TRIM(e.value) AS exclusion_id
INTO #exclusionsBreak 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(exclusions, ',') AS e;
