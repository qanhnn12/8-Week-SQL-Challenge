# 🍊 Case Study #8 - Fresh Segments
## C. Segment Analysis
### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? Only use the maximum `composition` value for each interest but you must keep the corresponding `month_year`.

* Create a CTE `max_composition` to find the maximum `composition` value for each interest. To keep the corresponding `month_year`, use the window funtion `MAX() OVER()` instead of the aggregate function `MAX()` with `GROUP BY`. 
* Create a CTE `composition_rank` to rank all maximum compositions for each `interest_id` in any `month_year` from the CTE `max_composition`
* Filter top 10 or bottom 10 interests using `WHERE`, then JOIN `max_composition` with `interest_map` to take the `interest_name` for each corresponding `interest_id`

```TSQL
WITH max_composition AS (
  SELECT 
    month_year,
    interest_id,
    MAX(composition) OVER(PARTITION BY interest_id) AS largest_composition
  FROM #interest_metrics_edited -- filtered dataset in which interests with less than 6 months are removed
  WHERE month_year IS NOT NULL
),
composition_rank AS (
  SELECT *,
    DENSE_RANK() OVER(ORDER BY largest_composition DESC) AS rnk
  FROM max_composition
)

--Top 10 interests that have the largest composition values
SELECT 
  cr.interest_id,
  im.interest_name,
  cr.rnk
FROM composition_rank cr
JOIN interest_map im ON cr.interest_id = im.id
WHERE cr.rnk <= 10
ORDER BY cr.rnk;
```
Top 10 interests which have the largest composition values in any `month_year`:

| interest_id | interest_name                     | rnk      |
|-------------|-----------------------------------|----------|
| 21057       | Work Comes First Travelers        | 1        |
| 6284        | Gym Equipment Owners              | 2        |
| 39          | Furniture Shoppers                | 3        |
| 77          | Luxury Retail Shoppers            | 4        |
| 12133       | Luxury Boutique Hotel Researchers | 5        |
| 5969        | Luxury Bedding Shoppers           | 6        |
| 171         | Shoe Shoppers                     | 7        |
| 4898        | Cosmetics and Beauty Shoppers     | 8        |
| 6286        | Luxury Hotel Guests               | 9        |
| 4           | Luxury Retail Researchers         | 10       |

Using the CTE above, replace the filter for top 10 interests by this:
```TSQL
--Bottom 10 interests that have the largest composition values
SELECT 
  DISTINCT TOP 10 cr.interest_id,
  im.interest_name,
  cr.rnk
FROM composition_rank cr
JOIN interest_map im ON cr.interest_id = im.id
ORDER BY cr.rnk DESC;
```
Bottom 10 interests which have the largest composition values in any `month_year`:

| interest_id | interest_name                     | rnk  |
|-------------|-----------------------------------|------|
| 33958       | Astrology Enthusiasts             | 555  |
| 37412       | Medieval History Enthusiasts      | 554  |
| 19599       | Dodge Vehicle Shoppers            | 553  |
| 19635       | Xbox Enthusiasts                  | 552  |
| 19591       | Camaro Enthusiasts                | 551  |
| 37421       | Budget Mobile Phone Researchers   | 550  |
| 42011       | League of Legends Video Game Fans | 550  |
| 22408       | Super Mario Bros Fans             | 549  |
| 34085       | Oakland Raiders Fans              | 548  |
| 36138       | Haunted House Researchers         | 547  |

---
### 2. Which 5 interests had the lowest average `ranking` value?
```TSQL

SELECT 
  TOP 5 metrics.interest_id,
  map.interest_name,
  CAST(AVG(1.0*metrics.ranking) AS decimal(10,2)) AS avg_ranking
FROM #interest_metrics_edited metrics
JOIN interest_map map
  ON metrics.interest_id = map.id
GROUP BY metrics.interest_id, map.interest_name
ORDER BY avg_ranking;
```
| interest_id | interest_name                  | avg_ranking  |
|-------------|--------------------------------|--------------|
| 41548       | Winter Apparel Shoppers        | 1.00         |
| 42203       | Fitness Activity Tracker Users | 4.11         |
| 115         | Mens Shoe Shoppers             | 5.93         |
| 171         | Shoe Shoppers                  | 9.36         |
| 4           | Luxury Retail Researchers      | 11.86        |

---
### 3. Which 5 interests had the largest standard deviation in their `percentile_ranking` value?
```TSQL
SELECT 
  DISTINCT TOP 5 metrics.interest_id,
  map.interest_name,
  ROUND(STDEV(metrics.percentile_ranking) 
    OVER(PARTITION BY metrics.interest_id), 2) AS std_percentile_ranking
FROM #interest_metrics_edited metrics
JOIN interest_map map
ON metrics.interest_id = map.id
ORDER BY std_percentile_ranking DESC;
```
| interest_id | interest_name                          | std_percentile_ranking  |
|-------------|----------------------------------------|-------------------------|
| 23          | Techies                                | 30.18                   |
| 20764       | Entertainment Industry Decision Makers | 28.97                   |
| 38992       | Oregon Trip Planners                   | 28.32                   |
| 43546       | Personalized Gift Shoppers             | 26.24                   |
| 10839       | Tampa and St Petersburg Trip Planners  | 25.61                   |

