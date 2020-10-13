CREATE TEMPORARY TABLE tmp_lat_import AS 
  SELECT extract(epoch FROM date_trunc('second',ts)) AS collected, count(*) AS samples, min(latency) AS min_latency, round(1000*avg(latency))/1000 AS avg_latency, max(latency) AS max_latency FROM timing GROUP BY date_trunc('second',ts) LIMIT 0;
\copy tmp_lat_import FROM 'latency_1s.csv' WITH CSV HEADER
\copy (SELECT * FROM (SELECT TIMESTAMP 'epoch' + collected::int * INTERVAL '1 second' AS collected,samples AS value,'tps' AS metric FROM tmp_lat_import UNION SELECT TIMESTAMP 'epoch' + collected::int * INTERVAL '1 second',min_latency,'min_latency' AS metric FROM tmp_lat_import UNION SELECT TIMESTAMP 'epoch' + collected::int * INTERVAL '1 second',max_latency,'max_latency' AS metric FROM tmp_lat_import UNION SELECT TIMESTAMP 'epoch' + (tmp_lat_import.collected::int) * INTERVAL '1 second',avg_latency,'avg_latency' AS metric FROM tmp_lat_import) AS lat ORDER BY collected,metric) to 'latency_metric.csv' CSV HEADER
