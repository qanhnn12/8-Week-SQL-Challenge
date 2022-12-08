# 🍕 Case Study #2 - Pizza Runner
## C. Ingredient Optimisation
### Data cleaning
**1. Create a new temporary table ```#toppingsBreak``` to separate ```toppings``` into multiple rows**
```TSQL
SELECT 
  pr.pizza_id,
  TRIM(value) AS topping_id,
  pt.topping_name
INTO #toppingsBreak
FROM pizza_recipes pr
  CROSS APPLY STRING_SPLIT(toppings, ',') AS t
JOIN pizza_toppings pt
  ON TRIM(t.value) = pt.topping_id;
  
SELECT *
FROM #toppingsBreak;
```
  
| pizza_id | topping_id | topping_name  |
|----------|------------|---------------|
| 1        | 1          | Bacon         |
| 1        | 2          | BBQ Sauce     |
| 1        | 3          | Beef          |
| 1        | 4          | Cheese        |
| 1        | 5          | Chicken       |
| 1        | 6          | Mushrooms     |
| 1        | 8          | Pepperoni     |
| 1        | 10         | Salami        |
| 2        | 4          | Cheese        |
| 2        | 6          | Mushrooms     |
| 2        | 7          | Onions        |
| 2        | 9          | Peppers       |
| 2        | 11         | Tomatoes      |
| 2        | 12         | Tomato Sauce  |
| 3        | 1          | Bacon         |
| 3        | 2          | BBQ Sauce     |
| 3        | 3          | Beef          |
| 3        | 4          | Cheese        |
| 3        | 5          | Chicken       |
| 3        | 6          | Mushrooms     |
| 3        | 7          | Onions        |
| 3        | 8          | Pepperoni     |
| 3        | 9          | Peppers       |
| 3        | 10         | Salami        |
| 3        | 11         | Tomatoes      |
| 3        | 12         | Tomato Sauce  |


**2. Add an identity column ```record_id``` to ```#customer_orders_temp``` to select each ordered pizza more easily**
```TSQL
ALTER TABLE #customer_orders_temp
ADD record_id INT IDENTITY(1,1);

SELECT *
FROM #customer_orders_temp;
```
  
| order_id | customer_id | pizza_id | exclusions | extras | order_time              | record_id  |
|----------|-------------|----------|------------|--------|-------------------------|------------|
| 1        | 101         | 1        |            |        | 2020-01-01 18:05:02.000 | 1          |
| 2        | 101         | 1        |            |        | 2020-01-01 19:00:52.000 | 2          |
| 3        | 102         | 1        |            |        | 2020-01-02 23:51:23.000 | 3          |
| 3        | 102         | 2        |            |        | 2020-01-02 23:51:23.000 | 4          |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 5          |
| 4        | 103         | 1        | 4          |        | 2020-01-04 13:23:46.000 | 6          |
| 4        | 103         | 2        | 4          |        | 2020-01-04 13:23:46.000 | 7          |
| 5        | 104         | 1        |            | 1      | 2020-01-08 21:00:29.000 | 8          |
| 6        | 101         | 2        |            |        | 2020-01-08 21:03:13.000 | 9          |
| 7        | 105         | 2        |            | 1      | 2020-01-08 21:20:29.000 | 10         |
| 8        | 102         | 1        |            |        | 2020-01-09 23:54:33.000 | 11         |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 11:22:59.000 | 12         |
| 10       | 104         | 1        |            |        | 2020-01-11 18:34:49.000 | 13         |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 18:34:49.000 | 14         |
  

**3. Create a new temporary table ```extrasBreak``` to separate ```extras``` into multiple rows**
```TSQL
SELECT 
  c.record_id,
  TRIM(e.value) AS extra_id
INTO #extrasBreak 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(extras, ',') AS e;

SELECT *
FROM #extrasBreak;
```
  
| record_id | extra_id  |
|-----------|-----------|
| 1         |           |
| 2         |           |
| 3         |           |
| 4         |           |
| 5         |           |
| 6         |           |
| 7         |           |
| 8         | 1         |
| 9         |           |
| 10        | 1         |
| 11        |           |
| 12        | 1         |
| 12        | 5         |
| 13        |           |
| 14        | 1         |
| 14        | 4         |

**4. Create a new temporary table ```exclusionsBreak``` to separate into ```exclusions``` into multiple rows**
```TSQL
SELECT 
  c.record_id,
  TRIM(e.value) AS exclusion_id
INTO #exclusionsBreak 
FROM #customer_orders_temp c
  CROSS APPLY STRING_SPLIT(exclusions, ',') AS e;

SELECT *
FROM #exclusionsBreak;
```
  
| record_id | exclusion_id  |
|-----------|---------------|
| 1         |               |
| 2         |               |
| 3         |               |
| 4         |               |
| 5         | 4             |
| 6         | 4             |
| 7         | 4             |
| 8         |               |
| 9         |               |
| 10        |               |
| 11        |               |
| 12        | 4             |
| 13        |               |
| 14        | 2             |
| 14        | 6             |

