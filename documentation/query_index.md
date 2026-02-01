# Query Index - Business Questions Guide

This document maps each SQL query to its business question and key insights, serving as a quick reference guide for the analysis.

---

## Query Organization

Queries are organized into 8 core modules focusing on different aspects of ER operations:

1. **Data Quality** - Ensuring reliable analysis foundation
2. **Overall Performance** - Benchmarking against standards  
3. **Urgency Analysis** - Clinical priority management
4. **Hospital Comparison** - Identifying best/worst performers
5. **Temporal Patterns** - Understanding demand cycles
6. **Resource Optimization** - Staffing and allocation efficiency
7. **Patient Satisfaction** - Experience and quality drivers
8. **Executive Dashboard** - Leadership-level KPIs

---

## Complete Query Catalog

### Module 1: Data Quality Assessment
**File:** `01_data_quality_assessment.sql`

**Business Question:**  
*"Is our ER tracking system capturing complete and accurate data?"*

**What It Analyzes:**
- Total visit volume and unique counts (visits, patients, hospitals)
- Missing data by field (completeness checks)
- Data integrity issues (negative values, invalid ranges)
- Duplicate record detection

**Key Metrics:**
- `total_visits`, `unique_patients`, `unique_hospitals`
- `missing_*` counts for each field
- `negative_wait_times`, `invalid_satisfaction_scores`

**Why It Matters:**  
Poor data quality undermines all downstream analysis. This query validates we have a reliable foundation before making business decisions.

**Expected Output:**  
Single row showing data completeness statistics. Ideally:
- 0 missing values in critical fields
- 0 data integrity violations
- 100% unique visit IDs

**When to Run:**
- Before any new analysis cycle
- After system upgrades or changes
- Monthly as part of quality monitoring
- When data anomalies are suspected

**Red Flags to Watch:**
- >5% missing data in any field
- Any negative wait times (data error)
- Invalid satisfaction scores (outside 1-10 range)
- Duplicate visit IDs

---

### Module 2: Overall Metrics & Benchmarking
**File:** `02_overall_metrics.sql`

**Business Question:**  
*"How do our ER wait times compare to national healthcare benchmarks?"*

**What It Analyzes:**
- Average wait times across all stages (registration, triage, doctor)
- Total wait time statistics (mean, std dev, min/max)
- Performance vs. 40-minute national benchmark
- Overall patient satisfaction

**Key Metrics:**
- `avg_total_wait_time` (benchmark: <40 min)
- `avg_time_to_doctor` (critical metric)
- `performance_vs_benchmark` (categorical rating)
- `avg_satisfaction_score`
- `std_dev_wait_time` (variability indicator)

**Why It Matters:**  
Establishes baseline performance and identifies whether we're competitive with peer institutions. Critical for board reporting and strategic planning.

**Expected Output:**  
Single summary row with all aggregate metrics and benchmark comparison.

**When to Run:**
- Monthly for executive reporting
- Before board meetings
- When comparing quarters or years
- For external reporting requirements

**Interpretation Guide:**
- **Excellent**: <30 min average (top quartile)
- **Good**: 30-40 min (meeting benchmark)
- **Fair**: 40-50 min (below benchmark)
- **Poor**: >50 min (intervention needed)

---

### Module 3: Urgency Level Analysis
**File:** `03_urgency_analysis.sql`

**Business Question:**  
*"Are we appropriately prioritizing critical patients over less urgent cases?"*

**What It Analyzes:**
- Visit distribution by urgency level (Critical, High, Medium, Low)
- Wait times segmented by urgency
- Patient satisfaction by urgency
- Admission rates by urgency (outcome indicator)

**Key Metrics:**
- `pct_of_visits` by urgency level
- `avg_time_to_doctor` by urgency (Critical should be <10 min)
- `avg_satisfaction` by urgency
- `pct_admitted` (higher urgency should have higher admission %)

**Why It Matters:**  
**This is a patient safety critical analysis.** Long waits for critical patients can lead to adverse outcomes, malpractice risk, and regulatory violations.

**Expected Output:**  
4 rows (one per urgency level) ordered Critical → High → Medium → Low with wait time and outcome metrics.

