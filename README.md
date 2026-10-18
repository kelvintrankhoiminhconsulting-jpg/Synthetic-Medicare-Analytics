# Synthetic Medicare Analytics

## Project Overview

This project analyzes CMS Synthetic Medicare Sample 1 data using Python, SQL Server, Power BI, and Tableau to demonstrate an end-to-end healthcare data analytics workflow.

The project covers data profiling, data quality assessment, cleaning and transformation, SQL analysis, data modeling, and interactive dashboard development. Power BI and Tableau were used to visualize beneficiary demographics, geographic distribution, healthcare utilization, and Medicare claims and cost patterns.

**Tools & Technologies:** Python, pandas, SQL Server, T-SQL, Power BI, DAX, Tableau, GitHub

## Business Objectives

- Analyze beneficiary demographics and geographic distribution.
- Explore Medicare carrier, inpatient, outpatient, and prescription drug event data.
- Examine healthcare utilization and associated medical costs.
- Identify and validate data-quality issues, duplicate records, and key relationships.
- Develop interactive dashboards in Power BI and Tableau to communicate analytical findings.

## Data Source

The project uses CMS Synthetic Medicare Sample 1 data, including beneficiary summary files for multiple years, carrier claims, inpatient claims, outpatient claims, and prescription drug event records.

The dataset is synthetic and intended for analytical practice and demonstration. It does not represent actual individual Medicare beneficiaries.

## Project Workflow

### 1. Python — Data Profiling and Quality Assessment

Used Python and pandas to inspect raw CSV files and assess data quality.

- Loaded and inspected multiple healthcare datasets.
- Reviewed row counts, column counts, data types, and missing values.
- Checked for duplicate records and identifier uniqueness.
- Examined date fields and relationships between datasets.
- Identified potential data-quality issues before loading data into SQL Server.

### 2. SQL Server — Data Cleaning, Transformation, and Analysis

Used SQL Server and T-SQL to prepare datasets for analytical reporting.

- Created and maintained cleaned tables.
- Standardized data types and reviewed date fields.
- Validated identifiers and table relationships.
- Organized beneficiary records by year.
- Developed a beneficiary dimension table.
- Performed SQL-based data-quality checks and analytical queries.

### 3. Data Modeling and DAX

Prepared analytical measures and data models for reporting.

- Established relationships between relevant datasets.
- Used dimensional modeling concepts to organize data for analysis.
- Created DAX measures for beneficiary counts and dashboard metrics.
- Used distinct counting to avoid counting the same beneficiary more than once within the selected year.

### 4. Power BI — Interactive Dashboard

Developed an interactive Power BI dashboard to explore Medicare beneficiary and healthcare data.

- Created KPI cards to summarize key metrics.
- Visualized beneficiary distribution by state using a map.
- Compared beneficiary counts across 2008–2010.
- Applied conditional formatting, tooltips, and visual titles.
- Designed dashboard visuals to support clear and intuitive data exploration.

### 5. Tableau — Interactive Data Visualization

Developed a Tableau dashboard using the prepared Medicare data to explore healthcare patterns and communicate findings through interactive visualizations.

- Built charts and visual summaries of key healthcare metrics.
- Used filters and interactive dashboard features to explore the data.
- Presented beneficiary, claims, utilization, and cost-related patterns.
- Applied visual design principles to support analytical storytelling.

## Key Skills Demonstrated

- Python data profiling and manipulation using pandas
- SQL Server and T-SQL data preparation and analysis
- Data cleaning and quality assessment
- Missing-value and duplicate-record checks
- Data type and date validation
- Primary-key and relationship validation concepts
- Dimensional data modeling
- DAX measure development
- Power BI dashboard development
- Tableau dashboard development
- Data visualization and analytical storytelling
- End-to-end data analytics workflow

## Project Structure

```text
Synthetic-Medicare-Analytics/
├── README.md
├── python/
│   └── Python profiling and validation scripts
├── sql/
│   └── SQL cleaning and analysis scripts
├── powerbi/
│   └── Power BI dashboard (.pbix)
├── tableau/
│   └── Tableau workbook or dashboard files
└── screenshots/
    ├── powerbi-dashboard.png
    └── tableau-dashboard.png
```

This is a suggested structure; adjust the file names and folders to match the actual files included in the repository.

## Project Outcome

This project demonstrates a complete healthcare analytics workflow, from raw-data profiling and quality assessment through SQL preparation, DAX measure development, and interactive dashboard reporting.

By combining Python, SQL Server, Power BI, and Tableau, the project showcases practical skills in data preparation, analytical modeling, visualization, and communicating insights from complex healthcare datasets.

## Disclaimer

This is an independent portfolio project using synthetic data for educational and demonstration purposes. The results should not be interpreted as official CMS reporting or as a representation of actual patient outcomes.


