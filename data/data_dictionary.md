# Data Dictionary - ER Wait Time Dataset

## Overview
This dataset contains emergency room visit records tracking patient wait times, operational metrics, and outcomes across multiple healthcare facilities.

---

## Table Schema

**Database:** `Wait Time & Operations Analysis`  
**Table:** `ER wait Time Dataset$`  
**Record Type:** Individual ER visit records  
**Granularity:** One row per patient visit  

---

## Field Definitions

### Identifiers

| Field Name | Data Type | Description | Example Values |
|------------|-----------|-------------|----------------|
| `Visit ID` | VARCHAR | Unique identifier for each ER visit | V00001, V00002 |
| `Patient ID` | VARCHAR | Unique patient identifier (can have multiple visits) | P12345, P67890 |
| `Hospital ID` | VARCHAR | Unique facility identifier | H001, H002 |

### Hospital Information

| Field Name | Data Type | Description | Example Values |
|------------|-----------|-------------|----------------|
| `Hospital Name` | VARCHAR | Name of the healthcare facility | City General Hospital |
| `Region` | VARCHAR | Geographic region of the hospital | Northeast, Southwest |
| `Facility Size (Beds)` | INT | Total bed capacity of the hospital | 250, 500, 1000 |

### Wait Time Metrics (in minutes)

| Field Name | Data Type | Description | Business Logic |
|------------|-----------|-------------|----------------|
| `Time to Registration (min)` | INT | Minutes from arrival to registration completion | Time patient waits to check in |
| `Time to Triage (min)` | INT | Minutes from registration to triage assessment | Initial nurse evaluation wait |
| `Time to Medical Professional (min)` | INT | Minutes from arrival to seeing doctor/PA | Critical metric for care access |
| `Total Wait Time (min)` | INT | Total minutes from arrival to treatment start | Primary KPI for patient experience |

**Wait Time Calculation:**

Total Wait Time = Time to Registration + Time to Triage + Time to Medical Professional

**National Benchmarks:**
- Critical cases: ≤10 minutes to medical professional
- High urgency: ≤20 minutes to medical professional  
- Overall average: ≤40 minutes total wait time

### Clinical Information

| Field Name | Data Type | Description | Values |
|------------|-----------|-------------|--------|
| `Urgency Level` | VARCHAR | Clinical urgency classification | Critical, High, Medium, Low |
| `Patient Outcome` | VARCHAR | Disposition after ER visit | Admitted, Discharged, Transferred |

**Urgency Level Definitions:**
- **Critical**: Life-threatening conditions requiring immediate intervention (trauma, cardiac arrest, stroke)
- **High**: Serious conditions requiring urgent care (severe pain, difficulty breathing, major injuries)
- **Medium**: Conditions requiring prompt attention (moderate pain, minor fractures, infections)
- **Low**: Non-urgent conditions (minor injuries, mild symptoms, routine care)

### Operational Metrics

| Field Name | Data Type | Description | Interpretation |
|------------|-----------|-------------|----------------|
| `Nurse-to-Patient Ratio` | DECIMAL | Average number of patients per nurse during visit | Lower = Better (optimal: 1:3 to 1:4) |
| `Specialist Availability` | DECIMAL | Percentage of required specialists on duty | 0-100% (higher = better) |

### Temporal Information

| Field Name | Data Type | Description | Values |
|------------|-----------|-------------|--------|
| `Day of Week` | VARCHAR | Day the visit occurred | Monday, Tuesday, ..., Sunday |
| `Time of Day` | VARCHAR | Time period of arrival | Morning, Afternoon, Evening, Night |

**Time of Day Definitions:**
- **Morning**: 6:00 AM - 12:00 PM
- **Afternoon**: 12:00 PM - 6:00 PM  
- **Evening**: 6:00 PM - 12:00 AM
- **Night**: 12:00 AM - 6:00 AM

### Satisfaction & Quality

| Field Name | Data Type | Description | Scale |
|------------|-----------|-------------|-------|
| `Patient Satisfaction` | INT | Post-visit satisfaction rating | 1-10 (10 = highest) |

**Satisfaction Score Interpretation:**
- 9-10: Promoters (highly satisfied)
- 7-8: Passives (satisfied but not enthusiastic)
- 1-6: Detractors (dissatisfied)

---

## Data Quality Notes

### Completeness
All core fields have >99% completion rate with minimal missing values:
- Wait time fields: Complete for all records
- Operational metrics: ~97% complete
- Satisfaction scores: ~98% complete

### Data Validation Rules
1. `Total Wait Time` must be ≥ 0
2. `Patient Satisfaction` must be between 1-10
3. `Nurse-to-Patient Ratio` should be > 0
4. `Specialist Availability` should be 0-100

### Known Limitations
- Historical data only (no real-time updates)
- Specialist availability is average during shift, not at exact visit time
- Wait times rounded to nearest minute
- Some visits may have data collection gaps due to system issues

---

## Common Analytical Patterns

### Key Performance Indicators (KPIs)
```sql
-- Average Total Wait Time
AVG([Total Wait Time (min)])

-- Critical Patient Response Time  
AVG([Time to Medical Professional (min)]) WHERE [Urgency Level] = 'Critical'

-- Patient Satisfaction Rate
AVG([Patient Satisfaction])

-- High Satisfaction Percentage
(COUNT(*) WHERE [Patient Satisfaction] >= 8) / COUNT(*)
```

### Segmentation Fields
- **By Urgency**: `[Urgency Level]`
- **By Hospital**: `[Hospital ID]` or `[Hospital Name]`
- **By Time**: `[Day of Week]`, `[Time of Day]`
- **By Region**: `[Region]`

---

## Update History

**Last Updated:** November 2025  
**Update Frequency:** Static dataset (historical analysis)  
**Record Count:** ~10,000 ER visits  
**Date Range:** Full fiscal year  

---

*For questions about data definitions or quality issues, refer to the data quality assessment query in `01_data_quality_assessment.sql`*

