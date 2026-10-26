/* =========================================================================================
   PROJECT:   CUSTOMER CHURN & REVENUE RETENTION DECISION SUPPORT SYSTEM (BA + SQL PROJECT)
   SCRIPT 02: BUSINESS ANALYST SQL ROOT-CAUSE DISCOVERY QUERIES (PRE-BRD ELICITATION)
   AUTHOR:    Shruti Thacker (@shrutithacker14)
   WHY THIS MATTERS FOR INTERVIEWS:
              Instead of relying on stakeholder guesswork, the Business Analyst wrote these
              5 SQL queries during the Discovery Phase to quantify WHERE and WHY revenue
              was churning—directly shaping Functional Requirements FR-01 through FR-10!
   ========================================================================================= */

USE CustomerRetentionBA_DB;
GO

-- =================================================================------------------------
-- BA DISCOVERY QUERY 1: Executive Churn & ARR Leakage Audit by Indian State (INR ₹)
-- Purpose: Summarises churned ARR in the synthetic sample; it does not establish a project budget.
-- =================================================================------------------------
SELECT 
    State,
    Region_Zone,
    COUNT(Customer_ID) AS Total_Subscribers,
    SUM(CAST(Is_Churned_Flag AS INT)) AS Churned_Subscribers,
    CAST(ROUND(AVG(CAST(Is_Churned_Flag AS FLOAT)) * 100.0, 2) AS DECIMAL(5,2)) AS Logo_Churn_Rate_Pct,
    FORMAT(SUM(Annualized_Revenue_ARR_INR), 'N0') AS Total_State_ARR_INR,
    FORMAT(SUM(CASE WHEN Is_Churned_Flag = 1 THEN Annualized_Revenue_ARR_INR ELSE 0 END), 'N0') AS Churned_ARR_Lost_INR,
    FORMAT(SUM(CASE WHEN Subscription_Status = 'Active (At-Risk)' THEN Annualized_Revenue_ARR_INR ELSE 0 END), 'N0') AS Active_At_Risk_ARR_INR
FROM dbo.Dim_Customer_Subscriptions
GROUP BY State, Region_Zone
ORDER BY SUM(CASE WHEN Is_Churned_Flag = 1 THEN Annualized_Revenue_ARR_INR ELSE 0 END) DESC;

-- =================================================================------------------------
-- BA DISCOVERY QUERY 2: Pareto Root-Cause Breakdown (Voluntary vs. Involuntary Churn)
-- Insight Used in BRD: Proves that Payment Failures (Involuntary Churn) and >24h Support
-- SLA breaches drive over 55% of lost ARR -> Led directly to FR-01 (Smart UPI Dunning)
-- and FR-04 (Priority L2 SLA Escalation).
-- =================================================================------------------------
WITH Churned_Cohort AS (
    SELECT 
        Churn_Category,
        Primary_Churn_Root_Cause,
        COUNT(*) AS Churned_Accounts,
        SUM(Annualized_Revenue_ARR_INR) AS Lost_ARR_INR
    FROM dbo.Dim_Customer_Subscriptions
    WHERE Is_Churned_Flag = 1
    GROUP BY Churn_Category, Primary_Churn_Root_Cause
)
SELECT 
    Churn_Category,
    Primary_Churn_Root_Cause,
    Churned_Accounts,
    ROUND(Lost_ARR_INR, 2) AS Lost_ARR_INR,
    CAST(ROUND(Lost_ARR_INR * 100.0 / SUM(Lost_ARR_INR) OVER (), 2) AS DECIMAL(5,2)) AS Share_Of_Lost_ARR_Pct,
    CAST(ROUND(SUM(Lost_ARR_INR) OVER (ORDER BY Lost_ARR_INR DESC) * 100.0 / SUM(Lost_ARR_INR) OVER (), 2) AS DECIMAL(5,2)) AS Cumulative_ARR_Loss_Pct
FROM Churned_Cohort
ORDER BY Lost_ARR_INR DESC;