---
### 4. For the 5 interests found in the previous question - what was minimum and maximum `percentile_ranking` values for each interest and its corresponding `year_month` value? Can you describe what is happening for these 5 interests?
```TSQL
--Based on the query for the previous question
WITH largest_std_interests AS (
  SELECT 
    DISTINCT TOP 5 metrics.interest_id,
    map.interest_name,
    map.interest_summary,
    ROUND(STDEV(metrics.percentile_ranking) 
      OVER(PARTITION BY metrics.interest_id), 2) AS std_percentile_ranking
  FROM #interest_metrics_edited metrics
  JOIN interest_map map
  ON metrics.interest_id = map.id
  ORDER BY std_percentile_ranking DESC
),
max_min_percentiles AS (
  SELECT 
    lsi.interest_id,
    lsi.interest_name,
    lsi. interest_summary,
    ime.month_year,
    ime.percentile_ranking,
    MAX(ime.percentile_ranking) OVER(PARTITION BY lsi.interest_id) AS max_pct_rnk,
    MIN(ime.percentile_ranking) OVER(PARTITION BY lsi.interest_id) AS min_pct_rnk
  FROM largest_std_interests lsi
  JOIN #interest_metrics_edited ime
  ON lsi.interest_id = ime.interest_id
)

SELECT 
  interest_id,
  interest_name,
  interest_summary,
  MAX(CASE WHEN percentile_ranking = max_pct_rnk THEN month_year END) AS max_pct_month_year,
  MAX(CASE WHEN percentile_ranking = max_pct_rnk THEN percentile_ranking END) AS max_pct_rnk,
  MIN(CASE WHEN percentile_ranking = min_pct_rnk THEN month_year END) AS min_pct_month_year,
  MIN(CASE WHEN percentile_ranking = min_pct_rnk THEN percentile_ranking END) AS min_pct_rnk
FROM max_min_percentiles
GROUP BY interest_id, interest_name, interest_summary;
```
| interest_id | interest_name                          | interest_summary                                                                                                                                                        | max_pct_month_year | max_pct_rnk | min_pct_month_year | min_pct_rnk  |
|-------------|----------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|-------------|--------------------|--------------|
| 10839       | Tampa and St Petersburg Trip Planners  | People researching attractions and accommodations in Tampa and St Petersburg. These consumers are more likely to spend money on flights, hotels, and local attractions. | 2018-07-01         | 75.03       | 2019-03-01         | 4.84         |
| 20764       | Entertainment Industry Decision Makers | Professionals reading industry news and researching trends in the entertainment industry.                                                                               | 2018-07-01         | 86.15       | 2019-08-01         | 11.23        |
| 23          | Techies                                | Readers of tech news and gadget reviews.                                                                                                                                | 2018-07-01         | 86.69       | 2019-08-01         | 7.92         |
| 38992       | Oregon Trip Planners                   | People researching attractions and accommodations in Oregon. These consumers are more likely to spend money on travel and local attractions.                            | 2018-11-01         | 82.44       | 2019-07-01         | 2.2          |
| 43546       | Personalized Gift Shoppers             | Consumers shopping for gifts that can be personalized.                                                                                                                  | 2019-03-01         | 73.15       | 2019-06-01         | 5.7          |


We can see that the the range between the maximum and minimum `percentile_ranking` of 5 interests in the table above is very large. 
Noticed that the month of the maximum and minumum values are different. This implies that these interests may have the seasonal demand or there are other underlying reasons related to products, services or prices that we should investigate further.

For example, customers prefer interest `10839`, which is `Tampa and St Petersburg Trip Planners` on July 2018, but not prefer that on March 2019. 
This might be because the trip on July was cheaper or the weather on those places was more suitable for travelling.

---
### 5. How would you describe our customers in this segment based off their composition and ranking values? What sort of products or services should we show to these customers and what should we avoid?

Customers in this segment love travelling and personalized gifts but they just want to spend once. That's why we can see that in one month of 2018, the `percentile_ranking` was very high; but in another month of 2019, that value was quite low. These customers are also interested in new trends in tech and entertainment industries. 

Therefore, we should only recommend only one-time accomodation services and personalized gift to them. We can ask them to sign-up to newsletters for tech products or new trends in entertainment industry as well.

---
My solution for **[D. Index Analysis](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/D.%20Index%20Analysis.md)**.
