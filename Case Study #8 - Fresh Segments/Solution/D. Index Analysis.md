# 🍊 Case Study #8 - Fresh Segments
## D. Index Analysis
The `index_value` is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the `composition` column by the `index_value` column rounded to 2 decimal places.

### 1. What is the top 10 interests by the average composition for each month?
```TSQL
SELECT 
  TOP 10 metrics.interest_id,
  map.interest_name,
  ROUND(metrics.composition / metrics.index_value, 2) AS avg_composition
FROM interest_metrics metrics
JOIN interest_map map ON metrics.interest_id = map.id
ORDER BY avg_composition DESC;
```
| interest_id | interest_name               | avg_composition  |
|-------------|-----------------------------|------------------|
| 21057       | Work Comes First Travelers  | 9.14             |
| 21057       | Work Comes First Travelers  | 8.31             |
| 21057       | Work Comes First Travelers  | 8.28             |
| 21057       | Work Comes First Travelers  | 8.26             |
| 21057       | Work Comes First Travelers  | 7.66             |
| 21057       | Work Comes First Travelers  | 7.66             |
| 21245       | Readers of Honduran Content | 7.6              |
| 6324        | Las Vegas Trip Planners     | 7.36             |
| 7541        | Alabama Trip Planners       | 7.27             |
| 6324        | Las Vegas Trip Planners     | 7.21             |

---
2. For all of these top 10 interests - which interest appears the most often?
```TSQL
WITH top_10_interests AS (
  SELECT 
    TOP 10 metrics.interest_id,
    map.interest_name,
    ROUND(metrics.composition / metrics.index_value, 2) AS avg_composition
FROM interest_metrics metrics
JOIN interest_map map 
  ON metrics.interest_id = map.id
ORDER BY avg_composition DESC
)

SELECT
  TOP 1 interest_id,
  interest_name,
  COUNT(interest_id) AS freq
FROM top_10_interests
GROUP BY interest_id, interest_name
ORDER BY freq DESC;
```
| interest_id | interest_name         | freq  |
|-------------|-----------------------|-------|
| 7541        | Work Comes First Travelers | 6     |

---
3. What is the average of the average composition for the top 10 interests for each month?
```TSQL
WITH top_10_interests AS (
  SELECT 
    TOP 10 metrics.interest_id,
    map.interest_name,
    metrics.composition / metrics.index_value AS avg_composition
FROM interest_metrics metrics
JOIN interest_map map ON metrics.interest_id = map.id
ORDER BY avg_composition DESC
)

SELECT ROUND(AVG(avg_composition), 2) AS avg_of_avg_composition
FROM top_10_interests;
```
| avg_of_avg_composition  |
|-------------------------|
| 7.87                    |

---
4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and include the previous top ranking interests in the same output shown below.
```TSQL
WITH avg_compositions AS (
  SELECT 
    month_year,
    interest_id,
    ROUND(composition / index_value, 2) AS avg_comp,
    ROUND(MAX(composition / index_value) OVER(PARTITION BY month_year), 2) AS max_avg_comp
  FROM interest_metrics
  WHERE month_year IS NOT NULL
),
max_avg_compositions AS (
  SELECT *
  FROM avg_compositions
  WHERE avg_comp = max_avg_comp
),
moving_avg_compositions AS (
  SELECT 
    mac.month_year,
    im.interest_name,
    mac.max_avg_comp AS max_index_composition,
    ROUND(AVG(mac.max_avg_comp) 
	  OVER(ORDER BY mac.month_year 
	       ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) AS '3_month_moving_avg',
    LAG(im.interest_name) OVER (ORDER BY mac.month_year) + ': ' +
	CAST(LAG(mac.max_avg_comp) OVER (ORDER BY mac.month_year) AS VARCHAR(4)) AS '1_month_ago',
    LAG(im.interest_name, 2) OVER (ORDER BY mac.month_year) + ': ' +
	CAST(LAG(mac.max_avg_comp, 2) OVER (ORDER BY mac.month_year) AS VARCHAR(4)) AS '2_month_ago'
  FROM max_avg_compositions mac 
  JOIN interest_map im 
    ON mac.interest_id = im.id
)

SELECT *
FROM moving_avg_compositions
WHERE month_year BETWEEN '2018-09-01' AND '2019-08-01';
```
| month_year | interest_name                 | max_index_composition | 3_month_moving_avg | 1_month_ago                       | 2_months_ago                       |
|------------|-------------------------------|-----------------------|--------------------|-----------------------------------|------------------------------------|
| 2018-09-01 | Work Comes First Travelers    | 8.26                  | 7.61               | Las Vegas Trip Planners: 7.21     | Las Vegas Trip Planners: 7.36      |
| 2018-10-01 | Work Comes First Travelers    | 9.14                  | 8.20               | Work Comes First Travelers: 8.26  | Las Vegas Trip Planners: 7.21      |
| 2018-11-01 | Work Comes First Travelers    | 8.28                  | 8.56               | Work Comes First Travelers: 9.14  | Work Comes First Travelers: 8.26   |
| 2018-12-01 | Work Comes First Travelers    | 8.31                  | 8.58               | Work Comes First Travelers: 8.28  | Work Comes First Travelers: 9.14   |
| 2019-01-01 | Work Comes First Travelers    | 7.66                  | 8.08               | Work Comes First Travelers: 8.31  | Work Comes First Travelers: 8.28   |
| 2019-02-01 | Work Comes First Travelers    | 7.66                  | 7.88               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 8.31   |
| 2019-03-01 | Alabama Trip Planners         | 6.54                  | 7.29               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 7.66   |
| 2019-04-01 | Solar Energy Researchers      | 6.28                  | 6.83               | Alabama Trip Planners: 6.54       | Work Comes First Travelers: 7.66   |
| 2019-05-01 | Readers of Honduran Content   | 4.41                  | 5.74               | Solar Energy Researchers: 6.28    | Alabama Trip Planners: 6.54        |
| 2019-06-01 | Las Vegas Trip Planners       | 2.77                  | 4.49               | Readers of Honduran Content: 4.41 | Solar Energy Researchers: 6.28     |
| 2019-07-01 | Las Vegas Trip Planners       | 2.82                  | 3.33               | Las Vegas Trip Planners: 2.77     | Readers of Honduran Content: 4.41  |
| 2019-08-01 | Cosmetics and Beauty Shoppers | 2.73                  | 2.77               | Las Vegas Trip Planners: 2.82     | Las Vegas Trip Planners: 2.77      |

---
5. Provide a possible reason why the max average composition might change from month to month? Could it signal something is not quite right with the overall business model for Fresh Segments? 
