-------------------------------------
--A. Data Exploration and Cleansing--
-------------------------------------

--1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

--modify the length of column month_year so it can store 10 characters
ALTER TABLE fresh_segments.dbo.interest_metrics
ALTER COLUMN month_year VARCHAR(10);

--update values in month_year column
UPDATE fresh_segments.dbo.interest_metrics
SET month_year = '01-' + month_year;

--convert month_year to DATE
ALTER TABLE fresh_segments.dbo.interest_metrics
ALTER COLUMN month_year DATE;

SELECT * FROM fresh_segments.dbo.interest_metrics;


--2. What is count of records in the fresh_segments.interest_metrics for each month_year value 
--sorted in chronological order (earliest to latest) with the null values appearing first?

SELECT 
  month_year,
  COUNT(*) AS cnt
FROM interest_metrics
GROUP BY month_year
ORDER BY month_year;
