# Jio-Inspired Customer Churn & Retention — Business Analysis Case Study

**Portfolio project by Shruti Thacker** · Business Analysis · SQL Server · Requirements Engineering

> **Important disclosure:** This is an independent, hypothetical portfolio case study inspired by the scale and subscription context of India's telecom/digital-services market. It is **not affiliated with, commissioned by, endorsed by, or based on internal data from Reliance Jio or any Jio group company**. All customer and event records are synthetic. “Jio-inspired” describes the scenario only; it must not be presented as employment or client work.

## Project overview

A fictional subscription business wants to understand customer churn and design a more consistent retention workflow. The case study uses SQL Server queries to explore a synthetic customer table and related support/payment events, then translates the analysis into draft business requirements, user stories, decision rules, KPIs, and UAT scenarios.

The work demonstrates how a Business Analyst can connect data discovery with requirements and process design. It does not claim that a live retention engine was deployed or that proposed interventions generated financial savings.

## Business question

Which customer and service signals are associated with churn in the sample, and what requirements should a hypothetical retention team consider before designing a proactive process?

## Dataset and verified profile

- Customer/subscription records: **3,000**
- Support and payment event records: **4,118**
- Customer records marked churned: **632**
- Churn share in this synthetic snapshot: **21.07%**
- Total annualized revenue represented by the customer table: **₹20,868,000**
- Annualized revenue associated with records marked churned: **₹4,332,816**
- Missing cells in both CSVs: **0**
- Duplicate full rows in both CSVs: **0**

These values describe the supplied synthetic dataset only. The ARR fields are annualized values, not audited revenue or a forecast of recoverable revenue. Churned ARR is not equivalent to cash loss or achievable savings.

## Deliverables

| Folder | Contents |
|---|---|
| `01_BRD_and_SQL_Discovery` | Draft BRD and discovery summary |
| `02_Stakeholder_Analysis_and_KPI_Catalog` | Stakeholder personas and KPI definitions |
| `03_Process_Maps_AsIs_vs_ToBe` | Proposed current/future-state process illustration |
| `04_Database_Datasets_3000_Records_INR` | Synthetic customer and event CSV files |
| `05_SQL_Server_Scripts_and_BA_Queries` | SQL Server schema, discovery queries, and proposed retention queue view |
| `06_Retention_Decision_Rules_and_ROI_Analysis` | Exploratory findings and proposed business rules |
| `07_Agile_User_Stories_RTM_and_UAT_Workbook` | User stories, traceability, and UAT test scenarios |

## Suggested workflow

1. Review the data dictionary/column names in the CSV files.
2. Open SQL Server Management Studio (SSMS).
3. Run `01_Create_Database_and_Tables.sql` in a **test/development SQL Server instance**. **Warning:** the script drops and recreates project tables, so do not run it against a database containing data you need.
4. Import the two CSVs using the column order/types defined in the script.
5. Run `02_BA_Root_Cause_Discovery_Queries.sql` query by query and compare the results with the workbook.
6. Run `03_Proactive_Retention_Decision_Engine.sql` after the tables are loaded.
7. Validate each query in your environment and record actual results before changing any UAT status from `Not Run`.

## Key analysis cautions

- This is a synthetic, cross-sectional dataset; it is not evidence of causation.
- A customer-level churn flag and a support-event table do not by themselves prove that a ticket caused churn.
- The stored risk score is provided in the sample; this project does not train or validate a predictive model.
- Proposed save rates, targets, credits, discounts, messaging channels, and response SLAs are hypotheses requiring stakeholder approval, cost modelling, legal/privacy review, and controlled testing.
- No real-world ROI or post-implementation improvement is claimed.
- The SQL view creates a prioritised queue from existing scores; it does not calculate a new predictive score or send messages to customers.

## Business analysis artefacts

- Business problem, scope, assumptions, dependencies, and constraints
- Stakeholder personas and KPI catalogue
- As-Is / To-Be process proposal
- Functional requirements and business rules
- Agile user stories with acceptance criteria
- Requirements traceability matrix (RTM)
- UAT scenarios (not executed)

## Tools

- Microsoft SQL Server / T-SQL
- Microsoft Excel
- Microsoft Word
- CSV datasets

## Repository structure

```text
jio-inspired-customer-churn-retention-case-study/
├── README.md
├── 01_BRD_and_SQL_Discovery/
├── 02_Stakeholder_Analysis_and_KPI_Catalog/
├── 03_Process_Maps_AsIs_vs_ToBe/
├── 04_Database_Datasets_3000_Records_INR/
├── 05_SQL_Server_Scripts_and_BA_Queries/
├── 06_Retention_Decision_Rules_and_ROI_Analysis/
└── 07_Agile_User_Stories_RTM_and_UAT_Workbook/
```

## How to discuss this in an interview

Describe it as a self-directed, synthetic-data case study. Explain what the data can and cannot support, how you would validate requirements with stakeholders, and how you would test the proposed workflow before launch. Do not describe the hypothetical personas as real interview participants or the proposed rules as deployed production functionality.

## Author

Shruti Thacker · [GitHub](https://github.com/shrutithacker14) · [Portfolio](https://shrutithacker.dev)
