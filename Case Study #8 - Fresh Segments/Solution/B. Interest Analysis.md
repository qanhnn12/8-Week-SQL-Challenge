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

If we removed all 110 `interest_id` values that are below 6 months in the table `interest_metrics`, 400 data points would be removing.

---
### 4. Does this decision make sense to remove these data points from a business perspective? Use an example where there are all 14 months present to a removed interest example for your arguments - think about what it means to have less months present from a segment perspective.
From the business perspective, we shouldn't remove these data points even if those customers didn't contribute much to the business outcome.
When checking the timeline of our data set, I realized that this business had just started 1 year and 1 month. 
The timeline was too short to decide whether those customers will go back or not.
```TSQL
SELECT 
  MIN(month_year) AS first_date,
  MAX(month_year) AS last_date
FROM interest_metrics;
```
| first_date | last_date  |
|------------|------------|
| 2018-07-01 | 2019-08-01 | 

```TSQL
--When total_months = 14
SELECT 
  month_year,
  COUNT(DISTINCT interest_id) interest_count,
  MIN(ranking) AS highest_rank,
  MAX(composition) AS composition_max,
  MAX(index_value) AS index_max
FROM interest_metrics metrics
WHERE interest_id IN (
  SELECT interest_id
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) = 14)
GROUP BY month_year
ORDER BY month_year, highest_rank;
```
| month_year | interest_count | highest_rank | composition_max | index_max  |
|------------|----------------|--------------|-----------------|------------|
| 2018-07-01 | 480            | 1            | 18.82           | 6.19       |
| 2018-08-01 | 480            | 1            | 13.9            | 2.84       |
| 2018-09-01 | 480            | 1            | 14.29           | 2.84       |
| 2018-10-01 | 480            | 1            | 15.15           | 3.37       |
| 2018-11-01 | 480            | 1            | 14.92           | 3.48       |
| 2018-12-01 | 480            | 3            | 15.05           | 3.13       |
| 2019-01-01 | 480            | 2            | 14.92           | 2.95       |
| 2019-02-01 | 480            | 2            | 14.39           | 3          |
| 2019-03-01 | 480            | 2            | 12.64           | 2.81       |
| 2019-04-01 | 480            | 2            | 11.01           | 2.85       |
| 2019-05-01 | 480            | 2            | 7.53            | 3.13       |
| 2019-06-01 | 480            | 2            | 6.94            | 4.01       |
| 2019-07-01 | 480            | 2            | 7.19            | 3.95       |
| 2019-08-01 | 480            | 2            | 7.1             | 3.99       |

```TSQL
--When total_months = 1
SELECT 
  month_year,
  COUNT(DISTINCT interest_id) interest_count,
  MIN(ranking) AS highest_rank,
  MAX(composition) AS composition_max,
  MAX(index_value) AS index_max
FROM interest_metrics metrics
WHERE interest_id IN (
  SELECT interest_id
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) = 1)
GROUP BY month_year
ORDER BY month_year, highest_rank;
```
| month_year | interest_count | highest_rank | composition_max | index_max  |
|------------|----------------|--------------|-----------------|------------|
| 2018-07-01 | 6              | 283          | 5.21            | 2.11       |
| 2018-08-01 | 1              | 657          | 1.81            | 0.95       |
| 2018-09-01 | 1              | 771          | 1.59            | 0.63       |
| 2019-02-01 | 2              | 1001         | 2.11            | 0.93       |
| 2019-03-01 | 1              | 1135         | 1.57            | 0.51       |
| 2019-08-01 | 2              | 437          | 2.6             | 1.83       |

Let's say we want to take the average, maximum or minimum of `ranking`, `composition` or `index_values` for each interest in every month, interests that don't have 14 months would create uneven distribution of observations since there are months we don't have data. Therefore, we should archive these data points in the segment analysis to have an accurate view on the overall interest of customers.

---
### 5. After removing these interests - how many unique interests are there for each month?
As mentioned before, instead of deleting interests below 6 months, I create a temporary table `interest_metrics_edited` excluded them for the segment analysis.

```TSQL
--Create a temporary table [interest_metrics_edited]
SELECT *
INTO #interest_metrics_edited
FROM interest_metrics
WHERE interest_id NOT IN (
  SELECT interest_id
  FROM interest_metrics
  WHERE interest_id IS NOT NULL
  GROUP BY interest_id
  HAVING COUNT(DISTINCT month_year) < 6);

--Check the count of interests_id
SELECT 
  COUNT(interest_id) AS all_interests,
  COUNT(DISTINCT interest_id) AS unique_interests
FROM #interest_metrics_edited
```
| all_interests | unique_interests  |
|---------------|-------------------|
| 12680         | 1092              |

Noticed that the number of unique interests has dropped from 1202 (*[Question 4 part A](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/A.%20Data%20Exploration%20and%20Cleansing.md)*) to 1092, which is 110 interests corresponding to 400 data points (Question 3 this part).

To find the number of unique interests for each month after removing step above:
```TSQL
SELECT 
  month_year,
  COUNT(DISTINCT interest_id) AS unique_interests
FROM #interest_metrics_edited
WHERE month_year IS NOT NULL
GROUP BY month_year
ORDER BY month_year;
```
| month_year | unique_interests  |
|------------|-------------------|
| 2018-07-01 | 709               |
| 2018-08-01 | 752               |
| 2018-09-01 | 774               |
| 2018-10-01 | 853               |
| 2018-11-01 | 925               |
| 2018-12-01 | 986               |
| 2019-01-01 | 966               |
| 2019-02-01 | 1072              |
| 2019-03-01 | 1078              |
| 2019-04-01 | 1035              |
| 2019-05-01 | 827               |
| 2019-06-01 | 804               |
| 2019-07-01 | 836               |
| 2019-08-01 | 1062              |

---
My solution for **[C. Segment Analysis](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/C.%20Segment%20Analysis.md)**.
