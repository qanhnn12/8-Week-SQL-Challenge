# 🛒 Case Study #5 - Data Mart
## D. Bonus Question
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
  * ```region```
  * ```platform```
  * ```age_band```
  * ```demographic```
  * ```customer_type```
  
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

---
## Solution
First, using the technique in part C to find the ```week_number``` of ```2020-06-15```.
```TSQL
--Find the week_number of '2020-06-15' (@weekNum=25)
DECLARE @weekNum int = (
  SELECT DISTINCT week_number
  FROM clean_weekly_sales
  WHERE week_date = '2020-06-15'
  AND calendar_year =2020)
```
Then, depending on the area we want to analyze, change the column name in the ```SELECT``` and  ```GROUP BY```. 

Remember to include the ```DECLARE @weekNum``` in the beginning of each part below.

---
### 1. Sales changes by ```regions```
```TSQL
WITH regionChanges AS (
  SELECT
    region,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY region
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM regionChanges;
```
| region        | before_changes | after_changes | pct_change  |
|---------------|--------------|-------------|-------------|
| OCEANIA       | 6698586333   | 6640244793  | -0.87       |
| EUROPE        | 328141414    | 344420043   | 4.96        |
| SOUTH AMERICA | 611056923    | 608981392   | -0.34       |
| AFRICA        | 4942976910   | 4997516159  | 1.10        |
| CANADA        | 1244662705   | 1234025206  | -0.85       |
| ASIA          | 4613242689   | 4551927271  | -1.33       |
| USA           | 1967554887   | 1960297502  | -0.37       |

**Insights and recommendations:** 
* Overall, the sales of most countries decreased after changing packages. 
* The highest negative impact was in ```ASIA``` with -1.33%. 
Danny should reduce the number of products with sustainable packages here.
* Only ```EUROPE``` saw a significant increase of 4.96% followed by ```AFRICA``` with 1.1%. These are areas that Danny should invest more.

---
### 2. Sales changes by ```platform```
```TSQL
WITH platformChanges AS (
  SELECT
    platform,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY platform
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM platformChanges;
```
| platform | before_changes | after_changes | pct_change  |
|----------|--------------|-------------|-------------|
| Retail   | 19886040272  | 19768576165 | -0.59       |
| Shopify  | 520181589    | 568836201   | 9.35        |

**Insights and recommendations:** 
* ```Shopify``` stores saw an increase in sales of 9.35% while the```Retail``` stores slightly decreased by 0.59%. 
* Danny should put more products with sustanable packages in ```Shopify``` stores.

---
### 3. Sales changes by ```age_band```
```TSQL
WITH ageBandChanges AS (
  SELECT
    age_band,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY age_band
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM ageBandChanges;
```
| age_band     | before_changes | after_changes | pct_change  |
|--------------|--------------|-------------|-------------|
| unknown      | 8191628826   | 8146983408  | -0.55       |
| Young Adults | 2290835366   | 2285973456  | -0.21       |
| Middle Aged  | 3276892347   | 3269748622  | -0.22       |
| Retirees     | 6646865322   | 6634706880  | -0.18       |

**Insights and recommendations:** 
* Overall, the sales slightly decreased in all bands.
* ```Middle Aged``` and ```Young Adults``` had more negative impact on sales than the ```Retirees```. Those bands should not be targeted in new packages.

---
### 4. Sales changes by ```demographic```
```TSQL
WITH demographicChanges AS (
  SELECT
    demographic,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY demographic
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM demographicChanges;
```
| demographic | before_changes | after_changes | pct_change  |
|-------------|----------------|---------------|-------------|
| unknown     | 8191628826     | 8146983408    | -0.55       |
| Families    | 6605726904     | 6598087538    | -0.12       |
| Couples     | 5608866131     | 5592341420    | -0.29       |

**Insights and recommendations:** 
* Overall, the sales slightly decreased in all demographic groups.
* ```Couples``` had more negative impact on sales than ```Families```. Those groups should not be targeted in new packages.

---
### 5. Sales changes by ```customer_type```
```TSQL
WITH customerTypeChanges AS (
  SELECT
    customer_type,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_changes,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_changes
  FROM clean_weekly_sales
  GROUP BY customer_type
)
SELECT *,
  CAST(100.0 * (after_changes-before_changes)/before_changes AS decimal(5,2)) AS pct_change
FROM customerTypeChanges;
```
| customer_type | before_changes | after_changes | pct_change  |
|---------------|----------------|---------------|-------------|
| Guest         | 7630353739     | 7595150744    | -0.46       |
| Existing      | 10168877642    | 10117367239   | -0.51       |
| New           | 2606990480     | 2624894383    | 0.69        |

**Insights and recommendations:** 
* The sales for `Guests` and `Existing` customers decreased, but increased for `New` customers.
* Further analysis should be taken to understand why `New` customers were interested in sustainable packages.
