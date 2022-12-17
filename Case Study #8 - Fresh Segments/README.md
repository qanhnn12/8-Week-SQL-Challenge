# 🍊 Case Study #8 - Fresh Segments

<p align="center">
<img src="https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/IMG/8.png" align="center" width="400" height="400" >

## 📕 Table of Contents
* [Bussiness Task](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%20-%20Fresh%20Segments#%EF%B8%8F-bussiness-task)
* [Entity Relationship Diagram](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%20-%20Fresh%20Segments#-entity-relationship-diagram)
* [Case Study Questions](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%20-%20Fresh%20Segments#-case-study-questions)
* [My Solution](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%20-%20Fresh%20Segments#-my-solution)

---
## 🛠️ Bussiness Task
Fresh Segments is a digital marketing agency that helps other businesses analyse trends in online ad click behaviour for their unique customer base.

Clients share their customer lists with the Fresh Segments team who then aggregate interest metrics and generate a single dataset worth of metrics for further analysis.
In particular - the composition and rankings for different interests are provided for each client showing the proportion of their customer list who interacted with online assets related to each interest for each month.

Danny has asked for your assistance to analyse aggregated metrics for an example client and provide some high level insights about the customer list and their interests.

---
## 🔐 Entity Relationship Diagram
<p align="center">
<img src="https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/IMG/e8-updated.PNG" align="center width="600" height="300"">

---
## ❓ Case Study Questions
### A. Data Exploration and Cleansing
View my solution [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/A.%20Data%20Exploration%20and%20Cleansing.md).

1. Update the `fresh_segments.interest_metrics` table by modifying the `month_year` column to be a date data type with the start of the month
2. What is count of records in the `fresh_segments.interest_metrics` for each `month_year` value sorted in chronological order (earliest to latest) 
with the null values appearing first?
3. What do you think we should do with these null values in the `fresh_segments.interest_metrics`
4. How many `interest_id` values exist in the `fresh_segments.interest_metrics` table but not in the `fresh_segments.interest_map` table? 
What about the other way around?
5. Summarise the `id` values in the `fresh_segments.interest_map` by its total record count in this table.
6. What sort of table join should we perform for our analysis and why? 
Check your logic by checking the rows where `interest_id` = 21246 in your joined output and 
include all columns from `fresh_segments.interest_metrics` and all columns from `fresh_segments.interest_map` except from the `id` column.
7. Are there any records in your joined table where the `month_year` value is before the `created_at` value from the `fresh_segments.interest_map` table? 
Do you think these values are valid and why?

---
### B. Interest Analysis
View my solution [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/B.%20Interest%20Analysis.md).

1. Which interests have been present in all `month_year` dates in our dataset?
2. Using this same `total_months` measure - calculate the cumulative percentage of all records starting at 14 months - which `total_months` value 
passes the 90% cumulative percentage value?
3. If we were to remove all `interest_id` values which are lower than the `total_months` value we found in the previous question - how many total data points
would we be removing?
4. Does this decision make sense to remove these data points from a business perspective? 
Use an example where there are all 14 months present to a removed interest example for your arguments - think about 
what it means to have less months present from a segment perspective.
5. After removing these interests - how many unique interests are there for each month?

---
### C. Segment Analysis
View my solution [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/C.%20Segment%20Analysis.md).

1. Using our filtered dataset by removing the interests with less than 6 months worth of data, 
which are the top 10 and bottom 10 interests which have the largest composition values in any `month_year`? 
2. Only use the maximum `composition` value for each interest but you must keep the corresponding `month_year`.
3. Which 5 interests had the lowest average `ranking` value?
4. Which 5 interests had the largest standard deviation in their `percentile_ranking` value?
5. For the 5 interests found in the previous question - what was minimum and maximum `percentile_ranking` values for each interest 
and its corresponding `year_month` value? Can you describe what is happening for these 5 interests?
6. How would you describe our customers in this segment based off their `composition` and ranking values? 
What sort of products or services should we show to these customers and what should we avoid?

---
### D. Index Analysis
View my solution [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution/D.%20Index%20Analysis.md).

The `index_value` is a measure which can be used to reverse calculate the average composition for Fresh Segments’ clients.

Average composition can be calculated by dividing the `composition` column by the `index_value` column rounded to 2 decimal places.

1. What is the top 10 interests by the average composition for each month?
2. For all of these top 10 interests - which interest appears the most often?
3. What is the average of the average composition for the top 10 interests for each month?
4. What is the 3 month rolling average of the max average composition value from September 2018 to August 2019 and 
include the previous top ranking interests in the same output shown below.
5. Provide a possible reason why the max average composition might change from month to month? 
Could it signal something is not quite right with the overall business model for Fresh Segments?

Required output for question 4:

| month_year | interest_name                 | max_index_composition | 3_month_moving_avg | 1_month_ago                       | 2_months_ago                       |
|------------|-------------------------------|-----------------------|--------------------|-----------------------------------|------------------------------------|
| 2018-09-01 | Work Comes First Travelers    | 8.26                  | 7.61               | Las Vegas Trip Planners: 7.21     | Las Vegas Trip Planners: 7.36      |
| 2018-10-01 | Work Comes First Travelers    | 9.14                  | 8.20               | Work Comes First Travelers: 8.26  | Las Vegas Trip Planners: 7.21      |
| 2018-11-01 | Work Comes First Travelers    | 8.28                  | 8.56               | Work Comes First Travelers: 9.14  | Work Comes First Travelers: 8.26   |
| 2018-12-01 | Work Comes First Travelers    | 8.31                  | 8.58               | Work Comes First Travelers: 8.28  | Work Comes First Travelers: 9.14   |
| 2019-01-01 | Work Comes First Travelers    | 7.66                  | 8.08               | Work Comes First Travelers: 8.31  | Work Comes First Travelers: 8.28   |
| 2019-02-01 | Work Comes First Travelers    | 7.66                  | 7.88               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 8.31   |
| 2019-03-01 | Alabama Trip Planners         | 6.54                  | 7.29               | Work Comes First Travelers: 7.66  | Work Comes First Travelers: 7.66   |
| 2019-04-01 | Solar Energy Researchers      | 6.28                  | 6.83               | Alabama Trip Planners: 6.54       | Work Comes First Travelers: 7.66   |
| 2019-05-01 | Readers of Honduran Content   | 4.41                  | 5.74               | Solar Energy Researchers: 6.28    | Alabama Trip Planners: 6.54        |
| 2019-06-01 | Las Vegas Trip Planners       | 2.77                  | 4.49               | Readers of Honduran Content: 4.41 | Solar Energy Researchers: 6.28     |
| 2019-07-01 | Las Vegas Trip Planners       | 2.82                  | 3.33               | Las Vegas Trip Planners: 2.77     | Readers of Honduran Content: 4.41  |
| 2019-08-01 | Cosmetics and Beauty Shoppers | 2.73                  | 2.77               | Las Vegas Trip Planners: 2.82     | Las Vegas Trip Planners: 2.77      |

---
## 🚀 My Solution
* View the complete syntax [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%20-%20Fresh%20Segments/Syntax).
* View the result and explanation [HERE](https://github.com/qanhnn12/8-Week-SQL-Challenge/tree/main/Case%20Study%20%238%20-%20Fresh%20Segments/Solution).
