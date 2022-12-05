# 🍊 Case Study #8 - Fresh Segments
## B. Interest Analysis
### 1. Which interests have been present in all `month_year` dates in our dataset?
```TSQL
-- Find how many unique month_year dates in our dataset
DECLARE @unique_month_year_cnt INT = (
  SELECT COUNT(DISTINCT month_year)
  FROM interest_metrics)

--Filter all interest_id that have the count = @unique_month_year_cnt
SELECT 
  interest_id,
  COUNT(month_year) AS cnt
FROM interest_metrics
GROUP BY interest_id
HAVING COUNT(month_year) = @unique_month_year_cnt;
```
480 rows in total. The first 10 rows:

| interest_id | cnt  |
|-------------|------|
| 5970        | 14   |
| 10838       | 14   |
| 111         | 14   |
| 33191       | 14   |
| 10978       | 14   |
| 10988       | 14   |
| 17540       | 14   |
| 6391        | 14   |
| 18202       | 14   |
| 19250       | 14   |

480 interests out of 1202 interests are present in all `month_year`.

---
### 2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value passes the 90% cumulative percentage value?
```TSQL
WITH interest_months AS (
  SELECT
    interest_id,
    COUNT(DISTINCT month_year) AS total_months
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
),
interest_count AS (
  SELECT
    total_months,
    COUNT(interest_id) AS interests
  FROM interest_months
  GROUP BY total_months
)

SELECT *,
  CAST(100.0 * SUM(interests) OVER(ORDER BY total_months DESC)
	/ SUM(interests) OVER() AS decimal(10, 2)) AS cumulative_pct
FROM interest_count;
```
| total_months | interests | cumulative_pct  |
|--------------|-----|-----------------|
| 14           | 480 | 39.93           |
| 13           | 82  | 46.76           |
| 12           | 65  | 52.16           |
| 11           | 94  | 59.98           |
| 10           | 86  | 67.14           |
| 9            | 95  | 75.04           |
| 8            | 67  | 80.62           |
| 7            | 90  | 88.10           |
| 6            | 33  | 90.85           |
| 5            | 38  | 94.01           |
| 4            | 32  | 96.67           |
| 3            | 15  | 97.92           |
| 2            | 12  | 98.92           |
| 1            | 13  | 100.00          |

Interests with total months of 6 and above received a 90% and above cumulative percentage. 
Interests below 6 months should be investigated to improve their clicks and customer interactions.

---
### 3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points would we be removing?
```TSQL
WITH interest_months AS (
  SELECT
    interest_id,
    COUNT(DISTINCT month_year) AS total_months
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
)

SELECT 
  COUNT(interest_id) AS interests,
  COUNT(DISTINCT interest_id) AS unique_interests
FROM interest_metrics
WHERE interest_id IN (
  SELECT interest_id 
  FROM interest_months
  WHERE total_months < 6);
```
| interests | unique_interests  |
|-----------|-------------------|
| 400       | 110               |

If we remove all 110 `interest_id` values in table `interest_metrics` that are below 6 months, 400 data points would be removing.

---
### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.


### 5. After removing these interests - how many unique interests are there for each month?