**When to Run:**
- Weekly for clinical quality monitoring
- After any critical incident
- Monthly for safety committee review
- When evaluating triage protocols

**Red Flags to Watch:**
- Critical patients waiting >10 minutes to see doctor
- Low urgency patients being seen faster than high urgency
- Critical patients with low satisfaction scores
- High urgency with low admission rates (possible under-triage)

**Regulatory Compliance:**
- CMS requires <10 min for life-threatening conditions
- Joint Commission monitors these metrics
- State health departments track critical care response

---

### Module 4: Hospital & Regional Performance
**File:** `04_hospital_performance.sql`

**Business Question:**  
*"Which hospitals/regions are performing well, and which need operational improvement?"*

**What It Analyzes:**
- Wait time performance by hospital
- Patient satisfaction by facility
- Operational metrics (nurse ratios, specialist availability) by hospital
- Performance rankings (best to worst)

**Key Metrics:**
- `avg_wait_time` by hospital
- `avg_satisfaction` by hospital
- `avg_nurse_ratio`, `avg_specialist_availability`
- `wait_time_rank_best_to_worst`, `satisfaction_rank`
- `facility_size` (context for performance)

**Why It Matters:**  
Identifies best-practice facilities to learn from and struggling facilities that need intervention. Supports resource allocation decisions and performance improvement initiatives.

**Expected Output:**  
One row per hospital (15-20 rows) ranked by wait time performance with all key operational metrics.

**When to Run:**
- Monthly for network performance review
- Quarterly for strategic planning
- Before resource allocation decisions
- When identifying improvement targets

**Actionable Insights:**
- Top 3 hospitals = best practice models to study
- Bottom 3 hospitals = immediate intervention targets
- Correlation between staffing and performance
- Regional patterns requiring system-level solutions

**Analysis Techniques:**
1. Compare top vs bottom performers for patterns
2. Correlate operational metrics with outcomes
3. Identify facility size impact on performance
4. Regional grouping for peer comparisons

---

### Module 5: Temporal Patterns - Day of Week
**File:** `05_temporal_patterns.sql` (Part 1: Day Analysis)

**Business Question:**  
*"Which days of the week have the highest patient volume and longest wait times?"*

**What It Analyzes:**
- Visit volume distribution across weekdays
- Wait time metrics by day of week
- Staffing levels by day (nurse ratios)
- High-urgency case volume by day

**Key Metrics:**
- `visits` and `pct_of_total_visits` by day
- `avg_wait_time` by day
- `avg_nurse_ratio` by day
- `high_urgency_visits` by day
- `avg_satisfaction` by day

**Why It Matters:**  
Identifies need for **dynamic staffing models** rather than uniform weekday scheduling. Reveals whether staffing levels match demand patterns.

**Expected Output:**  
7 rows (Monday-Sunday) with volume and wait time patterns.

**When to Run:**
- Monthly for staffing optimization
- Before creating new schedules
- When evaluating weekend staffing
- During budgeting for FTE planning

**Optimization Opportunity:**
If Monday has 23% higher volume but same staffing as Sunday, we have a clear inefficiency to address.

**Staffing Recommendations:**
- Identify highest volume day (likely Monday or Friday)
- Calculate required FTE increase for high-volume days
- Consider flex staffing or "surge teams"
- Adjust shift start times based on arrival patterns

---

### Module 6: Temporal Patterns - Time of Day
**File:** `05_temporal_patterns.sql` (Part 2: Time Analysis)

**Business Question:**  
*"When should we schedule maximum staff to handle peak demand periods?"*

**What It Analyzes:**
- Visit volume by time of day (Morning, Afternoon, Evening, Night)
- Wait times by time period
- Critical case percentage by time
- Satisfaction scores by time period

**Key Metrics:**
- `pct_of_visits` by time period
- `avg_total_wait` by time period
- `pct_critical`, `pct_high_urgency` by time
- `avg_nurse_ratio` by time
- `avg_satisfaction` by time

**Why It Matters:**  
Enables shift scheduling optimization. Ensures adequate staffing during actual peak hours rather than assumed peaks.

**Expected Output:**  
4 rows (one per time period) with demand and staffing metrics.

