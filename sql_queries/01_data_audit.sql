-- DATA QUALITY AND COMPLETENESS ASSESSMENT
-- Goal: Ensure the ER tracking system is capturing reliable data.

SELECT 
    COUNT(*) AS total_visits,
    COUNT(DISTINCT [Visit ID]) AS unique_visits,
    
    -- Check for missing values in critical time-stamps
    COUNT(*) - COUNT([Time to Registration (min)]) AS missing_reg_time,
    COUNT(*) - COUNT([Time to Triage (min)]) AS missing_triage_time,
    COUNT(*) - COUNT([Time to Medical Professional (min)]) AS missing_doctor_time,
    
    -- Data integrity checks
    SUM(CASE WHEN [Total Wait Time (min)] < 0 THEN 1 ELSE 0 END) AS negative_wait_times,
    SUM(CASE WHEN [Patient Satisfaction] < 1 OR [Patient Satisfaction] > 10 THEN 1 ELSE 0 END) AS invalid_satisfaction_scores
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$];
