# 🐟 Case Study #6 - Clique Bait
## C. Campaigns Analysis
Generate a table that has 1 single row for every unique visit_id record and has the following columns:
  * `user_id`
  * `visit_id`
  * `visit_start_time`: the earliest event_time for each visit
  * `page_views`: count of page views for each visit
  * `art_adds`: count of product cart add events for each visit
  * `purchase`: 1/0 flag if a purchase event exists for each visit
  * `campaign_name`: map the visit to a campaign if the visit_start_time falls between the start_date and end_date
  * `impression`: count of ad impressions for each visit
  * `click`: count of ad clicks for each visit
  * (Optional column) `cart_products`: a comma separated text value with 
  products added to the cart sorted by the order they were added to the cart (hint: use the `sequence_number`)
  
  ### Solution

* `INNER JOIN` from table `events` to `users`
* `INNER JOIN` from table `events` to `event_identifier`
* `LEFT JOIN` from table `events` to `campaign_identifier` to display`campaign_name` in all rows regardless of `start_time` and `end_time`.
* To generate earliest `visit_start_time` for each unique `visit_id`, use `MIN()` to find the 1st `visit_time`.
* Use `SUM()` and `CASE` to calculate `page_views`, `cart_adds`, `purchase`, ad `impression` and ad `click` for each `visit_id`.
* To get a comma separated list of products added to cart sorted by `sequence_number`:
  * Use a `CASE` to select `Add to cart` events.
  * Use `STRING_AGG()` to separate products by comma and ` WITHIN GROUP` to order `sequence_number`.
* Store the result in a temporary table `campaign_summary` for further analysis.
  
```TSQL
SELECT
    u.user_id,
    e.visit_id,
    MIN(event_time) AS visit_start_time,
    SUM(CASE WHEN ei.event_name = 'Page View' THEN 1 ELSE 0 END) AS page_views,
    SUM(CASE WHEN ei.event_name = 'Add to Cart' THEN 1 ELSE 0 END) AS cart_adds,
    SUM(CASE WHEN ei.event_name = 'Purchase' THEN 1 ELSE 0 END) AS purchase,
    c.campaign_name,
    SUM(CASE WHEN ei.event_name = 'Ad Impression' THEN 1 ELSE 0 END) AS impression,
    SUM(CASE WHEN ei.event_name = 'Ad Click' THEN 1 ELSE 0 END) AS click,
    STRING_AGG(CASE WHEN ei.event_name = 'Add to Cart' THEN ph.page_name END, ', ') 
      WITHIN GROUP (ORDER BY e.sequence_number) AS cart_products
INTO #campaign_summary
FROM events e
JOIN users u 
    ON e.cookie_id = u.cookie_id
JOIN event_identifier ei 
    ON e.event_type = ei.event_type
JOIN page_hierarchy ph 
    ON e.page_id = ph.page_id
LEFT JOIN campaign_identifier c 
    ON e.event_time BETWEEN c.start_date AND c.end_date
GROUP BY u.user_id, e.visit_id, c.campaign_name;
```
3,654 rows in total. The first 5 rows:
| user_id | visit_id | visit_start_time            | page_views | cart_adds | purchase | campaign_name                     | impression | click | cart_products                                                                |
|---------|----------|-----------------------------|------------|-----------|----------|-----------------------------------|------------|-------|------------------------------------------------------------------------------|
| 1       | 02a5d5   | 2020-02-26 16:57:26.2608710 | 4          | 0         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     | NULL                                                                         |
| 1       | 0826dc   | 2020-02-26 05:58:37.9186180 | 1          | 0         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     | NULL                                                                         |
| 1       | 0fc437   | 2020-02-04 17:49:49.6029760 | 10         | 6         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Tuna, Russian Caviar, Black Truffle, Abalone, Crab, Oyster                   |
| 1       | 30b94d   | 2020-03-15 13:12:54.0239360 | 9          | 7         | 1        | Half Off - Treat Your Shellf(ish) | 1          | 1     | Salmon, Kingfish, Tuna, Russian Caviar, Abalone, Lobster, Crab               |
| 1       | 41355d   | 2020-03-25 00:11:17.8606550 | 6          | 1         | 0        | Half Off - Treat Your Shellf(ish) | 0          | 0     | Lobster                                                                      |

---
Some ideas to investigate further include:
- Identifying users who have received impressions during each campaign period 
and comparing each metric with other users who did not have an impression event
- Does clicking on an impression lead to higher purchase rates?
- What is the uplift in purchase rate when comparing users who click on a campaign impression versus 
users who do not receive an impression? What if we compare them with users who have just an impression but do not click?
- What metrics can you use to quantify the success or failure of each campaign compared to each other?

### Solution
Since the number of users who *received impressions* is higher than those who *did not receive impressions* and those who *received impressions but not clicked to ads*, the total views, total cart adds and total purchases of the prior group are definitely higher than the latter groups. 
Therefore, in this case, I compare *the rate per user* among these groups (instead of the total). The purpose is to check:
* performance of ads: *impression rate* and *click rate*.
* whether the average `page_views`, `cart_adds`, and `purchase` per user increase after running ads.

