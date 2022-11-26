# 🛒 Case Study #5 - Data Mart
## B. Data Exploration

### 1. What day of the week is used for each week_date value?
```TSQL
SELECT DISTINCT(DATENAME(dw, week_date)) AS week_date_value
FROM clean_weekly_sales;
```
| week_date_value  |
|------------------|
| Monday           |

---
### 2. What range of week numbers are missing from the dataset?
* Create a recursive CTE ```allWeeks``` to generate 52 weeks in a year
* ```LEFT JOIN``` from ```allWeeks``` to ```clean_weekly_sales```. ```NULL``` rows in ```week_number``` are missing weeks
```TSQL
WITH allWeeks AS (
  SELECT 1 AS pos
  UNION ALL
  SELECT pos+1 FROM allWeeks
  WHERE pos+1 <= 52)

SELECT 
  DISTINCT a.pos, 
  c.week_number
FROM allWeeks a
LEFT JOIN clean_weekly_sales c
  ON a.pos = c.week_number
WHERE c.week_number IS NULL
ORDER BY a.pos;
```
28 rows in total. The first 12 rows:
| pos | week_number  |
|-----|--------------|
| 1   | NULL         |
| 2   | NULL         |
| 3   | NULL         |
| 4   | NULL         |
| 5   | NULL         |
| 6   | NULL         |
| 7   | NULL         |
| 8   | NULL         |
| 9   | NULL         |
| 10  | NULL         |
| 11  | NULL         |
| 12  | NULL         |

Week 1-12 and week 37-52 are missing from the dataset.

---
### 3. How many total transactions were there for each year in the dataset?
```TSQL
SELECT 
  calendar_year,
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY calendar_year
ORDER BY calendar_year;
```
| calendar_year | total_transactions  |
|---------------|---------------------|
| 2018          | 346406460           |
| 2019          | 365639285           |
| 2020          | 375813651           |

---
### 4. What is the total sales for each region for each month?
```TSQL
SELECT 
  region, 
  month_number, 
  SUM(sales) AS total_sales
FROM clean_weekly_sales
GROUP BY region, month_number
ORDER BY region, month_number;
```
49 rows in total. The first 15 rows:
| region | month_number | total_sales  |
|--------|--------------|--------------|
| AFRICA | 3            | 567767480    |
| AFRICA | 4            | 1911783504   |
| AFRICA | 5            | 1647244738   |
| AFRICA | 6            | 1767559760   |
| AFRICA | 7            | 1960219710   |
| AFRICA | 8            | 1809596890   |
| AFRICA | 9            | 276320987    |
| ASIA   | 3            | 529770793    |
| ASIA   | 4            | 1804628707   |
| ASIA   | 5            | 1526285399   |
| ASIA   | 6            | 1619482889   |
| ASIA   | 7            | 1768844756   |
| ASIA   | 8            | 1663320609   |
| ASIA   | 9            | 252836807    |

---
### 5. What is the total count of transactions for each platform?
```TSQL
SELECT 
  platform,
  SUM(transactions) AS total_transactions
FROM clean_weekly_sales
GROUP BY platform;
```
| platform | total_transactions  |
|----------|---------------------|
| Retail   | 1081934227          |
| Shopify  | 5925169             |

---
### 6. What is the percentage of sales for Retail vs Shopify for each month?
```TSQL
WITH sales_cte AS (
  SELECT 
    calendar_year, 
    month_number, 
    platform, 
    SUM(sales) AS monthly_sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, month_number, platform
)

SELECT 
  calendar_year, 
  month_number, 
  CAST(100.0 * MAX(CASE WHEN platform = 'Retail' THEN monthly_sales END)
	/ SUM(monthly_sales) AS decimal(5, 2)) AS pct_retail,
  CAST(100.0 * MAX(CASE WHEN platform = 'Shopify' THEN monthly_sales END)
	/ SUM(monthly_sales) AS decimal(5, 2)) AS pct_shopify
FROM sales_cte
GROUP BY calendar_year,  month_number
ORDER BY calendar_year, month_number;
```
| calendar_year | month_number | pct_retail | pct_shopify  |
|---------------|--------------|------------|--------------|
| 2018          | 3            | 97.92      | 2.08         |
| 2018          | 4            | 97.93      | 2.07         |
| 2018          | 5            | 97.73      | 2.27         |
| 2018          | 6            | 97.76      | 2.24         |
| 2018          | 7            | 97.75      | 2.25         |
| 2018          | 8            | 97.71      | 2.29         |
| 2018          | 9            | 97.68      | 2.32         |
| 2019          | 3            | 97.71      | 2.29         |
| 2019          | 4            | 97.80      | 2.20         |
| 2019          | 5            | 97.52      | 2.48         |
| 2019          | 6            | 97.42      | 2.58         |
| 2019          | 7            | 97.35      | 2.65         |
| 2019          | 8            | 97.21      | 2.79         |
| 2019          | 9            | 97.09      | 2.91         |
| 2020          | 3            | 97.30      | 2.70         |
| 2020          | 4            | 96.96      | 3.04         |
| 2020          | 5            | 96.71      | 3.29         |
| 2020          | 6            | 96.80      | 3.20         |
| 2020          | 7            | 96.67      | 3.33         |
| 2020          | 8            | 96.51      | 3.49         |