**When to Run:**
- During shift schedule creation
- When evaluating shift handoff times
- Monthly for operational review
- Before implementing shift changes

**Shift Optimization Strategies:**
1. Identify peak volume periods
2. Calculate staffing gap during peaks
3. Consider overlapping shifts during high-volume times
4. Evaluate split shifts for coverage

**Time Period Definitions:**
- Morning: 6 AM - 12 PM (often peak arrival time)
- Afternoon: 12 PM - 6 PM (moderate volume)
- Evening: 6 PM - 12 AM (secondary peak)
- Night: 12 AM - 6 AM (lowest volume, highest acuity)

---

### Module 7: Resource Optimization - Nurse Staffing
**File:** `06_resource_optimization.sql` (Part 1)

**Business Question:**  
*"How do nurse staffing levels impact wait times and patient satisfaction?"*

**What It Analyzes:**
- Correlation between nurse-to-patient ratios and wait times
- Impact on patient satisfaction
- Performance metrics at different staffing levels
- Optimal staffing level identification

**Key Metrics:**
- `nurse_ratio` vs. `avg_wait_time` (correlation)
- `nurse_ratio` vs. `avg_satisfaction`
- `pct_high_satisfaction` by staffing level
- Performance buckets (Optimal, Adequate, Strained, Critical)

**Why It Matters:**  
**Directly links resource investment to performance outcomes.** Provides evidence for staffing budget requests and helps optimize labor costs.

**Expected Output:**  
Multiple rows showing performance metrics at different staffing level buckets (e.g., 1:3, 1:4, 1:5).

**When to Run:**
- Before budget planning cycles
- When justifying staffing increases
- During operational efficiency reviews
- For business case development

**Business Case Value:**  
Quantifies ROI of adding nurses: "Each nurse added (improving ratio from 1:5 to 1:4) reduces wait by 5 min and increases satisfaction by 0.6 points."

**Key Findings to Extract:**
1. Optimal staffing ratio (point of diminishing returns)
2. Cost per minute of wait time reduction
3. Satisfaction improvement per staffing dollar
4. Safety threshold ratio (below which quality suffers)

---

### Module 8: Resource Optimization - Specialist Availability
**File:** `06_resource_optimization.sql` (Part 2)

**Business Question:**  
*"What's the relationship between specialist availability and patient outcomes for high-urgency cases?"*

**What It Analyzes:**
- Impact of specialist availability on wait times
- Effect on high-urgency patient care
- Admission rates by specialist availability
- Performance at different availability levels

**Key Metrics:**
- `specialist_availability` vs. `avg_time_to_doctor`
- Impact on critical and high urgency wait times
- `pct_admitted` by availability level
- Performance buckets (Well Staffed, Adequate, Understaffed, Severe)

**Why It Matters:**  
Specialist bottlenecks disproportionately affect high-acuity patients. This analysis identifies the minimum acceptable specialist coverage.

**Expected Output:**  
Rows showing performance at different specialist availability levels (60-100%, 40-59%, 20-39%, 0-19%).

**When to Run:**
- When evaluating on-call coverage
- Before specialist hiring decisions
- During contract negotiations
- For capacity planning

**Critical Thresholds:**
- **60%+ availability**: Optimal performance
- **40-59%**: Adequate but strained
- **20-39%**: Significant delays for complex cases
- **<20%**: Critical shortage, safety risk

**Specialist Coverage Solutions:**
1. On-call rotations to maintain minimum coverage
2. Telemedicine specialist consultations
3. Mid-level providers (PAs, NPs) for initial assessment
4. Inter-hospital specialist sharing agreements

---

### Module 9: Resource Optimization - Combined Impact
**File:** `06_resource_optimization.sql` (Part 3)

**Business Question:**  
*"What's the combined impact of nurse staffing AND specialist availability on overall performance?"*

**What It Analyzes:**
- Combined resource adequacy classification
- Interactive effects of multiple resource types
- Optimal resource combinations
- Performance under different resource scenarios

**Key Metrics:**
- Combined resource level (Well/Adequately/Partially/Under Resourced)
- `avg_wait_time` by resource level
- `avg_satisfaction` by resource level
- `avg_critical_time_to_doctor` by resource level

