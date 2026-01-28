-- STAFFING AND COST EFFICIENCY
-- Goal: Identify the nurse-to-patient ratio that optimizes satisfaction vs cost.

WITH staffing_metrics AS (
    SELECT 
        CASE 
            WHEN [Nurse-to-Patient Ratio] <= 3 THEN '1. Understaffed (1-3)'
            WHEN [Nurse-to-Patient Ratio] <= 5 THEN '2. Adequate (4-5)'
            WHEN [Nurse-to-Patient Ratio] <= 7 THEN '3. Well-Staffed (6-7)'
            ELSE '4. Optimal (8+)'
        END AS staffing_category,
        [Total Wait Time (min)],
        [Patient Satisfaction],
        ([Nurse-to-Patient Ratio] * 50) AS estimated_hourly_cost -- Simulation
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
)
SELECT 
    staffing_category,
    COUNT(*) AS volume,
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait,
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    ROUND(AVG(estimated_hourly_cost), 0) AS avg_nursing_cost_per_visit
FROM staffing_metrics
GROUP BY staffing_category
ORDER BY staffing_category;
