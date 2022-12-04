---------------------
--D. Index Analysis--
---------------------

SELECT 
  temp.*,
  map.interest_name
FROM (
  SELECT
    interest_id,
		month_year,
		DENSE_RANK() OVER(PARTITION BY month_year ORDER BY AVG(composition) DESC) AS rnk_avg_composition
	FROM interest_metrics
	WHERE month_year IS NOT NULL
	GROUP BY interest_id, month_year
	) temp
JOIN interest_map map 
  ON temp.interest_id = map.id
WHERE temp.rnk_avg_composition <= 10