**Why It Matters:**  
Shows that **both** resources matter - you can't compensate for low specialist availability with just more nurses (or vice versa).

**Expected Output:**  
Rows showing performance for different combinations of nurse ratios and specialist availability.

**When to Run:**
- Strategic resource planning
- Budget prioritization decisions
- When resources are constrained
- Trade-off analysis

**Resource Allocation Strategies:**
1. Prioritize the limiting factor (biggest bottleneck)
2. Balance improvements across both dimensions
3. Calculate marginal benefit of each resource type
4. Identify minimum acceptable threshold for each

---

### Module 10: Patient Satisfaction - NPS Analysis
**File:** `07_patient_satisfaction.sql` (Part 1)

**Business Question:**  
*"What percentage of our patients are promoters vs. detractors, and what characterizes each group?"*

**What It Analyzes:**
- Satisfaction distribution (Promoters 9-10, Passives 7-8, Detractors 1-6)
- Net Promoter Score calculation
- Characteristics of each satisfaction segment
- Operational differences between groups

**Key Metrics:**
- `pct_of_visits` in each satisfaction category
- `avg_wait_time` by satisfaction level
- `avg_nurse_ratio` by satisfaction level
- `pct_admitted` by satisfaction level

**Why It Matters:**  
NPS is a powerful predictor of patient loyalty, referrals, and online reviews. Understanding what drives promoters vs. detractors enables targeted improvements.

**Expected Output:**  
3 rows (Promoters, Passives, Detractors) with demographic and operational characteristics.

**When to Run:**
- Monthly for patient experience tracking
- Before patient experience initiatives
- After implementing satisfaction improvements
- For HCAHPS score analysis

**NPS Calculation:**
```
NPS = % Promoters - % Detractors
```

**NPS Benchmarks:**
- >50: Excellent (world-class)
- 30-50: Good (above average)
- 10-30: Fair (needs improvement)
- <10: Poor (urgent action needed)

**Actionable Insights:**
- What do promoters experience differently?
- Can we move passives to promoters with small changes?
- What frustrates detractors most?
- ROI of converting detractors to promoters

---

### Module 11: Patient Satisfaction - Wait Time Impact
**File:** `07_patient_satisfaction.sql` (Part 2)

**Business Question:**  
*"How does wait time affect patient satisfaction, and what are the satisfaction tipping points?"*

**What It Analyzes:**
- Satisfaction by wait time buckets (0-20, 21-30, 31-40, 41-60, 60+ minutes)
- Degradation of satisfaction as wait time increases
- Threshold identification for satisfaction drop-offs

**Key Metrics:**
- `avg_satisfaction` by wait time bucket
- `pct_high_satisfaction` by bucket
- Wait time thresholds for satisfaction changes

**Why It Matters:**  
Identifies how much wait time reduction is needed to meaningfully improve satisfaction. Shows diminishing returns of wait time improvements.

**Expected Output:**  
5 rows (one per wait time bucket) showing satisfaction degradation.

**When to Run:**
- Setting wait time targets
- Evaluating wait time reduction ROI
- Patient experience improvement planning
- Quality improvement initiatives

**Key Questions Answered:**
1. At what wait time does satisfaction drop significantly?
2. What wait time achieves 80%+ high satisfaction?
3. Is there a "good enough" threshold?
4. Do satisfaction gains plateau at very short waits?

**Typical Findings:**
- 0-20 min: 9.0+ satisfaction (excellent)
- 21-30 min: 8.5 satisfaction (very good)
- 31-40 min: 7.8 satisfaction (good)
- 41-60 min: 6.8 satisfaction (fair)
- 60+ min: 5.5 satisfaction (poor)

---

### Module 12: Patient Satisfaction - Urgency & Outcome Impact
**File:** `07_patient_satisfaction.sql` (Part 3)

**Business Question:**  
*"How does urgency level and patient outcome affect satisfaction?"*

**What It Analyzes:**
- Satisfaction by urgency level and outcome combination
- Expected satisfaction patterns
- Anomalies (low satisfaction despite good care)

**Key Metrics:**
- `avg_satisfaction` by urgency × outcome
- `min_satisfaction`, `max_satisfaction` (range)
- `avg_wait_time` for context