---
### Q1. What are the standard ingredients for each pizza?
```TSQL
SELECT 
  p.pizza_name,
  STRING_AGG(t.topping_name, ', ') AS ingredients
FROM #toppingsBreak t
JOIN pizza_names p 
  ON t.pizza_id = p.pizza_id
GROUP BY p.pizza_name;
```
  
| pizza_name | ingredients                                                            |
|------------|------------------------------------------------------------------------|
| Meatlovers | Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami  |
| Vegetarian | Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce             |

---
### Q2. What was the most commonly added extra?
```TSQL
SELECT 
  p.topping_name,
  COUNT(*) AS extra_count
FROM #extrasBreak e
JOIN pizza_toppings p
  ON e.extra_id = p.topping_id
GROUP BY p.topping_name
ORDER BY COUNT(*) DESC;
```
  
| topping_name | extra_count  |
|--------------|--------------|
| Bacon        | 4            |
| Cheese       | 1            |
| Chicken      | 1            |

The most commonly added extra was Bacon.

---
### Q3. What was the most common exclusion?
```TSQL
SELECT 
  p.topping_name,
  COUNT(*) AS exclusion_count
FROM #exclusionsBreak e
JOIN pizza_toppings p
  ON e.exclusion_id = p.topping_id
GROUP BY p.topping_name
ORDER BY COUNT(*) DESC;
```
  
| topping_name | exclusion_count  |
|--------------|------------------|
| Cheese       | 4                |
| Mushrooms    | 1                |
| BBQ Sauce    | 1                |

The most common exclusion was Cheese.

---
### Q4.Generate an order item for each record in the ```customers_orders``` table in the format of one of the following
* ```Meat Lovers```
* ```Meat Lovers - Exclude Beef```
* ```Meat Lovers - Extra Bacon```
* ```Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers```

To solve this question:
* Create 3 CTEs: ```extras_cte```, ```exclusions_cte```, and ```union_cte``` combining two tables
* Use the ```union_cte``` to LEFT JOIN with the ```customer_orders_temp``` and JOIN with the ```pizza_name```
* Use the ```CONCAT_WS``` with ```STRING_AGG``` to get the result

```TSQL
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
```

**Table ```cteExtra```**
| record_id | record_options        |
|-----------|-----------------------|
| 8         | Extra Bacon           |
| 10        | Extra Bacon           |
| 12        | Extra Bacon, Chicken  |
| 14        | Extra Bacon, Cheese   |

**Table ```cteExclusion```**
| record_id | record_options                 |
|-----------|--------------------------------|
| 5         | Exclusion Cheese               |
| 6         | Exclusion Cheese               |
| 7         | Exclusion Cheese               |
| 12        | Exclusion Cheese               |
| 14        | Exclusion BBQ Sauce, Mushrooms |

**Table ```cteUnion```**
| record_id | record_options                  |
|-----------|---------------------------------|
| 5         | Exclusion Cheese                |
| 6         | Exclusion Cheese                |
| 7         | Exclusion Cheese                |
| 8         | Extra Bacon                     |
| 10        | Extra Bacon                     |
| 12        | Exclusion Cheese                |
| 12        | Extra Bacon, Chicken            |
| 14        | Exclusion BBQ Sauce, Mushrooms  |
| 14        | Extra Bacon, Cheese             |

**Result**
  
| record_id | order_id | customer_id | pizza_id | order_time              | pizza_info                                                        |
|-----------|----------|-------------|----------|-------------------------|-------------------------------------------------------------------|
| 1         | 1        | 101         | 1        | 2020-01-01 18:05:02.000 | Meatlovers                                                        |
| 2         | 2        | 101         | 1        | 2020-01-01 19:00:52.000 | Meatlovers                                                        |
| 3         | 3        | 102         | 1        | 2020-01-02 23:51:23.000 | Meatlovers                                                        |
| 4         | 3        | 102         | 2        | 2020-01-02 23:51:23.000 | Vegetarian                                                        |
| 5         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers - Exclusion Cheese                                     |
| 6         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers - Exclusion Cheese                                     |
| 7         | 4        | 103         | 2        | 2020-01-04 13:23:46.000 | Vegetarian - Exclusion Cheese                                     |
| 8         | 5        | 104         | 1        | 2020-01-08 21:00:29.000 | Meatlovers - Extra Bacon                                          |
| 9         | 6        | 101         | 2        | 2020-01-08 21:03:13.000 | Vegetarian                                                        |
| 10        | 7        | 105         | 2        | 2020-01-08 21:20:29.000 | Vegetarian - Extra Bacon                                          |
| 11        | 8        | 102         | 1        | 2020-01-09 23:54:33.000 | Meatlovers                                                        |
| 12        | 9        | 103         | 1        | 2020-01-10 11:22:59.000 | Meatlovers - Exclusion Cheese - Extra Bacon, Chicken              |
| 13        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers                                                        |
| 14        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers - Exclusion BBQ Sauce, Mushrooms - Extra Bacon, Cheese |

