# ER-Wait-Time-Analysis
SQL-based operational analysis of Emergency Room wait times, staffing efficiency, and patient satisfaction.
# Emergency Room Wait Time & Operations Analysis

## Business Problem Statement
Emergency Departments (ED) face the constant challenge of balancing patient volume, staffing levels, and care quality. High wait times lead to decreased patient satisfaction and potentially poorer clinical outcomes. This project analyzes ER operational data to identify bottlenecks, evaluate the impact of nurse-to-patient ratios, and benchmark performance against national standards.

## Key Findings
* **Staffing Thresholds:** Identifying the "Adequate" vs "Optimal" nurse-to-patient ratio to minimize wait times without over-inflating costs.
* **Target Performance:** Evaluation of whether "Critical" urgency patients are meeting the 10-minute medical professional assessment target.
* **Temporal Peaks:** Monday and Friday afternoons represent peak volume periods requiring maximum staffing.
* **Bottleneck Identification:** Analysis reveals whether delays are primarily occurring at Registration, Triage, or while waiting for a Doctor.

## Technical Skills Demonstrated
* **Advanced SQL:** Window Functions (`RANK`, `SUM OVER`), Common Table Expressions (CTEs), and complex `CASE` logic.
* **Data Quality Auditing:** Integrity checks for negative time values and invalid satisfaction scores.
* **Business Intelligence:** Creating executive-level dashboards and financial cost-efficiency simulations.
* **Feature Engineering:** Preparing data for predictive modeling (classification labels and flags).

## Repository Structure
* `/sql_queries`: Organized modules for data cleaning, core analysis, and advanced metrics.
* `/docs`: Data dictionary and detailed business insights.

## How to Use
1. The queries are designed for SQL Server (T-SQL).
2. Run the `01_data_audit.sql` first to ensure data quality.
3. Utilize the `04_executive_dashboard.sql` for a summary of all KPIs.