**Why It Matters:**  
Critical patients may have lower satisfaction despite appropriate care (due to severity). Admitted patients typically have lower satisfaction than discharged. Understanding these patterns prevents misinterpretation of scores.

**Expected Output:**  
Multiple rows showing all combinations of urgency levels and outcomes.

**When to Run:**
- Interpreting satisfaction survey results
- Explaining satisfaction variations
- Setting realistic satisfaction targets
- Identifying true quality issues

**Expected Patterns:**
- Critical + Admitted: Lowest satisfaction (severe illness, anxious)
- Low + Discharged: Highest satisfaction (minor issue resolved)
- High + Admitted: Mid-range (appropriate care, but concerning)

**Red Flags:**
- Low urgency + Discharged with low satisfaction (process issue)
- Critical + Admitted with very low satisfaction (possible care quality concern)
- Any outcome with satisfaction <5 (investigate immediately)

---

### Module 13: Patient Satisfaction - Temporal Patterns
**File:** `07_patient_satisfaction.sql` (Part 4)

**Business Question:**  
*"When (day/time) do patients have the best and worst experiences?"*

**What It Analyzes:**
- Satisfaction by day of week and time of day
- Operational context (wait times, staffing) for low-satisfaction periods
- Best and worst performing time periods

**Key Metrics:**
- `avg_satisfaction` by day × time
- `pct_high_satisfaction` by day × time
- `avg_wait_time` for context
- `avg_nurse_ratio` for context

**Why It Matters:**  
Identifies when patients have poor experiences, enabling targeted interventions during specific periods.

**Expected Output:**  
Multiple rows showing satisfaction for all day/time combinations, sorted by satisfaction.

**When to Run:**
- Identifying satisfaction improvement targets
- Explaining satisfaction score fluctuations
- Staffing optimization for satisfaction
- Quality improvement planning

**Typical Patterns:**
- Monday mornings: Lower satisfaction (high volume, long waits)
- Weekend nights: Higher satisfaction (lower volume, shorter waits)
- Friday afternoons: Variable (depends on staffing)

**Intervention Strategies:**
- Target lowest satisfaction periods with extra resources
- Implement communication protocols during high-stress times
- Deploy patient experience specialists during known problem periods

---

### Module 14: Executive Dashboard
**File:** `08_executive_dashboard.sql`

**Business Question:**  
*"Provide hospital leadership with a comprehensive one-page view of ER performance."*

**What It Analyzes:**
- All critical KPIs in single report
- Volume, wait time, satisfaction, clinical, staffing metrics
- Performance targets and benchmarks
- Operational insights (busiest days, best/worst hospitals)

**Key Metrics:**
- Total visits, unique patients, hospitals
- All wait time KPIs (registration, triage, doctor, total)
- Satisfaction scores and high satisfaction rate
- Urgency mix and admission rates
- Staffing levels (nurses, specialists)
- Performance comparisons (best/worst hospitals)

**Why It Matters:**  
**Executive-level decision support.** Single view for board meetings, monthly reviews, strategic planning sessions. Ensures leadership has finger on the pulse of ER operations.

**Expected Output:**  
Formatted report with clear sections and labeled metrics (designed for easy reading by non-technical executives).

**When to Run:**
- Monthly for executive team meetings
- Quarterly for board presentations
- Before strategic planning sessions
- For regulatory reporting

**Intended Audience:**
- Chief Medical Officer
- Hospital Administrator
- Board of Directors
- Quality Improvement Committee
- Senior Leadership Team

**Report Sections:**
1. **Volume Metrics**: How many patients are we serving?
2. **Wait Time Performance**: Are we meeting benchmarks?
3. **Patient Satisfaction**: How are patients rating us?
4. **Clinical Metrics**: What's our patient mix and outcomes?
5. **Staffing Metrics**: Are we appropriately resourced?
6. **Operational Insights**: What are key operational facts?

**Monthly Talking Points:**
- YoY growth in volume
- Progress toward wait time targets
- Satisfaction score trends
- Critical patient compliance rate
- Staffing adequacy assessment
- Top priorities for next month

---

##  Recommended Query Execution Order