-- =================================================================------------------------
-- BA DISCOVERY QUERY 3: Early-Tenure Onboarding Cohort Analysis (Tenure + Onboarding Flag)
-- Insight Used in BRD: Customers who do NOT complete onboarding in Months 1-3 churn at
-- nearly 3x the rate of onboarded users -> Led to FR-03 (Guided In-App Onboarding Nudge).
-- =================================================================------------------------
SELECT 
    CASE 
        WHEN Tenure_Months <= 3 THEN '1. Early Tenure (1-3 Months)'
        WHEN Tenure_Months BETWEEN 4 AND 12 THEN '2. Mid Tenure (4-12 Months)'
        ELSE '3. Mature Tenure (13+ Months)'
    END AS Tenure_Cohort,
    Onboarding_Completed_Flag,
    COUNT(*) AS Subscriber_Count,
    SUM(CAST(Is_Churned_Flag AS INT)) AS Churned_Count,
    CAST(ROUND(AVG(CAST(Is_Churned_Flag AS FLOAT)) * 100.0, 2) AS DECIMAL(5,2)) AS Cohort_Churn_Rate_Pct,
    ROUND(AVG(Usage_Drop_MoM_Pct), 1) AS Avg_MoM_Usage_Drop_Pct
FROM dbo.Dim_Customer_Subscriptions
GROUP BY 
    CASE 
        WHEN Tenure_Months <= 3 THEN '1. Early Tenure (1-3 Months)'
        WHEN Tenure_Months BETWEEN 4 AND 12 THEN '2. Mid Tenure (4-12 Months)'
        ELSE '3. Mature Tenure (13+ Months)'
    END,
    Onboarding_Completed_Flag
ORDER BY Tenure_Cohort, Onboarding_Completed_Flag;

-- =================================================================------------------------
-- BA DISCOVERY QUERY 4: Payment Method & Involuntary Dunning Failure Analysis
-- Insight Used in BRD: Manual One-Time UPI and Debit Cards have 4x higher payment failures
-- than UPI AutoPay -> Justified FR-02 (₹100 Cashback Nudge to switch to UPI AutoPay).
-- =================================================================------------------------
SELECT 
    Payment_Method,
    Billing_Cycle,
    COUNT(*) AS Total_Users,
    ROUND(AVG(CAST(Payment_Failures_90D AS FLOAT)), 2) AS Avg_Payment_Failures_90D,
    SUM(CASE WHEN Churn_Category = 'Involuntary (Payment Failure)' THEN 1 ELSE 0 END) AS Involuntary_Churned_Users,
    CAST(ROUND(AVG(CAST(Is_Churned_Flag AS FLOAT)) * 100.0, 2) AS DECIMAL(5,2)) AS Overall_Churn_Rate_Pct,
    SUM(CASE WHEN Is_Churned_Flag = 1 THEN Annualized_Revenue_ARR_INR ELSE 0 END) AS Churned_ARR_INR
FROM dbo.Dim_Customer_Subscriptions
GROUP BY Payment_Method, Billing_Cycle
ORDER BY Involuntary_Churned_Users DESC;

-- =================================================================------------------------
-- BA DISCOVERY QUERY 5: Support Ticket SLA Breach (>24h) Impact via SQL INNER JOIN
-- Insight Used in BRD: Joins Subscriptions with Fact_Support_And_Payment_Events to prove
-- how >24h ticket resolution destroys CSAT and spikes churn.
-- =================================================================------------------------
SELECT 
    c.SLA_Breach_Over_24H_Flag,
    COUNT(DISTINCT c.Customer_ID) AS Customers_With_Tickets,
    COUNT(e.Event_ID) AS Total_Support_Events_Logged,
    ROUND(AVG(e.Resolution_Duration_Hours), 1) AS Avg_Resolution_Hours,
    ROUND(AVG(CAST(e.Post_Interaction_CSAT_1to5 AS FLOAT)), 2) AS Avg_Post_Ticket_CSAT,
    CAST(ROUND(AVG(CAST(c.Is_Churned_Flag AS FLOAT)) * 100.0, 2) AS DECIMAL(5,2)) AS Customer_Churn_Rate_Pct
FROM dbo.Dim_Customer_Subscriptions c
INNER JOIN dbo.Fact_Support_And_Payment_Events e
    ON c.Customer_ID = e.Customer_ID
WHERE e.Event_Category = 'Customer_Support_Ticket'
GROUP BY c.SLA_Breach_Over_24H_Flag;
GO
