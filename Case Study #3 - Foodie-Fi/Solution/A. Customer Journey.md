# 🥑 Case Study #3 - Foodie-Fi
## A. Customer Journey
Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.
```TSQL
SELECT 
	s.*,
	p.plan_name,
	p.price
FROM subscriptions s
JOIN plans p ON s.plan_id = p.plan_id
WHERE customer_id IN (1, 2, 11, 13, 15, 16, 18, 19);
```
| customer_id | plan_id | start_date | plan_name     | price   |
|-------------|---------|------------|---------------|---------|
| 1           | 0       | 2020-08-01 | trial         | 0.00    |
| 1           | 1       | 2020-08-08 | basic monthly | 9.90    |
| 2           | 0       | 2020-09-20 | trial         | 0.00    |
| 2           | 3       | 2020-09-27 | pro annual    | 199.00  |
| 11          | 0       | 2020-11-19 | trial         | 0.00    |
| 11          | 4       | 2020-11-26 | churn         | NULL    |
| 13          | 0       | 2020-12-15 | trial         | 0.00    |
| 13          | 1       | 2020-12-22 | basic monthly | 9.90    |
| 13          | 2       | 2021-03-29 | pro monthly   | 19.90   |
| 15          | 0       | 2020-03-17 | trial         | 0.00    |
| 15          | 2       | 2020-03-24 | pro monthly   | 19.90   |
| 15          | 4       | 2020-04-29 | churn         | NULL    |
| 16          | 0       | 2020-05-31 | trial         | 0.00    |
| 16          | 1       | 2020-06-07 | basic monthly | 9.90    |
| 16          | 3       | 2020-10-21 | pro annual    | 199.00  |
| 18          | 0       | 2020-07-06 | trial         | 0.00    |
| 18          | 2       | 2020-07-13 | pro monthly   | 19.90   |
| 19          | 0       | 2020-06-22 | trial         | 0.00    |
| 19          | 2       | 2020-06-29 | pro monthly   | 19.90   |

Customer 1 signed up to 7-day free trial on 01/08/2020. After that time, he/she didn't cancel the subsciption, so the system automatically upgraded it to basic monthly plan on 08/08/2020.

Customer 2 signed up to 7-day free trial on 20/09/2020. After that time, he/she upgraded to pro annual plan on 27/09/2020.

Customer 11 signed up to 7-day free trial on 19/11/2020. After that time, he/she cancelled the subsciption on 26/11/2020.

Customer 13 signed up to 7-day free trial on 15/12/2020. After that time, he/she didn't cancelled the subsciption, so the system automatically upgraded it to basic monthly plan on 22/12/2020. He/she continued using that plan for 2 months. On 29/03/2020 (still in the 3rd month using basic monthly plan), he/she upgraded to pro monthly plan.

Customer 15 signed up to 7-day free trial on 17/03/2020. After that time, he/she didn't cancel the subsciption, so the system automatically upgraded it basic monthly plan on 24/03/2020. He/she then cancelled that plan after 5 days (29/03/2020). He/she was able to use the basic monthly plan until 24/04/2020.

Customer 16 signed up to 7-day free trial on 31/05/2020. After that time, he/she didn't cancel the subsciption, so the system automatically upgraded it to basic monthly plan on 07/06/2020. He/she continued using that plan for 4 months. On 21/10/2020 (still in the 4th month using basic monthly plan), he/she upgraded to pro annual plan.

Customer 18 signed up to 7-day free trial on 06/07/2020. After the trial time, he/she upgraded the subscription to pro monthly plan on 13/07/2020.

Customer 19 signed up to 7-day free trial on 22/06/2020. After that time, he/she upgraded the subscription to pro monthly plan on 29/06/2020. After 2 months using that plan, he/she upgraded to pro annual plan on 29/08/2020.

---
My solution for **[B. Data Analysis Questions](https://github.com/qanhnn12/8-Week-SQL-Challenge/blob/main/Case%20Study%20%233%20-%20Foodie-Fi/Solution/B.%20Data%20Analysis%20Questions.md)**.
