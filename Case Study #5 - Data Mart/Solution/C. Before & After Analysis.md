# 🛒 Case Study #5 - Data Mart
## C. Before & After Analysis

This technique is usually used when we inspect an important event and want to inspect the impact before and after a certain point in time. 
Taking the week_date value of 2020-06-15 as the baseline week where the Data Mart sustainable packaging changes came into effect. 
We would include all week_date values for 2020-06-15 as the start of the period after the change and the previous week_date values would be before.

Using this analysis approach - answer the following questions:

### 1. What is the total sales for the 4 weeks before and after 2020-06-15? What is the growth or reduction rate in actual values and percentage of sales?
```TSQL
--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15')

--Find the total sales of 4 weeks before and after @weekNum
WITH salesChanges AS (
  SELECT
    SUM(CASE WHEN week_number BETWEEN @weekNum-4 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+3 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  WHERE calendar_year = 2020
)

SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges;
```
| before_changes | after_changes | pct_change  |
|----------------|---------------|-------------|
| 2345878357     | 2318994169    | -1.15       |

---
### 2. What about the entire 12 weeks before and after?
```TSQL
--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15')

--Find the total sales of 12 weeks before and after @weekNum
WITH salesChanges AS (
  SELECT
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  WHERE calendar_year = 2020
)

SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM salesChanges;
```
| before_changes | after_changes | pct_change  |
|----------------|---------------|-------------|
| 7126273147     | 6973947753    | -2.14       |

---
### 3. How do the sale metrics for these 2 periods before and after compare with the previous years in 2018 and 2019?
Part 1: How do the sales metrics for 4 weeks before and after compared with the previous years in 2018 and 2019?
```TSQL
--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15')

--Find the total sales of 4 weeks before and after @weekNum
WITH salesChanges AS (
  SELECT
    calendar_year,
    SUM(CASE WHEN week_number BETWEEN @weekNum-3 AND @weekNum-1 THEN sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+3 THEN sales END) AS after_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year
)

SELECT *,
  CAST(100.0 * (after_sales-before_sales)/before_sales AS decimal(5,2)) AS pct_change
FROM salesChanges
ORDER BY calendar_year;
```
| calendar_year | before_sales | after_sales | pct_change  |
|---------------|--------------|-------------|-------------|
| 2018          | 1602763447   | 2129242914  | 32.85       |
| 2019          | 1688891616   | 2252326390  | 33.36       |
| 2020          | 1760870267   | 2318994169  | 31.70       |

Part 2: How do the sales metrics for 12 weeks before and after compared with the previous years in 2018 and 2019?
```TSQL
--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15')

--Find the total sales of 12 weeks before and after @weekNum
WITH salesChanges AS (
  SELECT
    calendar_year,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year
)

SELECT *,
  CAST(100.0 * (after_sales-before_sales)/before_sales AS decimal(5,2)) AS pct_change
FROM salesChanges
ORDER BY calendar_year;
```
| calendar_year | before_sales | after_sales | pct_change  |
|---------------|--------------|-------------|-------------|
| 2018          | 6396562317   | 6500818510  | 1.63        |
| 2019          | 6883386397   | 6862646103  | -0.30       |
| 2020          | 7126273147   | 6973947753  | -2.14       |

---
My solution for **[D. Bonus Question](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution/D.%20Bonus%20Question.md)**.
