# 🛒 Case Study #5 - Data Mart
## A. Data Cleansing Steps
In a single query, perform the following operations and generate a new table in the ```data_mart``` schema named ```clean_weekly_sales```:
  * Convert the ```week_date``` to a ```DATE``` format
  * Add a ```week_number``` as the second column for each ```week_date``` value, for example any value from the 1st of January to 7th of January will be 1, 8th to 14th will be 2 etc
  * Add a ```month_number``` with the calendar month for each ```week_date``` value as the 3rd column
  * Add a ```calendar_year``` column as the 4th column containing either 2018, 2019 or 2020 values
  * Add a new column called ```age_band``` after the original ```segment``` column using the following mapping on the number inside the ```segment``` value

| egment | age_band     |
|--------|--------------|
| 1      | Young Adults |
| 2      | Middle Aged  |
| 3 or 4 | Retirees     |
  
  * Add a new ```demographic``` column using the following mapping for the first letter in the ```segment``` values
  
| segment | demographic |
|---------|-------------|
| C       | Couples     |
| F       | Families    |
  
  * Ensure all ```null``` string values with an ```"unknown"``` string value in the original ```segment``` column as well as the new ```age_band``` and ```demographic``` columns
  * Generate a new ```avg_transaction``` column as the sales value divided by ```transactions``` rounded to 2 decimal places for each record

---
## Solution

| Columns          | Actions to take                                                                                                                                          |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| week_date        | Convert to ```DATE``` using ```CONVERT```                                                                                                                |
| week_number*     | Extract number of week using ```DATEPART```                                                                                                              |
| month_number*    | Extract month using ```DATEPART```                                                                                                                       |
| calendar_year*   | Extract year using ```DATEPART```                                                                                                                        |
| region           | No changes                                                                                                                                               |
| platform         | No changes                                                                                                                                               |
| segment          | No changes                                                                                                                                               |
| customer_type    | No changes                                                                                                                                               |
| age_band*        | Use ```CASE WHEN``` to categorize ```segment```: '1' = ```Young Adults```, '2' = ```Middle Aged```, '3' or '4' = ```Retirees``` and null = ```unknown``` |
| demographic*     | Use ```CASE WHEN``` to categorize ```segment```: 'C' = ```Couples```, 'F' = ```Families``` and null = ```unknown```                                      |
| transactions     | No changes                                                                                                                                               |
| sales            | ```CAST``` to ```bigint``` for further aggregations                                                                                                         |
| avg_transaction* | Divide ```sales``` by ```transactions``` and round up to 2 decimal places                     

```TSQL
SELECT
  CONVERT(date, week_date, 3) AS week_date,
  DATEPART(week, CONVERT(date, week_date, 3)) AS week_number,
  DATEPART(month, CONVERT(date, week_date, 3)) AS month_number,
  DATEPART(year, CONVERT(date, week_date, 3)) AS calendar_year,
  region,
  platform,
  segment,
  customer_type,
  CASE 
    WHEN RIGHT(segment, 1) = '1' THEN 'Young Adults'
    WHEN RIGHT(segment, 1) = '2' THEN 'Middle Aged'
    WHEN RIGHT(segment, 1) IN ('3', '4') THEN 'Retirees'
    ELSE 'unknown' END AS age_band,
  CASE 
    WHEN LEFT(segment, 1) = 'C' THEN 'Couples'
    WHEN LEFT(segment, 1) = 'F' THEN 'Families'
    ELSE 'unknown' END AS demographic,
  transactions,
  CAST(sales AS bigint) AS sales,
  ROUND(CAST(sales AS FLOAT)/transactions, 2) AS avg_transaction
INTO clean_weekly_sales
FROM weekly_sales;
```
The first 10 rows:
| week_date  | week_number | month_number | calendar_year | region | platform | segment | customer_type | age_band     | demographic | transactions | sales    | avg_transaction  |
|------------|-------------|--------------|---------------|--------|----------|---------|---------------|--------------|-------------|--------------|----------|------------------|
| 2020-08-31 | 36          | 8            | 2020          | ASIA   | Retail   | C3      | New           | Retirees     | Couples     | 120631       | 3656163  | 30.31            |
| 2020-08-31 | 36          | 8            | 2020          | ASIA   | Retail   | F1      | New           | Young Adults | Families    | 31574        | 996575   | 31.56            |
| 2020-08-31 | 36          | 8            | 2020          | USA    | Retail   | null    | Guest         | unknown      | unknown     | 529151       | 16509610 | 31.2             |
| 2020-08-31 | 36          | 8            | 2020          | EUROPE | Retail   | C1      | New           | Young Adults | Couples     | 4517         | 141942   | 31.42            |
| 2020-08-31 | 36          | 8            | 2020          | AFRICA | Retail   | C2      | New           | Middle Aged  | Couples     | 58046        | 1758388  | 30.29            |
| 2020-08-31 | 36          | 8            | 2020          | CANADA | Shopify  | F2      | Existing      | Middle Aged  | Families    | 1336         | 243878   | 182.54           |
| 2020-08-31 | 36          | 8            | 2020          | AFRICA | Shopify  | F3      | Existing      | Retirees     | Families    | 2514         | 519502   | 206.64           |
| 2020-08-31 | 36          | 8            | 2020          | ASIA   | Shopify  | F1      | Existing      | Young Adults | Families    | 2158         | 371417   | 172.11           |
| 2020-08-31 | 36          | 8            | 2020          | AFRICA | Shopify  | F2      | New           | Middle Aged  | Families    | 318          | 49557    | 155.84           |
| 2020-08-31 | 36          | 8            | 2020          | AFRICA | Retail   | C3      | New           | Retirees     | Couples     | 111032       | 3888162  | 35.02            |

---
My solution for **[B. Data Exploration](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%235%20-%20Data%20Mart/Solution/B.%20Data%20Exploration.md)**.
