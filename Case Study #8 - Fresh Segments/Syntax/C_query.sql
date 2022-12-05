-----------------------
--C. Segment Analysis--
-----------------------

--1. Using our filtered dataset by removing the interests with less than 6 months worth of data, 
--which are the top 10 and bottom 10 interests which have the largest composition values in any month_year? 
--Only use the maximum composition value for each interest but you must keep the corresponding month_year.

WITH max_composition AS (
  SELECT 
    month_year,
    interest_id,
    MAX(composition) OVER(PARTITION BY interest_id) AS largest_composition
  FROM #interest_metrics_edited -- filtered dataset in which interests with less than 6 months are removed
  WHERE month_year IS NOT NULL
),
composition_rank AS (
  SELECT *,
    DENSE_RANK() OVER(ORDER BY largest_composition DESC) AS rnk
  FROM max_composition
)

--Top 10 interests that have the largest composition values
SELECT 
  cr.interest_id,
  im.interest_name,
  cr.rnk
FROM composition_rank cr
JOIN interest_map im ON cr.interest_id = im.id
WHERE cr.rnk <= 10
ORDER BY cr.rnk;

--Bottom 10 interests that have the largest composition values
SELECT 
  DISTINCT TOP 10 cr.interest_id,
  im.interest_name,
  cr.rnk
FROM composition_rank cr
JOIN interest_map im ON cr.interest_id = im.id
ORDER BY cr.rnk DESC;


--2. Which 5 interests had the lowest average ranking value?

SELECT 
  TOP 5 metrics.interest_id,
  map.interest_name,
  CAST(AVG(1.0*metrics.ranking) AS decimal(10,2)) AS avg_ranking
FROM #interest_metrics_edited metrics
JOIN interest_map map
  ON metrics.interest_id = map.id
GROUP BY metrics.interest_id, map.interest_name
ORDER BY avg_ranking;


--3. Which 5 interests had the largest standard deviation in their percentile_ranking value?

SELECT 
  DISTINCT TOP 5 metrics.interest_id,
  map.interest_name,
  ROUND(STDEV(metrics.percentile_ranking) 
    OVER(PARTITION BY metrics.interest_id), 2) AS std_percentile_ranking
FROM #interest_metrics_edited metrics
JOIN interest_map map
ON metrics.interest_id = map.id
ORDER BY std_percentile_ranking DESC;


--4. For the 5 interests found in the previous question - what were minimum and maximum percentile_ranking values for each interest 
--and its corresponding year_month value? Can you describe what is happening for these 5 interests?

--Based on the query for the previous question
WITH largest_std_interests AS (
  SELECT 
    DISTINCT TOP 5 metrics.interest_id,
    map.interest_name,
    map.interest_summary,
    ROUND(STDEV(metrics.percentile_ranking) 
      OVER(PARTITION BY metrics.interest_id), 2) AS std_percentile_ranking
  FROM #interest_metrics_edited metrics
  JOIN interest_map map
  ON metrics.interest_id = map.id
  ORDER BY std_percentile_ranking DESC
),
max_min_percentiles AS (
  SELECT 
    lsi.interest_id,
    lsi.interest_name,
    lsi. interest_summary,
    ime.month_year,
    ime.percentile_ranking,
    MAX(ime.percentile_ranking) OVER(PARTITION BY lsi.interest_id) AS max_pct_rnk,
    MIN(ime.percentile_ranking) OVER(PARTITION BY lsi.interest_id) AS min_pct_rnk
  FROM largest_std_interests lsi
  JOIN #interest_metrics_edited ime
  ON lsi.interest_id = ime.interest_id
)

SELECT 
  interest_id,
  interest_name,
  interest_summary,
  MAX(CASE WHEN percentile_ranking = max_pct_rnk THEN month_year END) AS max_pct_month_year,
  MAX(CASE WHEN percentile_ranking = max_pct_rnk THEN percentile_ranking END) AS max_pct_rnk,
  MIN(CASE WHEN percentile_ranking = min_pct_rnk THEN month_year END) AS min_pct_month_year,
  MIN(CASE WHEN percentile_ranking = min_pct_rnk THEN percentile_ranking END) AS min_pct_rnk
FROM max_min_percentiles
GROUP BY interest_id, interest_name, interest_summary;
