-- EXECUTIVE OPERATIONS DASHBOARD
-- A single view of all critical KPIs for hospital leadership.

WITH metrics AS (
    SELECT 
        COUNT(*) AS total_visits,
        AVG(CAST([Total Wait Time (min)] AS FLOAT)) AS avg_wait,
        AVG(CAST([Patient Satisfaction] AS FLOAT)) AS avg_sat,
        SUM(CASE WHEN [Urgency Level] = 'Critical' AND [Time to Medical Professional (min)] <= 10 THEN 1 ELSE 0 END) AS critical_targets_met,
        SUM(CASE WHEN [Urgency Level] = 'Critical' THEN 1 ELSE 0 END) AS total_critical
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
)
SELECT 
    'Total ER Volume' AS KPI, CAST(total_visits AS NVARCHAR) AS Value FROM metrics
UNION ALL
SELECT 'Avg Wait Time', CAST(ROUND(avg_wait, 1) AS NVARCHAR) + ' mins' FROM metrics
UNION ALL
SELECT 'Avg Satisfaction', CAST(ROUND(avg_sat, 2) AS NVARCHAR) + ' / 10' FROM metrics
UNION ALL
SELECT 'Critical Care Target %', CAST(ROUND(100.0 * critical_targets_met / total_critical, 2) AS NVARCHAR) + '%' FROM metrics;
