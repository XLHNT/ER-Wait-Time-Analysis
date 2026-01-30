-- ============================================================================
-- Q4: HOSPITAL AND REGIONAL PERFORMANCE COMPARISON
-- ============================================================================
-- Business Question: Which hospitals/regions need operational improvement?
--
-- Purpose: Identify best-practice facilities and underperformers
-- Skills Demonstrated: Multi-level grouping, ranking functions, performance benchmarking
--
-- Expected Output: One row per hospital with performance rankings
-- Use Case: Resource allocation, best practice sharing, intervention targeting
-- ============================================================================

SELECT 
    Region,
    [Hospital Name],
    [Hospital ID],
    
    COUNT(*) AS total_visits,
    [Facility Size (Beds)] AS facility_size,
    
    -- Wait Time Performance
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    
    -- Patient Satisfaction
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Operational Metrics
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    ROUND(AVG(CAST([Specialist Availability] AS FLOAT)), 1) AS avg_specialist_availability,
    
    -- Performance Rankings
    RANK() OVER (ORDER BY AVG(CAST([Total Wait Time (min)] AS FLOAT)) ASC) AS wait_time_rank_best_to_worst,
    RANK() OVER (ORDER BY AVG(CAST([Patient Satisfaction] AS FLOAT)) DESC) AS satisfaction_rank
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Total Wait Time (min)] >= 0
GROUP BY Region, [Hospital Name], [Hospital ID], [Facility Size (Beds)]
ORDER BY avg_wait_time ASC;

-- ============================================================================
-- Interpretation Guide:
-- Top 3 Hospitals (rank 1-3): 
--   - Document their best practices
--   - Use as training models for others
--
-- Bottom 3 Hospitals:
--   - Immediate intervention targets
--   - Check if staffing (nurse ratio, specialist availability) is the issue
--
-- Look for patterns:
--   - Does facility size correlate with performance?
--   - Do certain regions consistently outperform?
--   - Is nurse ratio the key differentiator?
-- ============================================================================
