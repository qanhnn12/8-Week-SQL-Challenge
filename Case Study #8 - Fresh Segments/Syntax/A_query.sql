-------------------------------------
--A. Data Exploration and Cleansing--
-------------------------------------

--1. Update the fresh_segments.interest_metrics table by modifying the month_year column to be a date data type with the start of the month

--Modify the length of column month_year so it can store 10 characters
ALTER TABLE fresh_segments.dbo.interest_metrics
ALTER COLUMN month_year VARCHAR(10);

--Update values in month_year column
UPDATE fresh_segments.dbo.interest_metrics
SET month_year =  CONVERT(DATE, '01-' + month_year, 105)

--Convert month_year to DATE
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


--3. What do you think we should do with these null values in the fresh_segments.interest_metrics?

--interest_id = 21246 have NULL _month, _year, and month_year
SELECT *
FROM interest_metrics
WHERE month_year IS NULL
ORDER BY interest_id DESC;

--Delete rows that are null in column interest_id (1193 rows)
DELETE FROM interest_metrics
WHERE interest_id IS NULL;


--4. How many interest_id values exist in the fresh_segments.interest_metrics table 
--but not in the fresh_segments.interest_map table? What about the other way around?

SELECT 
  COUNT(DISTINCT map.id) AS map_id_count,
  COUNT(DISTINCT metrics.interest_id) AS metrics_id_count,
  SUM(CASE WHEN map.id IS NULL THEN 1 END) AS not_in_metric,
  SUM(CASE WHEN metrics.interest_id is NULL THEN 1 END) AS not_in_map
FROM interest_metrics metrics
FULL JOIN interest_map map
  ON metrics.interest_id = map.id;
  

--5. Summarise the id values in the fresh_segments.interest_map by its total record count in this table

SELECT COUNT(*) AS map_id_count
FROM interest_map;


--6. What sort of table join should we perform for our analysis and why? 
--Check your logic by checking the rows where interest_id = 21246 in your joined output and 
--include all columns from fresh_segments.interest_metrics and all columns from fresh_segments.interest_map except from the id column.

SELECT 
  metrics.*,
  map.interest_name,
  map.interest_summary,
  map.created_at,
  map.last_modified
FROM interest_metrics metrics
JOIN interest_map map
  ON metrics.interest_id = map.id
WHERE metrics.interest_id = 21246;
  
  
--7. Are there any records in your joined table where the month_year value is before the created_at value from the fresh_segments.interest_map table? 
--Do you think these values are valid and why?

--Check if metrics.month_year < map.created_at
SELECT COUNT(*) AS cnt
FROM interest_metrics metrics
JOIN interest_map map
  ON metrics.interest_id = map.id
WHERE metrics.month_year < CAST(map.created_at AS DATE);

--Check if metrics.month_year and map.created_at are in the same month
SELECT COUNT(*) AS cnt
FROM interest_metrics metrics
JOIN interest_map map
  ON map.id = metrics.interest_id
WHERE metrics.month_year < CAST(DATEADD(DAY, -DAY(map.created_at)+1, map.created_at) AS DATE);
