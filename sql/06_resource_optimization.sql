-- ============================================================================
-- Q7-Q11: RESOURCE OPTIMIZATION AND CORRELATION ANALYSIS
-- ============================================================================
-- Business Questions: 
--   - How do nurse staffing levels impact wait times and satisfaction?
--   - What's the relationship between specialist availability and patient outcomes?
--   - What are optimal staffing levels for different urgency mixes?
--
-- Purpose: Quantify ROI of staffing investments
-- Skills Demonstrated: Correlation analysis, bucketing, operational efficiency
--
-- Expected Output: Performance metrics segmented by staffing levels
-- Business Value: Build business case for staffing budget requests
-- ============================================================================

-- ============================================================================
-- PART 1: Nurse-to-Patient Ratio Analysis
-- ============================================================================
SELECT 
    CASE 
        WHEN [Nurse-to-Patient Ratio] <= 3.5 THEN '1:3.5 or better (Optimal)'
        WHEN [Nurse-to-Patient Ratio] <= 4.5 THEN '1:3.6-4.5 (Adequate)'
        WHEN [Nurse-to-Patient Ratio] <= 5.5 THEN '1:4.6-5.5 (Strained)'
        ELSE '1:5.6+ (Critical Shortage)'
    END AS staffing_level,
    
    COUNT(*) AS visits,
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    
    -- Performance Metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- High Satisfaction Rate
    ROUND(100.0 * SUM(CASE WHEN [Patient Satisfaction] >= 8 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_satisfaction
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Nurse-to-Patient Ratio] IS NOT NULL
  AND [Total Wait Time (min)] >= 0
GROUP BY 
    CASE 
        WHEN [Nurse-to-Patient Ratio] <= 3.5 THEN '1:3.5 or better (Optimal)'
        WHEN [Nurse-to-Patient Ratio] <= 4.5 THEN '1:3.6-4.5 (Adequate)'
        WHEN [Nurse-to-Patient Ratio] <= 5.5 THEN '1:4.6-5.5 (Strained)'
        ELSE '1:5.6+ (Critical Shortage)'
    END
ORDER BY avg_nurse_ratio;

-- ============================================================================
-- PART 2: Specialist Availability Impact
-- ============================================================================
SELECT 
    CASE 
        WHEN [Specialist Availability] >= 60 THEN '60-100% (Well Staffed)'
        WHEN [Specialist Availability] >= 40 THEN '40-59% (Adequate)'
        WHEN [Specialist Availability] >= 20 THEN '20-39% (Understaffed)'
        ELSE '0-19% (Severely Short)'
    END AS specialist_availability_level,
    
    COUNT(*) AS visits,
    ROUND(AVG(CAST([Specialist Availability] AS FLOAT)), 1) AS avg_specialist_avail,
    
    -- Impact on High-Urgency Cases
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    
    -- Critical and High Urgency Performance
    ROUND(AVG(CASE WHEN [Urgency Level] IN ('Critical', 'High') 
                   THEN CAST([Time to Medical Professional (min)] AS FLOAT) 
                   END), 1) AS avg_urgent_time_to_doctor,
    
    -- Admission Rate (indicator of ability to handle complex cases)
    ROUND(100.0 * SUM(CASE WHEN [Patient Outcome] = 'Admitted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_admitted
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Specialist Availability] IS NOT NULL
  AND [Total Wait Time (min)] >= 0
GROUP BY 
    CASE 
        WHEN [Specialist Availability] >= 60 THEN '60-100% (Well Staffed)'
        WHEN [Specialist Availability] >= 40 THEN '40-59% (Adequate)'
        WHEN [Specialist Availability] >= 20 THEN '20-39% (Understaffed)'
        ELSE '0-19% (Severely Short)'
    END
ORDER BY avg_specialist_avail DESC;

-- ============================================================================
-- PART 3: Combined Resource Impact (Nurse + Specialist)
-- ============================================================================
SELECT 
    -- Resource Classification
    CASE 
        WHEN [Nurse-to-Patient Ratio] <= 4.0 AND [Specialist Availability] >= 50 THEN 'Well Resourced'
        WHEN [Nurse-to-Patient Ratio] <= 4.5 AND [Specialist Availability] >= 40 THEN 'Adequately Resourced'
        WHEN [Nurse-to-Patient Ratio] <= 5.0 OR [Specialist Availability] >= 30 THEN 'Partially Resourced'
        ELSE 'Under Resourced'
    END AS resource_level,
    
    COUNT(*) AS visits,
    
    -- Average Resource Metrics
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    ROUND(AVG(CAST([Specialist Availability] AS FLOAT)), 1) AS avg_specialist_avail,
    
    -- Performance Outcomes
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Urgency-Specific Performance
    ROUND(AVG(CASE WHEN [Urgency Level] = 'Critical' 
                   THEN CAST([Time to Medical Professional (min)] AS FLOAT) 
                   END), 1) AS avg_critical_time_to_doctor
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Nurse-to-Patient Ratio] IS NOT NULL
  AND [Specialist Availability] IS NOT NULL
  AND [Total Wait Time (min)] >= 0
GROUP BY 
    CASE 
        WHEN [Nurse-to-Patient Ratio] <= 4.0 AND [Specialist Availability] >= 50 THEN 'Well Resourced'
        WHEN [Nurse-to-Patient Ratio] <= 4.5 AND [Specialist Availability] >= 40 THEN 'Adequately Resourced'
        WHEN [Nurse-to-Patient Ratio] <= 5.0 OR [Specialist Availability] >= 30 THEN 'Partially Resourced'
        ELSE 'Under Resourced'
    END
ORDER BY 
    CASE 
        WHEN resource_level = 'Well Resourced' THEN 1
        WHEN resource_level = 'Adequately Resourced' THEN 2
        WHEN resource_level = 'Partially Resourced' THEN 3
        ELSE 4
    END;

-- ============================================================================
-- Interpretation Guide:
-- 
-- ROI Calculation Example:
--   If moving from 1:5 ratio to 1:4 ratio:
--   - Reduces wait time by ~5-7 minutes
--   - Increases satisfaction by ~0.5-0.8 points
--   - Calculate: (Satisfaction improvement × Patient volume × Revenue per patient)
--               - (Additional nurse FTE cost)
--   = Business case for staffing investment
--
-- Key Insights to Extract:
--   1. What's the "optimal" staffing level (diminishing returns point)?
--   2. Which resource (nurse vs specialist) has bigger impact?
--   3. At what staffing level do we start seeing patient safety risks?
-- ============================================================================