---
### Q5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the ```customer_orders``` table and add a 2x in front of any relevant ingredients.
* For example: ```"Meat Lovers: 2xBacon, Beef, ... , Salami"```

To solve this question:
* Create a CTE in which each line displays an ingredient for an ordered pizza (add '2x' for extras and remove exclusions as well)
* Use ```CONCAT``` and ```STRING_AGG``` to get the result

```TSQL
WITH ingredients AS (
  SELECT 
    c.*,
    p.pizza_name,

    -- Add '2x' in front of topping_names if their topping_id appear in the #extrasBreak table
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
```
  
| record_id | order_id | customer_id | pizza_id | order_time              | ingredients_list                                                                     |
|-----------|----------|-------------|----------|-------------------------|--------------------------------------------------------------------------------------|
| 1         | 1        | 101         | 1        | 2020-01-01 18:05:02.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami, Cheese    |
| 2         | 2        | 101         | 1        | 2020-01-01 19:00:52.000 | Meatlovers: Cheese, Salami, Pepperoni, Mushrooms, Chicken, Beef, BBQ Sauce, Bacon    |
| 3         | 3        | 102         | 1        | 2020-01-02 23:51:23.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami, Cheese    |
| 4         | 3        | 102         | 2        | 2020-01-02 23:51:23.000 | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce, Cheese               |
| 5         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers: Salami, Pepperoni, Mushrooms, Chicken, Beef, BBQ Sauce, Bacon            |
| 6         | 4        | 103         | 1        | 2020-01-04 13:23:46.000 | Meatlovers: Bacon, BBQ Sauce, Beef, Chicken, Mushrooms, Pepperoni, Salami            |
| 7         | 4        | 103         | 2        | 2020-01-04 13:23:46.000 | Vegetarian: Mushrooms, Tomato Sauce, Tomatoes, Peppers, Onions                       |
| 8         | 5        | 104         | 1        | 2020-01-08 21:00:29.000 | Meatlovers: Cheese, Salami, Pepperoni, Mushrooms, Chicken, Beef, BBQ Sauce, 2xBacon  |
| 9         | 6        | 101         | 2        | 2020-01-08 21:03:13.000 | Vegetarian: Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce, Cheese               |
| 10        | 7        | 105         | 2        | 2020-01-08 21:20:29.000 | Vegetarian: Cheese, Tomato Sauce, Tomatoes, Peppers, Onions, Mushrooms               |
| 11        | 8        | 102         | 1        | 2020-01-09 23:54:33.000 | Meatlovers: Cheese, Salami, Mushrooms, Pepperoni, Bacon, BBQ Sauce, Beef, Chicken    |
| 12        | 9        | 103         | 1        | 2020-01-10 11:22:59.000 | Meatlovers: 2xChicken, Beef, BBQ Sauce, 2xBacon, Pepperoni, Mushrooms, Salami        |
| 13        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers: Salami, Cheese, Mushrooms, Pepperoni, Bacon, BBQ Sauce, Beef, Chicken    |
| 14        | 10       | 104         | 1        | 2020-01-11 18:34:49.000 | Meatlovers: Chicken, Beef, 2xBacon, Pepperoni, 2xCheese, Salami                      |

---
### Q6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?
To solve this question:
* Create a CTE to record the number of times each ingredient was used
  * if extra ingredient, add 2 
  * if excluded ingredient, add 0
  * no extras or no exclusions, add 1
```TSQL
WITH frequentIngredients AS (
  SELECT 
    c.record_id,
    t.topping_name,
    CASE
      -- if extra ingredient, add 2
      WHEN t.topping_id IN (
          SELECT extra_id 
          FROM #extrasBreak e
          WHERE e.record_id = c.record_id) 
      THEN 2
      -- if excluded ingredient, add 0
      WHEN t.topping_id IN (
          SELECT exclusion_id 
          FROM #exclusionsBreak e 
          WHERE c.record_id = e.record_id)
      THEN 0
      -- no extras, no exclusions, add 1
      ELSE 1
    END AS times_used
  FROM #customer_orders_temp c
  JOIN #toppingsBreak t
    ON t.pizza_id = c.pizza_id
  JOIN pizza_names p
    ON p.pizza_id = c.pizza_id
)

SELECT 
  topping_name,
  SUM(times_used) AS times_used 
FROM frequentIngredients
GROUP BY topping_name
ORDER BY times_used DESC;
```
  
| topping_name | times_used  |
|--------------|-------------|
| Bacon        | 13          |
| Mushrooms    | 13          |
| Cheese       | 11          |
| Chicken      | 11          |
| Pepperoni    | 10          |
| Salami       | 10          |
| Beef         | 10          |
| BBQ Sauce    | 9           |
| Peppers      | 4           |
| Onions       | 4           |
| Tomato Sauce | 4           |
| Tomatoes     | 4           |
  
---
My solution for **[D. Pricing and Ratings](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%232%20-%20Pizza%20Runner/Solution/D.%20Pricing%20and%20Ratings.md)**.