### First-Time Analysis (Complete Assessment)
1. **01_data_quality_assessment** - Verify data before proceeding 
2. **02_overall_metrics** - Establish baseline 
3. **03_urgency_analysis** - Identify safety issues (most critical) 
4. **04_hospital_performance** - Find outliers 
5. **05_temporal_patterns** - Understand demand cycles 
6. **06_resource_optimization** - Link resources to outcomes 
7. **07_patient_satisfaction** - Understand experience drivers 
8. **08_executive_dashboard** - Compile findings 

**Time Required:** 2-3 hours for complete first analysis

### Monthly Monitoring (Quick Check)
Run in this order for ongoing tracking:
1. **08_executive_dashboard** - High-level check (5 min)
2. **03_urgency_analysis** - Safety monitoring (5 min)
3. **04_hospital_performance** - Performance tracking (5 min)
4. (Run others as needed for deep dives)

**Time Required:** 15-30 minutes for monthly check

### Quarterly Strategic Reviews (Comprehensive)
Full suite analysis to identify trends and new opportunities:
- Run all queries in order
- Compare results to previous quarter
- Calculate quarter-over-quarter changes
- Update recommendations based on improvements
- Present findings to leadership

**Time Required:** Half-day analysis session

### Ad-Hoc Investigations
When specific issues arise:
- **Patient complaint surge**: Run satisfaction queries (07)
- **Critical incident**: Run urgency analysis (03)
- **Staffing decision**: Run resource optimization (06)
- **Budget planning**: Run hospital performance (04) + resource optimization (06)

---

##  Output Interpretation Guide

### Data Quality (Query 01)
 **Good:** <1% missing data, 0 integrity violations  
 **Acceptable:** 1-5% missing in non-critical fields  
 **Poor:** >5% missing or any integrity violations → Stop and fix data

### Wait Time Benchmarks (Query 02)
 **Excellent:** <30 min average  
 **Good:** 30-40 min average (meets benchmark)  
 **Needs Improvement:** 40-50 min  
 **Poor:** >50 min average

### Urgency Performance (Query 03)
 **Safe:** >90% of critical patients seen in <10 min  
 **Marginal:** 75-90% compliance  
 **Unsafe:** <75% compliance (patient safety risk)

### Hospital Rankings (Query 04)
- Focus on hospitals in bottom quartile (25%)
- Investigate hospitals with >50% gap vs. best performer
- Look for patterns in top performers to replicate
- Consider facility size when comparing

### Satisfaction Scores (Query 07)
 **Excellent:** >8.5/10 average  
 **Good:** 7.5-8.5/10  
 **Needs Work:** 6.5-7.5/10  
 **Poor:** <6.5/10 (reputation risk)

### NPS Interpretation
- **Promoters (9-10)**: Loyal advocates, will refer others
- **Passives (7-8)**: Satisfied but unenthusiastic
- **Detractors (1-6)**: Unhappy, may leave negative reviews

**NPS Formula:** % Promoters - % Detractors
- >50: World-class
- 30-50: Good
- 10-30: Average
- <10: Poor

---

## Using This Analysis for Decision-Making

### For Hospital Administrators
**Primary Queries:** 02, 04, 08  
**Key Questions:**
- Are we competitive with peers?
- Which facilities need resources?
- What's our overall performance trend?
- How do we justify budget requests?

**Monthly Focus:**
- Executive dashboard review
- Hospital performance comparison
- Budget variance analysis
- Strategic initiative tracking

### For ER Medical Directors
**Primary Queries:** 03, 05, 06  
**Key Questions:**
- Are we meeting safety standards for critical patients?
- Do we have right staffing at right times?
- What operational changes improve outcomes?
- How can we optimize clinical workflows?

**Weekly Focus:**
- Critical patient response times
- Staffing adequacy assessment
- Peak volume management
- Quality metrics tracking

### For Quality Improvement Teams
**Primary Queries:** 03, 07, Anomaly Detection  
**Key Questions:**
- Where are quality gaps?
- What drives patient satisfaction?
- What are our outlier cases?
- Which interventions have highest ROI?

**Monthly Focus:**
- Satisfaction driver analysis
- Improvement initiative tracking
- Best practice identification
- Measurement and reporting

