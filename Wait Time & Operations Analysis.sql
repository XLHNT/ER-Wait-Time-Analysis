-- Q1: DATA QUALITY AND COMPLETENESS ASSESSMENT
-- Is our ER tracking system capturing complete data?

SELECT 
    COUNT(*) AS total_visits,
    COUNT(DISTINCT [Visit ID]) AS unique_visits,
    COUNT(DISTINCT [Patient ID]) AS unique_patients,
    COUNT(DISTINCT [Hospital ID]) AS unique_hospitals,
    
    -- Wait time completeness
    COUNT(*) - COUNT([Time to Registration (min)]) AS missing_reg_time,
    COUNT(*) - COUNT([Time to Triage (min)]) AS missing_triage_time,
    COUNT(*) - COUNT([Time to Medical Professional (min)]) AS missing_doctor_time,
    COUNT(*) - COUNT([Total Wait Time (min)]) AS missing_total_wait,
    
    -- Operational data completeness
    COUNT(*) - COUNT([Nurse-to-Patient Ratio]) AS missing_nurse_ratio,
    COUNT(*) - COUNT([Specialist Availability]) AS missing_specialist_avail,
    
    -- Outcome completeness
    COUNT(*) - COUNT([Patient Outcome]) AS missing_outcome,
    COUNT(*) - COUNT([Patient Satisfaction]) AS missing_satisfaction,
    
    -- Data integrity checks
    SUM(CASE WHEN [Total Wait Time (min)] < 0 THEN 1 ELSE 0 END) AS negative_wait_times,
    SUM(CASE WHEN [Patient Satisfaction] < 1 OR [Patient Satisfaction] > 10 THEN 1 ELSE 0 END) AS invalid_satisfaction_scores
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$];



-- Q2: OVERALL WAIT TIME METRICS AND BENCHMARKING
-- How do our wait times compare to national benchmarks?

SELECT 
    COUNT(*) AS total_visits,
    
    -- Registration metrics
    ROUND(AVG(CAST([Time to Registration (min)] AS FLOAT)), 1) AS avg_time_to_registration,
    MIN([Time to Registration (min)]) AS min_time_to_registration,
    MAX([Time to Registration (min)]) AS max_time_to_registration,
    
    -- Triage metrics
    ROUND(AVG(CAST([Time to Triage (min)] AS FLOAT)), 1) AS avg_time_to_triage,
    
    -- Doctor wait metrics
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    
    -- Total wait metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait_time,
    ROUND(STDEV(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS std_dev_wait_time,
    
    -- Benchmark comparison (40 min national average)
    CASE 
        WHEN AVG(CAST([Total Wait Time (min)] AS FLOAT)) < 30 THEN 'Excellent - Below Benchmark'
        WHEN AVG(CAST([Total Wait Time (min)] AS FLOAT)) < 45 THEN 'Good - Near Benchmark'
        ELSE 'Needs Improvement - Above Benchmark'
    END AS performance_vs_benchmark,
    
    -- Patient satisfaction
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction_score
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Total Wait Time (min)] >= 0;



-- Q3: URGENCY LEVEL DISTRIBUTION AND WAIT TIMES
-- Are we prioritizing critical patients appropriately?


SELECT 
    [Urgency Level],
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_visits,
    
    -- Wait time metrics by urgency
    ROUND(AVG(CAST([Time to Registration (min)] AS FLOAT)), 1) AS avg_time_to_registration,
    ROUND(AVG(CAST([Time to Triage (min)] AS FLOAT)), 1) AS avg_time_to_triage,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait_time,
    
    -- Patient satisfaction by urgency
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Outcome distribution
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




-- Q4: HOSPITAL AND REGIONAL PERFORMANCE COMPARISON
-- Which hospitals/regions need operational improvement?

SELECT 
    Region,
    [Hospital Name],
    [Hospital ID],
    
    COUNT(*) AS total_visits,
    [Facility Size (Beds)] AS facility_size,
    
    -- Wait time performance
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    
    -- Patient satisfaction
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Operational metrics
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    ROUND(AVG(CAST([Specialist Availability] AS FLOAT)), 1) AS avg_specialist_availability,
    
    -- Performance ranking
    RANK() OVER (ORDER BY AVG(CAST([Total Wait Time (min)] AS FLOAT)) ASC) AS wait_time_rank_best_to_worst,
    RANK() OVER (ORDER BY AVG(CAST([Patient Satisfaction] AS FLOAT)) DESC) AS satisfaction_rank
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Total Wait Time (min)] >= 0
GROUP BY Region, [Hospital Name], [Hospital ID], [Facility Size (Beds)]
ORDER BY avg_wait_time ASC;





