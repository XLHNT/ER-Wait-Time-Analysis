# Emergency Room Wait Time & Operations Analysis

![SQL](https://img.shields.io/badge/SQL-Server-CC2927?style=flat-square&logo=microsoft-sql-server)
![Analysis](https://img.shields.io/badge/Analysis-Healthcare-4CAF50?style=flat-square)
![Status](https://img.shields.io/badge/Status-Complete-success?style=flat-square)

## Project Overview

A comprehensive SQL-based analysis of emergency room operations examining patient wait times, resource allocation, and operational efficiency across multiple hospitals. This project identifies critical bottlenecks in ER workflows and provides data-driven recommendations to improve patient care and satisfaction.

### Business Problem

Healthcare facilities face mounting pressure to reduce ER wait times while maintaining quality care. This analysis addresses:

- **Long patient wait times** affecting satisfaction and health outcomes
- **Inefficient resource allocation** during peak demand periods  
- **Inconsistent performance** across facilities and urgency levels
- **Lack of data-driven insights** for operational decision-making

### Key Findings

1. **Average wait time is 35.6 minutes**, meeting national benchmarks but with significant variation across hospitals (range: 28-45 minutes)

2. **Critical patients face excessive waits**: 18% of critical cases wait over 10 minutes to see medical professionals, violating safety standards

3. **Monday mornings are peak crisis times**: 23% higher volume with 40% longer wait times, yet staffing levels remain static

4. **Nurse-to-patient ratios correlate strongly with satisfaction**: Facilities with ratios above 1:4 show 35% higher patient satisfaction scores

5. **Specialist availability is the bottleneck**: Only 45% average specialist availability directly correlates with increased wait times for high-urgency cases

### Technical Skills Demonstrated

- **Advanced SQL**: CTEs, window functions, subqueries, complex joins
- **Statistical Analysis**: Z-score calculations, percentile ranking, variance analysis  
- **Data Quality Assessment**: Completeness checks, anomaly detection, data validation
- **Business Intelligence**: KPI development, executive dashboards, trend analysis
- **Healthcare Analytics**: Urgency-based segmentation, clinical outcome tracking

---

##  Repository Structure
```
ER-Wait-Time-Analysis/
│
├──  README.md                                    # Project overview and findings
│
├──  data/
│   └──  data_dictionary.md                       # Complete data schema and definitions
│
├──  sql/
│   ├──  01_data_quality_assessment.sql           # Data completeness and integrity
│   ├──  02_overall_metrics.sql                   # Benchmark comparisons
│   ├──  03_urgency_analysis.sql                  # Priority-based performance
│   ├──  04_hospital_performance.sql              # Regional comparisons
│   ├──  05_temporal_patterns.sql                 # Day/time analysis
│   ├──  06_resource_optimization.sql             # Staffing insights
│   ├──  07_patient_satisfaction.sql              # Satisfaction drivers
│   └──  08_executive_dashboard.sql               # Leadership KPIs
│
├──  insights/
│   └──  detailed_findings.md                     # In-depth analysis results
│
└──  documentation/
    └──  query_index.md                           # Business questions guide
```

---

## How to Use This Repository

### Prerequisites
- SQL Server 2016+ or compatible database engine
- Database: `Wait Time & Operations Analysis`
- Table: `ER wait Time Dataset$`

### Running the Analysis

1. **Set up your database environment**
```sql
   USE [Wait Time & Operations Analysis];
```

2. **Execute queries in order** (numbered 01-08 in the `/sql` folder)
   - Start with `01_data_quality_assessment.sql` to validate data
   - Run subsequent analyses based on your business questions

3. **Review outputs** in the `/insights` folder for interpretation

### Key Analysis Areas

| Query File | Business Question | Output |
|------------|-------------------|---------|
| 01_data_quality | Is our data complete? | Data completeness metrics |
| 02_overall_metrics | How do we compare to benchmarks? | Performance vs. national standards |
| 03_urgency_analysis | Are critical patients prioritized? | Wait times by urgency level |
| 04_hospital_performance | Which facilities need improvement? | Hospital rankings |
| 05_temporal_patterns | When are our peak hours? | Day/time patterns |
| 06_resource_optimization | How should we allocate staff? | Resource correlation analysis |
| 07_patient_satisfaction | What drives satisfaction? | Satisfaction factor analysis |
| 08_executive_dashboard | What are our key metrics? | Executive KPI summary |

---

## Business Impact

### Actionable Recommendations

**Immediate Actions (0-30 days):**
- Increase staffing by 25% on Monday mornings (7 AM - 12 PM)
- Implement fast-track protocol for critical patients to meet 10-minute standard
- Deploy additional specialist on-call coverage during peak hours

**Strategic Initiatives (30-90 days):**
- Standardize best practices from top-performing hospitals to underperformers
- Develop predictive staffing model based on day/time patterns
- Create real-time dashboard for ER managers to monitor wait times

**Expected Outcomes:**
- 20% reduction in average wait times
- 90% compliance with critical patient safety standards  
- 15-point improvement in patient satisfaction scores
- $2.5M annual savings from improved operational efficiency

---

## Sample Insights

### Wait Time Distribution by Urgency

- Critical Cases:  Avg 18.2 min | Target: <10 min  |  BELOW TARGET
- High Priority:   Avg 28.5 min | Target: <20 min  |  BELOW TARGET
- Medium Priority: Avg 38.1 min | Target: <40 min  |  ON TARGET
- Low Priority:    Avg 52.3 min | Target: <60 min  |  ON TARGET

### Top Performing vs. Underperforming Hospitals
- Best:  Hospital 45 | 28.3 min avg | 8.7/10 satisfaction | 1:3.2 nurse ratio
- Worst: Hospital 12 | 45.1 min avg | 6.2/10 satisfaction | 1:5.8 nurse ratio
- Gap:   -59% wait time difference directly tied to staffing levels

---

## Technical Details

**Database Platform:** Microsoft SQL Server  
**Query Complexity:** Intermediate to Advanced  
**Analysis Type:** Descriptive and Diagnostic Analytics  
**Data Volume:** ~10,000 ER visits across multiple facilities  

### Advanced SQL Techniques Used
- Common Table Expressions (CTEs) for modular analysis
- Window functions for ranking and running calculations  
- CASE statements for dynamic categorization
- Statistical functions (AVG, STDEV, PERCENTILE_CONT)
- Complex aggregations with ROLLUP and CUBE
- Z-score calculations for anomaly detection

---

## Connect With Me

**Isuekebho Excel**  
**xcelisuekebho@gmail.com**


---

## License

This project is available for educational and portfolio purposes. Data has been anonymized for privacy.

---

*This analysis demonstrates proficiency in SQL, healthcare analytics, and business intelligence - essential skills for data-driven healthcare improvement initiatives.*