### For Finance/Operations
**Primary Queries:** 06, 05, 04  
**Key Questions:**
- How can we optimize labor costs?
- What's ROI of adding staff?
- Which inefficiencies cost the most?
- How do we allocate capital investments?

**Monthly Focus:**
- Resource utilization analysis
- Cost per visit tracking
- Staffing efficiency metrics
- Budget performance

### For Nursing Leadership
**Primary Queries:** 06, 05, 03  
**Key Questions:**
- Are nurse staffing levels adequate?
- When do we need additional coverage?
- How does staffing affect outcomes?
- What's the impact of nurse ratios?

**Weekly Focus:**
- Nurse-to-patient ratio monitoring
- Shift coverage adequacy
- Staff satisfaction correlation
- Overtime and burnout indicators

---

## Technical Notes

### Query Performance Tips
- Queries use proper indexing assumptions on ID fields
- CAST to FLOAT ensures accurate decimal averages
- WHERE clauses filter invalid data before aggregation
- Window functions used efficiently for rankings

### Customization Options
Each query can be modified:
- Change time period filters (add WHERE date clauses)
- Adjust benchmark thresholds in CASE statements
- Add additional grouping dimensions
- Export to visualization tools (Tableau, Power BI)
- Modify aggregation levels (daily vs monthly)

### Data Refresh Frequency
Recommended refresh schedule:
- **Daily:** Queries 05, 08 for operational monitoring
- **Weekly:** Queries 03, 04, 07 for management review
- **Monthly:** Full suite for strategic analysis
- **Quarterly:** Comprehensive with trend analysis

### Export and Visualization
Best practices for output:
- Export executive dashboard to PDF for distribution
- Load time series data into visualization tools
- Create automated email reports from query results
- Build interactive dashboards for real-time monitoring

---

## Troubleshooting Common Issues

### Issue: Query Returns No Results
**Possible Causes:**
- Database name incorrect in FROM clause
- Table name changed or missing
- Insufficient permissions
- Empty dataset

**Solutions:**
- Verify database and table names
- Check data exists: `SELECT COUNT(*) FROM table`
- Confirm user permissions
- Check date filters aren't too restrictive

### Issue: Unexpected Values (e.g., Average = 0)
**Possible Causes:**
- NULL values not handled properly
- Division by zero errors
- Data type mismatches
- Recent data quality issues

**Solutions:**
- Use NULLIF in denominators
- Add ISNULL or COALESCE functions
- Verify CAST statements
- Run data quality query first

### Issue: Performance is Slow
**Possible Causes:**
- Large dataset without indexes
- Complex window functions on full table
- Missing WHERE clause filters
- Inefficient JOINs

**Solutions:**
- Add indexes on key fields (Visit ID, Hospital ID, dates)
- Use WHERE clauses to limit data volume
- Consider creating summary tables
- Run during off-peak hours

### Issue: Results Don't Match Expectations
**Possible Causes:**
- Misunderstanding business logic
- Data changed since last run
- Filters excluding relevant data
- Aggregation level incorrect

**Solutions:**
- Review query comments for business logic
- Check data quality assessment results
- Verify WHERE clause filters
- Compare to previous results for trends

---

## Questions & Support

### For Technical Questions
- SQL syntax issues: Review query comments
- Performance problems: See troubleshooting section above
- Data issues: Run 01_data_quality_assessment.sql first

### For Business Questions
- Interpreting results: See "Output Interpretation Guide" section
- Decision-making: See "Using This Analysis" section
- Prioritization: Focus on patient safety (Query 03) first

### For Additional Analysis
If you need analysis not covered by these queries:
- Modify existing queries with your criteria
- Combine multiple queries for complex questions
- Request custom queries from analytics team

---

## Version History & Updates

**Version 1.0** (January 2025)
- Initial query suite created
- 8 core modules implemented
- Documentation completed

**Planned Enhancements:**
- Predictive wait time forecasting queries
- Patient flow simulation queries
- Staff scheduling optimization queries
- Real-time monitoring queries

---

*This query index serves as the technical companion to the business insights in detailed_findings.md. Use together for complete understanding of the ER operations analysis.*

**Last Updated:** January 2025  
**Next Review:** Quarterly  
**Maintained By:** Analytics Team
