-- CORE PERFORMANCE METRICS
-- Goal: Benchmark against the 40-minute national average.

SELECT 
    [Urgency Level],
    COUNT(*) AS total_visits,
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait,
    
    -- Performance vs National Benchmark (40 min)
    CASE 
        WHEN AVG(CAST([Total Wait Time (min)] AS FLOAT)) < 30 THEN 'Excellent - Below Benchmark'
        WHEN AVG(CAST([Total Wait Time (min)] AS FLOAT)) < 45 THEN 'Good - Near Benchmark'
        ELSE 'Needs Improvement - Above Benchmark'
    END AS performance_status,
    
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Total Wait Time (min)] >= 0
GROUP BY [Urgency Level]
ORDER BY avg_total_wait ASC;
