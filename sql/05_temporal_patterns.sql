-- ============================================================================
-- Q5: TEMPORAL PATTERNS - DAY OF WEEK ANALYSIS
-- ============================================================================
-- Business Question: Which days have highest volume and longest waits?
--
-- Purpose: Optimize staffing schedules based on demand patterns
-- Skills Demonstrated: Time-based segmentation, pattern analysis
--
-- Expected Output: 7 rows (Monday-Sunday) with demand metrics
-- Business Impact: Enable dynamic staffing vs. uniform scheduling
-- ============================================================================

SELECT 
    [Day of Week],
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_total_visits,
    
    -- Wait Time Metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Time to Registration (min)] AS FLOAT)), 1) AS avg_registration_time,
    ROUND(AVG(CAST([Time to Triage (min)] AS FLOAT)), 1) AS avg_triage_time,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_doctor_wait,
    
    -- Patient Outcomes
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Staffing Levels
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    
    -- High Urgency Volume
    SUM(CASE WHEN [Urgency Level] IN ('Critical', 'High') THEN 1 ELSE 0 END) AS high_urgency_visits
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
GROUP BY [Day of Week]
ORDER BY 
    CASE [Day of Week]
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- ============================================================================
-- Q6: TIME OF DAY ANALYSIS AND PEAK HOURS
-- ============================================================================
-- Business Question: When should we schedule maximum staff for peak demand?
--
-- Purpose: Identify optimal shift scheduling and resource deployment
-- Expected Output: 4 rows (Morning, Afternoon, Evening, Night)
-- ============================================================================

SELECT 
    [Time of Day],
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_visits,
    
    -- Wait Time Metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    
    -- Urgency Distribution
    ROUND(100.0 * SUM(CASE WHEN [Urgency Level] = 'Critical' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_critical,
    ROUND(100.0 * SUM(CASE WHEN [Urgency Level] IN ('Critical', 'High') THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_urgency,
    
    -- Patient Satisfaction
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Resource Levels
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
GROUP BY [Time of Day]
ORDER BY 
    CASE [Time of Day]
        WHEN 'Morning' THEN 1
        WHEN 'Afternoon' THEN 2
        WHEN 'Evening' THEN 3
        WHEN 'Night' THEN 4
    END;

-- ============================================================================
-- Interpretation Guide:
-- Look for mismatches between volume and staffing:
--   - High volume day + low nurse ratio = inefficiency
--   - Low volume day + high nurse ratio = overstaffing
--
-- Action Items:
--   - Increase staffing on high-volume days/times
--   - Deploy "surge teams" during peak periods
--   - Consider splitting shifts to match demand curves
-- ============================================================================