---
### 7. What is the percentage of sales by demographic for each year in the dataset?
```TSQL
WITH sales_by_demographic AS (
  SELECT 
    calendar_year,
    demographic,
    SUM(sales) AS sales
  FROM clean_weekly_sales
  GROUP BY calendar_year, demographic)

SELECT 
  calendar_year,
  CAST(100.0 * MAX(CASE WHEN demographic = 'Families' THEN sales END)
	/ SUM(sales) AS decimal(5, 2)) AS pct_families,
  CAST(100.0 * MAX(CASE WHEN demographic = 'Couples' THEN sales END) 
	/ SUM(sales) AS decimal(5, 2)) AS pct_couples,
  CAST(100.0 * MAX(CASE WHEN demographic = 'unknown' THEN sales END)
	/ SUM(sales) AS decimal(5, 2)) AS pct_unknown
FROM sales_by_demographic
GROUP BY calendar_year;
```
| calendar_year | pct_families | pct_couples | pct_unknown  |
|---------------|--------------|-------------|--------------|
| 2018          | 31.99        | 26.38       | 41.63        |
| 2019          | 32.47        | 27.28       | 40.25        |
| 2020          | 32.73        | 28.72       | 38.55        |

---
### 8. Which age_band and demographic values contribute the most to Retail sales?
```TSQL
DECLARE @retailSales bigint = (
  SELECT SUM(sales)
  FROM clean_weekly_sales
  WHERE platform = 'Retail')
				
SELECT 
  age_band,
  demographic,
  SUM(sales) AS sales,
  CAST(100.0 * SUM(sales)/@retailSales AS decimal(5, 2)) AS contribution
FROM clean_weekly_sales
WHERE platform = 'Retail'
GROUP BY age_band, demographic
ORDER BY contribution DESC;
```
| age_band     | demographic | sales       | contribution  |
|--------------|-------------|-------------|---------------|
| unknown      | unknown     | 16067285533 | 40.52         |
| Retirees     | Families    | 6634686916  | 16.73         |
| Retirees     | Couples     | 6370580014  | 16.07         |
| Middle Aged  | Families    | 4354091554  | 10.98         |
| Young Adults | Couples     | 2602922797  | 6.56          |
| Middle Aged  | Couples     | 1854160330  | 4.68          |
| Young Adults | Families    | 1770889293  | 4.47          |

The highest retail sales are contributed by *unknown* ```age_band``` and ```demographic``` at 40.52% followed by *retired families* at 16.73% and *retired couples* at 16.07%.

---
### 9. Can we use the avg_transaction column to find the average transaction size for each year for Retail vs Shopify? If not - how would you calculate it instead?
```TSQL
SELECT 
  calendar_year,
  platform,
  ROUND(AVG(avg_transaction), 0) AS avg_transaction_row,
  SUM(sales) / SUM(transactions) AS avg_transaction_group
FROM clean_weekly_sales
GROUP BY calendar_year, platform
ORDER BY calendar_year, platform;
```
| calendar_year | platform | avg_transaction_row | avg_transaction_group  |
|---------------|----------|---------------------|------------------------|
| 2018          | Retail   | 43                  | 36                     |
| 2018          | Shopify  | 188                 | 192                    |
| 2019          | Retail   | 42                  | 36                     |
| 2019          | Shopify  | 178                 | 183                    |
| 2020          | Retail   | 41                  | 36                     |
| 2020          | Shopify  | 175                 | 179                    |

What's the difference between ```avg_transaction_row``` and ```avg_transaction_group```?
* ```avg_transaction_row``` is the average transaction of each individual row in the dataset 
* ```avg_transaction_group``` is the average transaction of each ```platform``` in each ```calendar_year```

The average transaction size for each year by platform is actually ```avg_transaction_group```.

---
My solution for **[C. Before & After Analysis](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution/C.%20Before%20%26%20After%20Analysis.md)**.