-- Q5: TEMPORAL PATTERNS - DAY OF WEEK ANALYSIS
-- Which days have highest volume and longest waits?

SELECT 
    [Day of Week],
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_total_visits,
    
    -- Wait time metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Time to Registration (min)] AS FLOAT)), 1) AS avg_registration_time,
    ROUND(AVG(CAST([Time to Triage (min)] AS FLOAT)), 1) AS avg_triage_time,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_doctor_wait,
    
    -- Patient outcomes
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Staffing levels
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    
    -- High urgency volume
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




-- Q6: TIME OF DAY ANALYSIS AND PEAK HOURS
-- When should we schedule maximum staff for peak demand?

SELECT 
    [Time of Day],
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_visits,
    
    -- Wait time metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    
    -- Urgency distribution
    ROUND(100.0 * SUM(CASE WHEN [Urgency Level] = 'Critical' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_critical,
    ROUND(100.0 * SUM(CASE WHEN [Urgency Level] IN ('Critical', 'High') THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_urgency,
    
    -- Patient satisfaction
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Resource levels
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    ROUND(AVG(CAST([Specialist Availability] AS FLOAT)), 1) AS avg_specialist_avail
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
GROUP BY [Time of Day]
ORDER BY 
    CASE [Time of Day]
        WHEN 'Morning' THEN 1
        WHEN 'Afternoon' THEN 2
        WHEN 'Evening' THEN 3
        WHEN 'Night' THEN 4
    END;






-- Q7: SEASONAL VARIATIONS IN ER UTILIZATION
-- How do seasonal patterns affect staffing needs?

SELECT 
    Season,
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_annual_visits,
    
    -- Wait metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    MIN([Total Wait Time (min)]) AS min_wait,
    MAX([Total Wait Time (min)]) AS max_wait,
    
    -- Patient mix
    ROUND(100.0 * SUM(CASE WHEN [Urgency Level] IN ('Critical', 'High') THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_urgency,
    
    -- Outcomes
    ROUND(100.0 * SUM(CASE WHEN [Patient Outcome] = 'Admitted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_admitted,
    
    -- Satisfaction
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Operational capacity
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
GROUP BY Season
ORDER BY 
    CASE Season
        WHEN 'Winter' THEN 1
        WHEN 'Spring' THEN 2
        WHEN 'Summer' THEN 3
        WHEN 'Fall' THEN 4
    END;





-- Q8: STAFFING LEVELS AND WAIT TIME CORRELATION
-- What nurse-to-patient ratio minimizes wait times?

WITH staffing_categories AS (
    SELECT 
        [Visit ID],
        [Nurse-to-Patient Ratio],
        [Total Wait Time (min)],
        [Patient Satisfaction],
        [Time to Medical Professional (min)],
        
        CASE 
            WHEN [Nurse-to-Patient Ratio] <= 3 THEN '1. Understaffed (1-3)'
            WHEN [Nurse-to-Patient Ratio] <= 5 THEN '2. Adequate (4-5)'
            WHEN [Nurse-to-Patient Ratio] <= 7 THEN '3. Well-Staffed (6-7)'
            ELSE '4. Optimal (8+)'
        END AS staffing_category
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
    WHERE [Nurse-to-Patient Ratio] IS NOT NULL
)
SELECT 
    staffing_category,
    COUNT(*) AS visits,
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    
    -- Wait time impact
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    
    -- Patient satisfaction impact
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Efficiency indicator
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)) / NULLIF(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 0), 1) AS wait_per_nurse_ratio
FROM staffing_categories
GROUP BY staffing_category
ORDER BY staffing_category;



-- Q9: SPECIALIST AVAILABILITY IMPACT ON OUTCOMES
-- Does specialist availability reduce wait times and improve outcomes?

SELECT 
    CASE 
        WHEN [Specialist Availability] = 0 THEN '0. No Specialists'
        WHEN [Specialist Availability] <= 2 THEN '1. Low (1-2)'
        WHEN [Specialist Availability] <= 4 THEN '2. Medium (3-4)'
        ELSE '3. High (5+)'
    END AS specialist_availability_category,
    
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_visits,
    
    ROUND(AVG(CAST([Specialist Availability] AS FLOAT)), 1) AS avg_specialists,
    
    -- Wait time metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait,
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    
    -- Patient outcomes
    ROUND(100.0 * SUM(CASE WHEN [Patient Outcome] = 'Admitted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_admitted,
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Urgency distribution
    ROUND(100.0 * SUM(CASE WHEN [Urgency Level] IN ('Critical', 'High') THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_urgency
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Specialist Availability] IS NOT NULL
GROUP BY 
    CASE 
        WHEN [Specialist Availability] = 0 THEN '0. No Specialists'
        WHEN [Specialist Availability] <= 2 THEN '1. Low (1-2)'
        WHEN [Specialist Availability] <= 4 THEN '2. Medium (3-4)'
        ELSE '3. High (5+)'
    END
ORDER BY specialist_availability_category;



-- Q10: WAIT TIME BOTTLENECK ANALYSIS
-- Where in the ER process are bottlenecks occurring?

WITH wait_components AS (
    SELECT 
        [Visit ID],
        [Total Wait Time (min)] AS total_wait,
        [Time to Registration (min)] AS registration_time,
        [Time to Triage (min)] AS triage_time,
        [Time to Medical Professional (min)] AS doctor_time,
        
        -- Calculate percentage of total wait for each stage
        ROUND(100.0 * [Time to Registration (min)] / NULLIF([Total Wait Time (min)], 0), 1) AS pct_wait_registration,
        ROUND(100.0 * [Time to Triage (min)] / NULLIF([Total Wait Time (min)], 0), 1) AS pct_wait_triage,
        ROUND(100.0 * [Time to Medical Professional (min)] / NULLIF([Total Wait Time (min)], 0), 1) AS pct_wait_doctor
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
    WHERE [Total Wait Time (min)] > 0
)
SELECT 
    'Registration' AS process_stage,
    ROUND(AVG(registration_time), 1) AS avg_wait_minutes,
    ROUND(AVG(pct_wait_registration), 1) AS avg_pct_of_total_wait,
    COUNT(*) AS visits_analyzed
FROM wait_components

UNION ALL

SELECT 
    'Triage',
    ROUND(AVG(triage_time), 1),
    ROUND(AVG(pct_wait_triage), 1),
    COUNT(*)
FROM wait_components

UNION ALL

SELECT 
    'Waiting for Doctor',
    ROUND(AVG(doctor_time), 1),
    ROUND(AVG(pct_wait_doctor), 1),
    COUNT(*)
FROM wait_components

ORDER BY avg_wait_minutes DESC;




-- Q11: PATIENT SATISFACTION DRIVERS ANALYSIS
-- Business Question: What factors most influence patient satisfaction?

WITH satisfaction_categories AS (
    SELECT 
        [Visit ID],
        [Patient Satisfaction],
        [Total Wait Time (min)],
        [Urgency Level],
        [Nurse-to-Patient Ratio],
        [Patient Outcome],
        
        CASE 
            WHEN [Patient Satisfaction] <= 3 THEN '1. Very Dissatisfied (1-3)'
            WHEN [Patient Satisfaction] <= 5 THEN '2. Dissatisfied (4-5)'
            WHEN [Patient Satisfaction] <= 7 THEN '3. Neutral (6-7)'
            WHEN [Patient Satisfaction] <= 9 THEN '4. Satisfied (8-9)'
            ELSE '5. Very Satisfied (10)'
        END AS satisfaction_category
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
    WHERE [Patient Satisfaction] IS NOT NULL
)
SELECT 
    satisfaction_category,
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_visits,
    
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction_score,
    
    -- Key drivers
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    
    -- Outcomes
    ROUND(100.0 * SUM(CASE WHEN [Patient Outcome] = 'Discharged' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_discharged,
    
    -- Urgency mix
    ROUND(100.0 * SUM(CASE WHEN [Urgency Level] IN ('Critical', 'High') THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_high_urgency
FROM satisfaction_categories
GROUP BY satisfaction_category
ORDER BY satisfaction_category;




-- Q12: HIGH-VOLUME VS LOW-VOLUME PERIOD COMPARISON
-- How do operations differ between peak and off-peak times?

WITH visit_volume_classification AS (
    SELECT 
        [Visit ID],
        [Day of Week],
        [Time of Day],
        [Total Wait Time (min)],
        [Patient Satisfaction],
        [Nurse-to-Patient Ratio],
        [Urgency Level],
        
        CASE 
            WHEN [Day of Week] IN ('Saturday', 'Sunday') AND [Time of Day] = 'Night' THEN 'Low Volume'
            WHEN [Day of Week] IN ('Monday', 'Friday') AND [Time of Day] IN ('Afternoon', 'Evening') THEN 'High Volume'
            ELSE 'Moderate Volume'
        END AS volume_period
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
)
SELECT 
    volume_period,
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 2) AS pct_of_visits,
    
    -- Wait time comparison
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    MIN([Total Wait Time (min)]) AS min_wait,
    MAX([Total Wait Time (min)]) AS max_wait,
    
    -- Staffing comparison
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    
    -- Patient satisfaction
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    -- Urgency distribution
    ROUND(100.0 * SUM(CASE WHEN [Urgency Level] = 'Critical' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_critical
FROM visit_volume_classification
GROUP BY volume_period
ORDER BY 
    CASE volume_period
        WHEN 'Low Volume' THEN 1
        WHEN 'Moderate Volume' THEN 2
        WHEN 'High Volume' THEN 3
    END;




-- Q13: FACILITY SIZE AND OPERATIONAL EFFICIENCY
-- Do larger facilities operate more efficiently?

WITH facility_categories AS (
    SELECT 
        [Hospital Name],
        [Facility Size (Beds)],
        [Total Wait Time (min)],
        [Patient Satisfaction],
        [Nurse-to-Patient Ratio],
        [Visit ID],
        
        CASE 
            WHEN [Facility Size (Beds)] < 100 THEN '1. Small (<100 beds)'
            WHEN [Facility Size (Beds)] < 200 THEN '2. Medium (100-199 beds)'
            WHEN [Facility Size (Beds)] < 300 THEN '3. Large (200-299 beds)'
            ELSE '4. Very Large (300+ beds)'
        END AS facility_size_category
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
    WHERE [Facility Size (Beds)] IS NOT NULL
)
SELECT 
    facility_size_category,
    COUNT(DISTINCT [Hospital Name]) AS num_hospitals,
    COUNT(*) AS total_visits,
    ROUND(AVG(CAST([Facility Size (Beds)] AS FLOAT)), 0) AS avg_bed_count,
    
    -- Efficiency metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_wait_time,
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    ROUND(AVG(CAST([Nurse-to-Patient Ratio] AS FLOAT)), 1) AS avg_nurse_ratio,
    
    -- Visits per bed (utilization proxy)
    ROUND(CAST(COUNT(*) AS FLOAT) / NULLIF(AVG(CAST([Facility Size (Beds)] AS FLOAT)), 0), 2) AS visits_per_bed
FROM facility_categories
GROUP BY facility_size_category
ORDER BY facility_size_category;



-- Q14: CRITICAL PATIENT FAST-TRACK EFFECTIVENESS
-- Are we meeting critical patient wait time targets?

WITH critical_patients AS (
    SELECT 
        [Visit ID],
        [Urgency Level],
        [Time to Medical Professional (min)] AS time_to_doctor,
        [Total Wait Time (min)] AS total_wait,
        [Patient Outcome],
        [Patient Satisfaction],
        
        CASE 
            WHEN [Urgency Level] = 'Critical' AND [Time to Medical Professional (min)] <= 10 THEN 'Met Target (<10 min)'
            WHEN [Urgency Level] = 'Critical' AND [Time to Medical Professional (min)] > 10 THEN 'Missed Target (>10 min)'
            WHEN [Urgency Level] = 'High' AND [Time to Medical Professional (min)] <= 30 THEN 'Met Target (<30 min)'
            WHEN [Urgency Level] = 'High' AND [Time to Medical Professional (min)] > 30 THEN 'Missed Target (>30 min)'
            ELSE 'Standard Care'
        END AS target_performance
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
    WHERE [Urgency Level] IN ('Critical', 'High')
)
SELECT 
    [Urgency Level],
    target_performance,
    
    COUNT(*) AS visits,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(PARTITION BY [Urgency Level]), 2) AS pct_within_urgency_level,
    
    ROUND(AVG(time_to_doctor), 1) AS avg_time_to_doctor,
    MIN(time_to_doctor) AS min_time,
    MAX(time_to_doctor) AS max_time,
    
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction,
    
    ROUND(100.0 * SUM(CASE WHEN [Patient Outcome] = 'Admitted' THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_admitted
FROM critical_patients
GROUP BY [Urgency Level], target_performance
ORDER BY [Urgency Level], target_performance;




-- Q15: OPERATIONAL COST-EFFICIENCY SIMULATION
-- What staffing levels optimize cost vs patient satisfaction?

WITH cost_simulation AS (
    SELECT 
        [Visit ID],
        [Nurse-to-Patient Ratio],
        [Total Wait Time (min)],
        [Patient Satisfaction],
        
        -- Cost assumptions
        [Nurse-to-Patient Ratio] * 50 AS estimated_hourly_nursing_cost,
        
        -- Satisfaction-based revenue (higher satisfaction = better reimbursement)
        CASE 
            WHEN [Patient Satisfaction] >= 9 THEN 1000
            WHEN [Patient Satisfaction] >= 7 THEN 900
            WHEN [Patient Satisfaction] >= 5 THEN 800
            ELSE 700
        END AS estimated_revenue_per_visit
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
    WHERE [Nurse-to-Patient Ratio] IS NOT NULL 
      AND [Patient Satisfaction] IS NOT NULL
      AND [Total Wait Time (min)] >= 0
)
SELECT 
    CASE 
        WHEN [Nurse-to-Patient Ratio] <= 3 THEN '1. Low Staffing (1-3)'
        WHEN [Nurse-to-Patient Ratio] <= 5 THEN '2. Medium Staffing (4-5)'
        WHEN [Nurse-to-Patient Ratio] <= 7 THEN '3. High Staffing (6-7)'
        ELSE '4. Very High Staffing (8+)'
    END AS staffing_level,
    
    COUNT(*) AS visits,
    ROUND(AVG([Nurse-to-Patient Ratio]), 1) AS avg_nurse_ratio,
    ROUND(AVG([Total Wait Time (min)]), 1) AS avg_wait_time,
    ROUND(AVG([Patient Satisfaction]), 2) AS avg_satisfaction,
    
    -- Financial metrics
    ROUND(AVG(estimated_hourly_nursing_cost), 0) AS avg_nursing_cost_per_visit,
    ROUND(AVG(estimated_revenue_per_visit), 0) AS avg_revenue_per_visit,
    ROUND(AVG(estimated_revenue_per_visit - estimated_hourly_nursing_cost), 0) AS avg_net_margin,
    
    -- Total financial impact
    ROUND(SUM(estimated_revenue_per_visit - estimated_hourly_nursing_cost), 0) AS total_net_margin
FROM cost_simulation
GROUP BY 
    CASE 
        WHEN [Nurse-to-Patient Ratio] <= 3 THEN '1. Low Staffing (1-3)'
        WHEN [Nurse-to-Patient Ratio] <= 5 THEN '2. Medium Staffing (4-5)'
        WHEN [Nurse-to-Patient Ratio] <= 7 THEN '3. High Staffing (6-7)'
        ELSE '4. Very High Staffing (8+)'
    END
ORDER BY staffing_level;





-- Q16: FEATURE ENGINEERING FOR PREDICTIVE MODELS
-- What features predict long wait times and low satisfaction?

SELECT 
    [Visit ID],
    [Patient ID],
    
    -- Temporal features
    [Day of Week],
    [Season],
    [Time of Day],
    CASE WHEN [Day of Week] IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END AS weekend_flag,
    CASE WHEN [Time of Day] IN ('Evening', 'Night') THEN 1 ELSE 0 END AS after_hours_flag,
    
    -- Urgency encoding
    [Urgency Level],
    CASE 
        WHEN [Urgency Level] = 'Critical' THEN 4
        WHEN [Urgency Level] = 'High' THEN 3
        WHEN [Urgency Level] = 'Medium' THEN 2
        ELSE 1
    END AS urgency_numeric,
    CASE WHEN [Urgency Level] IN ('Critical', 'High') THEN 1 ELSE 0 END AS high_urgency_flag,
    
    -- Resource features
    [Nurse-to-Patient Ratio],
    [Specialist Availability],
    [Facility Size (Beds)],
    CASE WHEN [Nurse-to-Patient Ratio] < 4 THEN 1 ELSE 0 END AS understaffed_flag,
    CASE WHEN [Specialist Availability] = 0 THEN 1 ELSE 0 END AS no_specialist_flag,
    
    -- Facility features
    CASE WHEN [Facility Size (Beds)] >= 200 THEN 1 ELSE 0 END AS large_facility_flag,
    
    -- Wait time features
    [Time to Registration (min)],
    [Time to Triage (min)],
    [Time to Medical Professional (min)],
    [Total Wait Time (min)],
    CASE WHEN [Total Wait Time (min)] > 60 THEN 1 ELSE 0 END AS excessive_wait_flag,
    
    -- Interaction features
    [Nurse-to-Patient Ratio] * [Facility Size (Beds)] AS staffing_capacity_interaction,
    CASE WHEN [Day of Week] IN ('Monday', 'Friday') AND [Time of Day] = 'Afternoon' THEN 1 ELSE 0 END AS peak_time_flag,
    
    -- Target variables
    [Patient Satisfaction],
    CASE WHEN [Patient Satisfaction] >= 8 THEN 1 ELSE 0 END AS high_satisfaction_label,
    CASE WHEN [Total Wait Time (min)] > 45 THEN 1 ELSE 0 END AS long_wait_label,
    [Patient Outcome]
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$];




-- Q17: ANOMALY DETECTION AND OUTLIER IDENTIFICATION
-- Which visits represent operational anomalies requiring investigation?

WITH wait_statistics AS (
    SELECT 
        AVG(CAST([Total Wait Time (min)] AS FLOAT)) AS mean_wait,
        STDEV(CAST([Total Wait Time (min)] AS FLOAT)) AS std_wait
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
    WHERE [Total Wait Time (min)] >= 0
),
anomaly_detection AS (
    SELECT 
        v.[Visit ID],
        v.[Patient ID],
        v.[Hospital Name],
        v.[Day of Week],
        v.[Time of Day],
        v.[Urgency Level],
        v.[Total Wait Time (min)],
        v.[Patient Satisfaction],
        v.[Nurse-to-Patient Ratio],
        
        -- Z-score calculation
        ROUND((v.[Total Wait Time (min)] - ws.mean_wait) / NULLIF(ws.std_wait, 0), 2) AS wait_time_z_score,
        
        -- Anomaly flags
        CASE WHEN v.[Total Wait Time (min)] > (ws.mean_wait + 3 * ws.std_wait) THEN 1 ELSE 0 END AS extreme_wait_flag,
        CASE WHEN v.[Total Wait Time (min)] < 5 AND v.[Urgency Level] = 'Critical' THEN 1 ELSE 0 END AS suspiciously_fast_flag,
        CASE WHEN v.[Patient Satisfaction] <= 2 AND v.[Total Wait Time (min)] < 30 THEN 1 ELSE 0 END AS low_satisfaction_short_wait_flag,
        CASE WHEN v.[Nurse-to-Patient Ratio] = 0 THEN 1 ELSE 0 END AS zero_staff_flag,
        CASE WHEN v.[Time to Registration (min)] > v.[Total Wait Time (min)] THEN 1 ELSE 0 END AS data_inconsistency_flag
    FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$] v
    CROSS JOIN wait_statistics ws
    WHERE v.[Total Wait Time (min)] >= 0
)
SELECT 
    [Visit ID],
    [Patient ID],
    [Hospital Name],
    [Day of Week],
    [Time of Day],
    [Urgency Level],
    [Total Wait Time (min)],
    wait_time_z_score,
    [Patient Satisfaction],
    
    (extreme_wait_flag + suspiciously_fast_flag + low_satisfaction_short_wait_flag + 
     zero_staff_flag + data_inconsistency_flag) AS total_anomalies,
    
    CASE WHEN extreme_wait_flag = 1 THEN 'Extreme Wait Time, ' ELSE '' END +
    CASE WHEN suspiciously_fast_flag = 1 THEN 'Suspiciously Fast Critical Care, ' ELSE '' END +
    CASE WHEN low_satisfaction_short_wait_flag = 1 THEN 'Low Satisfaction Despite Short Wait, ' ELSE '' END +
    CASE WHEN zero_staff_flag = 1 THEN 'Zero Staffing Recorded, ' ELSE '' END +
    CASE WHEN data_inconsistency_flag = 1 THEN 'Data Inconsistency, ' ELSE '' END AS anomaly_details
FROM anomaly_detection
WHERE (extreme_wait_flag + suspiciously_fast_flag + low_satisfaction_short_wait_flag + 
       zero_staff_flag + data_inconsistency_flag) > 0
ORDER BY total_anomalies DESC, wait_time_z_score DESC;




-- ----------------------------------------------------------------------------
-- Q18: EXECUTIVE OPERATIONS DASHBOARD - COMPREHENSIVE ER METRICS
-- Business Question: Provide hospital leadership with complete ER performance metrics.
-- Skills: Executive reporting, KPI aggregation, operational dashboard
-- ----------------------------------------------------------------------------

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

