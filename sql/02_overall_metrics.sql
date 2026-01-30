-- ============================================================================
-- Q2: OVERALL WAIT TIME METRICS AND BENCHMARKING
-- ============================================================================
-- Business Question: How do our wait times compare to national healthcare benchmarks?
--
-- Purpose: Establish baseline performance and identify competitiveness
-- Skills Demonstrated: Aggregate functions, statistical measures, benchmark comparisons
--
-- National Benchmark: 40 minutes average total ER wait time
-- Expected Output: Single summary row with all wait time statistics
-- ============================================================================

SELECT 
    COUNT(*) AS total_visits,
    
    -- Registration Metrics
    ROUND(AVG(CAST([Time to Registration (min)] AS FLOAT)), 1) AS avg_time_to_registration,
    MIN([Time to Registration (min)]) AS min_time_to_registration,
    MAX([Time to Registration (min)]) AS max_time_to_registration,
    
    -- Triage Metrics
    ROUND(AVG(CAST([Time to Triage (min)] AS FLOAT)), 1) AS avg_time_to_triage,
    
    -- Doctor Wait Metrics
    ROUND(AVG(CAST([Time to Medical Professional (min)] AS FLOAT)), 1) AS avg_time_to_doctor,
    
    -- Total Wait Metrics
    ROUND(AVG(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS avg_total_wait_time,
    ROUND(STDEV(CAST([Total Wait Time (min)] AS FLOAT)), 1) AS std_dev_wait_time,
    
    -- Benchmark Comparison (40 min national average)
    CASE 
        WHEN AVG(CAST([Total Wait Time (min)] AS FLOAT)) < 30 THEN 'Excellent - Below Benchmark'
        WHEN AVG(CAST([Total Wait Time (min)] AS FLOAT)) < 45 THEN 'Good - Near Benchmark'
        ELSE 'Needs Improvement - Above Benchmark'
    END AS performance_vs_benchmark,
    
    -- Patient Satisfaction
    ROUND(AVG(CAST([Patient Satisfaction] AS FLOAT)), 2) AS avg_satisfaction_score
    
FROM [Wait Time & Operations Analysis].dbo.[ER wait Time Dataset$]
WHERE [Total Wait Time (min)] >= 0; -- Exclude any data errors

-- ============================================================================
-- Interpretation Guide:
-- avg_total_wait_time: 
--   <30 min = Excellent | 30-40 min = Good | 40-50 min = Fair | >50 min = Poor
-- avg_satisfaction_score:
--   >8.5 = Excellent | 7.5-8.5 = Good | 6.5-7.5 = Fair | <6.5 = Poor
-- ============================================================================
