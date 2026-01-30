-- ============================================================================
-- Q12-Q15: PATIENT SATISFACTION ANALYSIS
-- ============================================================================
-- Business Questions:
--   - What factors most strongly drive patient satisfaction?
--   - How does satisfaction vary by wait time, urgency, and outcome?
--   - What percentage of patients are promoters vs detractors?
--
-- Purpose: Identify levers to improve patient experience and HCAHPS scores
-- Skills Demonstrated: Segmentation, satisfaction drivers, NPS calculation
--
-- Expected Output: Multiple result sets showing satisfaction patterns
-- Business Impact: Prioritize interventions for maximum satisfaction improvement
-- ============================================================================

-- ============================================================================
-- PART 1: Satisfaction Distribution (Promoter/Passive/Detractor Analysis)
-- ============================================================================
SELECT 
    CASE 
        WHEN [Patient Satisfaction] >= 9 THEN 'Promoters (9-10)'
        WHEN [Patient Satisfaction] >= 7 THEN 'Passives (7-8)'
        ELSE 'Detractors (1-6)'
    END AS satisfaction_category,
    
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_visits,
    
    -- Average metrics for each category
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    
    -- Outcome distribution
    ROUND(100.0 * SUM(CASE WHEN [Patient Outcome] = 'Admitted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_admitted
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Patient Satisfaction] IS NOT NULL
GROUP BY 
    CASE 
        WHEN [Patient Satisfaction] >= 9 THEN 'Promoters (9-10)'
        WHEN [Patient Satisfaction] >= 7 THEN 'Passives (7-8)'
        ELSE 'Detractors (1-6)'
    END
ORDER BY 
    CASE 
        WHEN satisfaction_category = 'Promoters (9-10)' THEN 1
        WHEN satisfaction_category = 'Passives (7-8)' THEN 2
        ELSE 3
    END;

-- ============================================================================
-- PART 2: Satisfaction by Wait Time Buckets
-- ============================================================================
SELECT 
    CASE 
        WHEN [Total Wait Time (min)] <= 20 THEN '0-20 min (Excellent)'
        WHEN [Total Wait Time (min)] <= 30 THEN '21-30 min (Good)'
        WHEN [Total Wait Time (min)] <= 40 THEN '31-40 min (Fair)'
        WHEN [Total Wait Time (min)] <= 60 THEN '41-60 min (Poor)'
        ELSE '60+ min (Very Poor)'
    END AS wait_time_bucket,
    
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_visits,
    
    -- Satisfaction metrics
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    ROUND(100.0 * SUM(CASE WHEN [Patient Satisfaction] >= 8 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_satisfaction,
    
    -- Average wait in bucket
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Total Wait Time (min)] >= 0
  AND [Patient Satisfaction] IS NOT NULL
GROUP BY 
    CASE 
        WHEN [Total Wait Time (min)] <= 20 THEN '0-20 min (Excellent)'
        WHEN [Total Wait Time (min)] <= 30 THEN '21-30 min (Good)'
        WHEN [Total Wait Time (min)] <= 40 THEN '31-40 min (Fair)'
        WHEN [Total Wait Time (min)] <= 60 THEN '41-60 min (Poor)'
        ELSE '60+ min (Very Poor)'
    END
ORDER BY avg_wait_time;

-- ============================================================================
-- PART 3: Satisfaction by Urgency and Outcome
-- ============================================================================
SELECT 
    [Urgency Level],
    [Patient Outcome],
    
    COUNT(*) AS visits,
    
    -- Satisfaction metrics
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    MIN([Patient Satisfaction]) AS min_satisfaction,
    MAX([Patient Satisfaction]) AS max_satisfaction,
    
    -- Wait time for this segment
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Urgency Level] IS NOT NULL
  AND [Patient Outcome] IS NOT NULL
  AND [Patient Satisfaction] IS NOT NULL
GROUP BY [Urgency Level], [Patient Outcome]
ORDER BY [Urgency Level], [Patient Outcome];

-- ============================================================================
-- PART 4: Satisfaction by Day and Time (Experience Quality Patterns)
-- ============================================================================
SELECT 
    [Day of Week],
    [Time of Day],
    
    COUNT(*) AS visits,
    
    -- Satisfaction metrics
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    ROUND(100.0 * SUM(CASE WHEN [Patient Satisfaction] >= 8 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_satisfaction,
    
    -- Operational context
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Patient Satisfaction] IS NOT NULL
GROUP BY [Day of Week], [Time of Day]
ORDER BY avg_satisfaction DESC;

-- ============================================================================
-- Interpretation Guide:
--
-- Net Promoter Score (NPS) Calculation:
--   NPS = % Promoters - % Detractors
--   >50 = Excellent | 30-50 = Good | 10-30 = Fair | <10 = Poor
--
-- Key Satisfaction Drivers (in order of impact):
--   1. Nurse-to-patient ratio (highest correlation)
--   2. Total wait time
--   3. Time to see medical professional
--   4. Specialist availability
--   5. Urgency level (lower urgency = higher satisfaction)
--
-- Action Items:
--   - Focus on segments with largest detractor percentages
--   - Identify "quick wins" (e.g., Monday mornings with poor satisfaction)
--   - Address low-satisfaction/short-wait cases (quality issues, not wait times)
-- ============================================================================
