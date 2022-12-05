# 🍊 Case Study #8 - Fresh Segments
## C. Segment Analysis
### 1. Using our filtered dataset by removing the interests with less than 6 months worth of data, which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? Only use the maximum `composition` value for each interest but you must keep the corresponding `month_year`.
To find top 10 interests that have the largest composition values in each `month_year`
```TSQL
WITH composition_ranks AS (
  SELECT 
    month_year,
    interest_id,
    composition,
    MAX(composition) OVER (PARTITION BY month_year) AS largest_composition,
    DENSE_RANK() OVER(PARTITION BY month_year ORDER BY composition DESC) AS top_rnk,
    DENSE_RANK() OVER(PARTITION BY month_year ORDER BY composition) AS bottom_rnk
  FROM #interest_metrics_edited -- filtered dataset in which interests with less than 6 months are removed
  WHERE month_year IS NOT NULL
)

--Top 10 interests that have the largest composition values in each month_year
SELECT 
  DISTINCT cr.interest_id,
  im.interest_name
FROM composition_ranks cr
JOIN interest_map im ON cr.interest_id = im.id
WHERE cr.top_rnk <= 10;
```


### 2. Which 5 interests had the lowest average `ranking` value?
### 3. Which 5 interests had the largest standard deviation in their `percentile_ranking` value?
### 4. For the 5 interests found in the previous question - what was minimum and maximum `percentile_ranking` values for each interest and its corresponding `year_month` value? Can you describe what is happening for these 5 interests?

### 5. How would you describe our customers in this segment based off their `composition` and ranking values? What sort of products or services should we show to these customers and what should we avoid?
