-- ============================================================================
-- Q1: DATA QUALITY AND COMPLETENESS ASSESSMENT
-- ============================================================================
-- Business Question: Is our ER tracking system capturing complete and accurate data?
-- 
-- Purpose: Validate data integrity before conducting analysis
-- Skills Demonstrated: Data quality assessment, completeness checks, integrity validation
-- 
-- Expected Output: Single row with completeness metrics for all fields
-- Red Flags: >5% missing data, any negative wait times, invalid satisfaction scores
-- ============================================================================

SELECT 
    -- Volume Metrics
    COUNT(*) AS total_visits,
    COUNT(DISTINCT [Visit ID]) AS unique_visits,
    COUNT(DISTINCT [Patient ID]) AS unique_patients,
    COUNT(DISTINCT [Hospital ID]) AS unique_hospitals,
    
    -- Wait Time Completeness Checks
    COUNT(*) - COUNT([Time to Registration (min)]) AS missing_reg_time,
    COUNT(*) - COUNT([Time to Triage (min)]) AS missing_triage_time,
    COUNT(*) - COUNT([Time to Medical Professional (min)]) AS missing_doctor_time,
    COUNT(*) - COUNT([Total Wait Time (min)]) AS missing_total_wait,
    
    -- Operational Data Completeness
    COUNT(*) - COUNT([Nurse-to-Patient Ratio]) AS missing_nurse_ratio,
    COUNT(*) - COUNT([Specialist Availability]) AS missing_specialist_avail,
    
    -- Outcome Completeness
    COUNT(*) - COUNT([Patient Outcome]) AS missing_outcome,
    COUNT(*) - COUNT([Patient Satisfaction]) AS missing_satisfaction,
    
    -- Data Integrity Checks
    SUM(CASE WHEN [Total Wait Time (min)] < 0 THEN 1 ELSE 0 END) AS negative_wait_times,
    SUM(CASE WHEN [Patient Satisfaction] < 1 OR [Patient Satisfaction] > 10 THEN 1 ELSE 0 END) AS invalid_satisfaction_scores
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$];

-- ============================================================================
-- Interpretation Guide:
-- - All missing counts should be 0 or very close to 0 (<1% of total)
-- - negative_wait_times and invalid_satisfaction_scores MUST be 0
-- - If integrity violations exist, investigate before proceeding with analysis
-- ============================================================================
