-- ============================================================================
-- Q3: URGENCY LEVEL DISTRIBUTION AND WAIT TIMES
-- ============================================================================
-- Business Question: Are we prioritizing critical patients appropriately?
--
-- Purpose: Patient safety analysis - ensure critical cases receive timely care
-- Skills Demonstrated: GROUP BY, segmentation, clinical prioritization analysis
--
-- Clinical Standards:
--   Critical patients: Should see doctor within 10 minutes
--   High urgency: Should see doctor within 20 minutes
-- Expected Output: 4 rows (one per urgency level) with performance metrics
--  CRITICAL: Monitor critical patient compliance closely for safety
-- ============================================================================

SELECT 
    [Urgency Level],
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_visits,
    
    -- Wait Time Metrics by Urgency
    ROUND(AVG(CAST([Time to Registration (min)] AS FLOAT)), 1) AS avg_time_to_registration,
    ROUND(AVG(CAST([Time to Triage (min)] AS FLOAT)), 1) AS avg_time_to_triage,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait_time,
    
    -- Patient Satisfaction by Urgency
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Outcome Distribution
    ROUND(100.0 * SUM(CASE WHEN [Patient Outcome] = 'Admitted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_admitted,
    ROUND(100.0 * SUM(CASE WHEN [Patient Outcome] = 'Discharged' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_discharged
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Urgency Level] IS NOT NULL
GROUP BY [Urgency Level]
ORDER BY 
    CASE [Urgency Level]
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        WHEN 'Low' THEN 4
        ELSE 5
    END;

-- ============================================================================
-- Interpretation Guide:
-- Critical Patients:
--   avg_time_to_doctor >10 min = SAFETY RISK - immediate action required
--   avg_time_to_doctor <10 min = Meeting standard
-- 
-- Expected Pattern:
--   Higher urgency → Higher admission rate
--   Higher urgency → Lower total volume
--   Critical patients may have lower satisfaction due to severity of condition
-- ============================================================================