#### 1. Calculate the number of users in each group

```TSQL
--Number of users who received impressions during campaign periods
SELECT COUNT(DISTINCT user_id) AS received_impressions
FROM #campaign_summary
WHERE impression > 0
AND campaign_name IS NOT NULL;
```
| received_impressions  |
|-----------------------|
| 417                   |

```TSQL
--Number of users who received impressions but didn't click on the ad during campaign periods
SELECT COUNT(DISTINCT user_id) AS received_impressions_not_clicked
FROM #campaign_summary
WHERE impression > 0
AND click = 0
AND campaign_name IS NOT NULL;
```
| received_impressions_not_clicked  |
|-----------------------------------|
| 127                               |

```TSQL
--Number of users who didn't receive impressions during campaign periods
SELECT COUNT(DISTINCT user_id) AS received_impressions
FROM #campaign_summary
WHERE campaign_name IS NOT NULL
AND user_id NOT IN (
  SELECT user_id
  FROM #campaign_summary
  WHERE impression > 0);
```
| received_impressions  |
|-----------------------|
| 56                    |

Now we know:
* The number of users who received impressions during campaign periods is 417.
* The number of users who received impressions but didn't click on the ad is 127.
* The number of users who didn't receive impressions during campaign periods is 56.

Using those numbers, we can calculate:
* Overall, impression rate = 100 * 417 / (417+56) = 88.2 %
* Overall, click rate = 100-(100 * 127 / 417) = 69.5 %

#### 2. Calculate the average clicks, average views, average cart adds, and average purchases of each group

```TSQL
--For users who received impressions
DECLARE @received int 
SET @received = 417

SELECT 
  CAST(1.0*SUM(page_views) / @received AS decimal(10,1)) AS avg_view,
  CAST(1.0*SUM(cart_adds) / @received AS decimal(10,1)) AS avg_cart_adds,
  CAST(1.0*SUM(purchase) / @received AS decimal(10,1)) AS avg_purchase
FROM #campaign_summary
WHERE impression > 0
AND campaign_name IS NOT NULL;
```
| avg_view | avg_cart_adds | avg_purchase  |
|----------|---------------|---------------|
|  15.3    | 9.0           | 1.5           |

```TSQL
--For users who received impressions but didn't click on the ad
DECLARE @received_not_clicked int 
SET @received_not_clicked = 127

SELECT
  CAST(1.0*SUM(page_views) / @received_not_clicked AS decimal(10,1)) AS avg_view,
  CAST(1.0*SUM(cart_adds) / @received_not_clicked AS decimal(10,1)) AS avg_cart_adds,
  CAST(1.0*SUM(purchase) / @received_not_clicked AS decimal(10,1)) AS avg_purchase
FROM #campaign_summary
WHERE impression > 0
AND click = 0
AND campaign_name IS NOT NULL;
```
| avg_view | avg_cart_adds | avg_purchase  |
|----------|---------------|---------------|
| 7.5      | 2.7           | 0.8           | 

```TSQL
--For users didn't receive impressions 
DECLARE @not_received int 
SET @not_received = 56

SELECT 
  CAST(1.0*SUM(page_views) / @not_received AS decimal(10,1)) AS avg_view,
  CAST(1.0*SUM(cart_adds) / @not_received AS decimal(10,1)) AS avg_cart_adds,
  CAST(1.0*SUM(purchase) / @not_received AS decimal(10,1)) AS avg_purchase
FROM #campaign_summary
WHERE campaign_name IS NOT NULL
AND user_id NOT IN (
  SELECT user_id
  FROM #campaign_summary
  WHERE impression > 0);
```
| avg_view | avg_cart_adds | avg_purchase  |
|----------|---------------|---------------|
| 19.4     | 5.8           | 1.2           |

#### 3. Compare the average views, average cart adds and average purchases of users received impressions and not received impressions

Combine results in (2), we have the table below:

|                             | avg_view | avg_cart_adds | avg_purchase |
|-----------------------------|----------|---------------|--------------|
| Received impressions        | 15.3     | 9             | 1.5          |
| Not received impressions    | 19.4     | 5.8           | 1.2          |
| *Increase by campaigns*     | *No*     | *Yes*         | *Yes*        |

Insights:
* During campaign periods, the average view per user decreases while the average of products added to cart per user and average of purchased products per user increase. Customers might not wander around many pages to select products, but click on ads or directly go to the relevant page having that products. 
* Customers received impressions were more likely to add products to cart then to purchase them: (9-5.8) > (1.5-1.2).

#### 4. Compare the average purchases of users received impressions and received impressions but not clicked to ads
Combine results in (2), we have the table below:

|                                      | avg_purchase  |
|--------------------------------------|---------------|
| Received impressions                 | 1.5           |
| Received impressions but not clicked | 0.8           |
| *Increase by clicking to the ads*    | *Yes*         |

Insights:
* The average purchases for users who received impressions but didn't click on ads is lower than those who received impressions in overall. 
* Clicking on ads didn't lead to higher purchase rate.
