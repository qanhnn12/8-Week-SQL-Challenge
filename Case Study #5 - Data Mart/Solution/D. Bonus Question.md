# 🛒 Case Study #5 - Data Mart
## D. Bonus Question
Which areas of the business have the highest negative impact in sales metrics performance in 2020 for the 12 week before and after period?
  * ```region```
  * ```platform```
  * ```age_band```
  * ```demographic```
  * ```customer_type```
  
Do you have any further recommendations for Danny’s team at Data Mart or any interesting insights based off this analysis?

## Solution
Using the technique in part C, we first find the ```week_number``` of ```2020-06-15```.
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

### 1. Sales changes by ```regions```
```TSQL
WITH regionChanges AS (
  SELECT
    region,
    SUM(CASE WHEN week_number BETWEEN @weekNum-12 AND @weekNum-1 THEN sales END) AS before_sales,
    SUM(CASE WHEN week_number BETWEEN @weekNum AND @weekNum+11 THEN sales END) AS after_sales
  FROM clean_weekly_sales
  GROUP BY region
)
SELECT *,
  CAST(100.0 * (after_sales-before_sales)/before_sales AS decimal(5,2)) AS pct_change
FROM regionChanges;
```
| region        | before_sales | after_sales | pct_change  |
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
* The highest negative impact was in Asia with -1.33%. The sustainable packages didn't work well here. 
Danny team should consider reducing the number of products wrapped by this kind of packages.
* Only Europe saw a significant increase of 4.96%, followed by Africa with 1.1%. These are potential areas that Danny team should invest more.
