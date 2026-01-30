
-- Q18: EXECUTIVE OPERATIONS DASHBOARD - COMPREHENSIVE ER METRICS

-- Business Question: Provide hospital leadership with complete ER performance metrics
--
-- Purpose: Executive-level decision support and board reporting
-- Skills Demonstrated: CTEs, UNION ALL, executive reporting, KPI aggregation
--
-- Expected Output: Formatted single-column report with all critical metrics
-- Audience: CMO, Hospital Administrator, Board of Directors
-- Frequency: Monthly strategic review or quarterly board meetings


WITH overall_metrics AS (
    SELECT 
        COUNT(*) AS total_visits,
        COUNT(DISTINCT [Patient ID]) AS unique_patients,
        COUNT(DISTINCT [Hospital ID]) AS num_hospitals,
        
        -- Wait time KPIs
        ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait,
        ROUND(AVG(CAST([Time to Registration (min)] AS FLOAT)), 1) AS avg_registration_time,
        ROUND(AVG(CAST([Time to Triage (min)] AS FLOAT)), 1) AS avg_triage_time,
        ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
        
        -- Patient satisfaction
        ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
        ROUND(100.0 * SUM(CASE WHEN [Patient Satisfaction] >= 8 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_satisfaction,
        
        -- Urgency mix
        ROUND(100.0 * SUM(CASE WHEN [Urgency Level] = 'Critical' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_critical,
        ROUND(100.0 * SUM(CASE WHEN [Urgency Level] IN ('Critical', 'High') THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_urgency,
        
        -- Outcomes
        ROUND(100.0 * SUM(CASE WHEN [Patient Outcome] = 'Admitted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_admitted,
        
        -- Staffing
        ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
        ROUND(AVG(CAST([Specialist Availability] AS FLOAT)), 1) AS avg_specialist_avail
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
),
performance_targets AS (
    SELECT 
        SUM(CASE WHEN [Urgency Level] = 'Critical' AND [Time to Medical Professional (min)] <= 10 THEN 1 ELSE 0 END) AS critical_met_target,
        SUM(CASE WHEN [Urgency Level] = 'Critical' THEN 1 ELSE 0 END) AS total_critical,
        
        SUM(CASE WHEN [Total Wait Time (min)] <= 30 THEN 1 ELSE 0 END) AS visits_under_30min,
        COUNT(*) AS total_measured_visits
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
    WHERE [Total Wait Time (min)] >= 0
),
peak_patterns AS (
    SELECT TOP 1
        [Day of Week] AS busiest_day,
        COUNT(*) AS visits_on_busiest_day
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
    GROUP BY [Day of Week]
    ORDER BY COUNT(*) DESC
),
best_worst_hospitals AS (
    SELECT 
        MIN(avg_wait) AS best_hospital_wait,
        MAX(avg_wait) AS worst_hospital_wait
    FROM (
        SELECT AVG(CAST([Total Wait Time (min)] AS FLOAT)) AS avg_wait
        FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
        WHERE [Total Wait Time (min)] >= 0
        GROUP BY [Hospital ID]
    ) hospital_waits
)

-- Formatted Executive Report Output
SELECT 
    '=== VOLUME METRICS ===' AS section,
    CAST(om.total_visits AS NVARCHAR(100)) AS metric_value,
    'Total ER Visits' AS metric_name
FROM overall_metrics om

UNION ALL SELECT '', CAST(om.unique_patients AS NVARCHAR(100)), 'Unique Patients'
FROM overall_metrics om

UNION ALL SELECT '', CAST(om.num_hospitals AS NVARCHAR(100)), 'Hospitals in Network'
FROM overall_metrics om

UNION ALL SELECT '', '', ''

UNION ALL SELECT '=== WAIT TIME PERFORMANCE ===', '', ''

UNION ALL SELECT '', CAST(om.avg_total_wait AS NVARCHAR(100)) + ' min', 'Average Total Wait Time'
FROM overall_metrics om

UNION ALL SELECT '', CAST(om.avg_registration_time AS NVARCHAR(100)) + ' min', 'Average Registration Time'
FROM overall_metrics om

UNION ALL SELECT '', CAST(om.avg_triage_time AS NVARCHAR(100)) + ' min', 'Average Triage Time'
FROM overall_metrics om

UNION ALL SELECT '', CAST(om.avg_time_to_doctor AS NVARCHAR(100)) + ' min', 'Average Time to Doctor'
FROM overall_metrics om

UNION ALL SELECT '', 
    CAST(ROUND(100.0 * pt.visits_under_30min / pt.total_measured_visits, 2) AS NVARCHAR(100)) + '%',
    'Visits Under 30 Minutes'
FROM performance_targets pt

UNION ALL SELECT '', '', ''

UNION ALL SELECT '=== PATIENT SATISFACTION ===', '', ''

UNION ALL SELECT '', CAST(om.avg_satisfaction AS NVARCHAR(100)) + ' / 10', 'Average Satisfaction Score'
FROM overall_metrics om

UNION ALL SELECT '', CAST(om.pct_high_satisfaction AS NVARCHAR(100)) + '%', 'High Satisfaction Rate (8+)'
FROM overall_metrics om

UNION ALL SELECT '', '', ''

UNION ALL SELECT '=== CLINICAL METRICS ===', '', ''

UNION ALL SELECT '', CAST(om.pct_critical AS NVARCHAR(100)) + '%', 'Critical Cases'
FROM overall_metrics om

UNION ALL SELECT '', CAST(om.pct_high_urgency AS NVARCHAR(100)) + '%', 'High Urgency Cases'
FROM overall_metrics om

UNION ALL SELECT '', 
    CAST(ROUND(100.0 * pt.critical_met_target / NULLIF(pt.total_critical, 0), 2) AS NVARCHAR(100)) + '%',
    'Critical Patients Seen Within 10 Min'
FROM performance_targets pt

UNION ALL SELECT '', CAST(om.pct_admitted AS NVARCHAR(100)) + '%', 'Admission Rate'
FROM overall_metrics om

UNION ALL SELECT '', '', ''

UNION ALL SELECT '=== STAFFING METRICS ===', '', ''

UNION ALL SELECT '', CAST(om.avg_nurse_ratio AS NVARCHAR(100)), 'Average Nurse-to-Patient Ratio'
FROM overall_metrics om

UNION ALL SELECT '', CAST(om.avg_specialist_avail AS NVARCHAR(100)), 'Average Specialist Availability'
FROM overall_metrics om

UNION ALL SELECT '', '', ''

UNION ALL SELECT '=== OPERATIONAL INSIGHTS ===', '', ''

UNION ALL SELECT '', pp.busiest_day + ' (' + CAST(pp.visits_on_busiest_day AS NVARCHAR(100)) + ' visits)', 
    'Busiest Day of Week'
FROM peak_patterns pp

UNION ALL SELECT '', CAST(bwh.best_hospital_wait AS NVARCHAR(100)) + ' min', 'Best Hospital Average Wait'
FROM best_worst_hospitals bwh

UNION ALL SELECT '', CAST(bwh.worst_hospital_wait AS NVARCHAR(100)) + ' min', 'Worst Hospital Average Wait'
FROM best_worst_hospitals bwh;


-- Usage Guide:
-- This query produces a formatted single-column report suitable for:
--   - Monthly leadership presentations
--   - Board meeting KPI summaries  
--   - Quality committee reviews
--   - Strategic planning sessions
--
-- Copy the results directly into PowerPoint/Excel for executive reporting.
