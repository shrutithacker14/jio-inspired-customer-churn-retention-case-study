/* =========================================================================================
   PROJECT:   CUSTOMER CHURN & REVENUE RETENTION DECISION SUPPORT SYSTEM (BA + SQL PROJECT)
   SCRIPT 03: PROPOSED SQL RETENTION PRIORITISATION QUEUE VIEW
   AUTHOR:    Shruti Thacker (@shrutithacker14)
   PURPOSE:   Implements the To-Be Business Rules (BR-01 to BR-05) directly in SQL Server
              to generate a sample daily prioritisation queue for analyst review; it does not contact customers.
   ========================================================================================= */

USE CustomerRetentionBA_DB;
GO

CREATE OR ALTER VIEW dbo.vw_Daily_Proactive_Retention_Queue AS
SELECT 
    c.Customer_ID,
    c.State,
    c.Plan_Name,
    c.Billing_Cycle,
    c.Payment_Method,
    c.Tenure_Months,
    c.Monthly_Recurring_Revenue_INR,
    c.Annualized_Revenue_ARR_INR,
    c.SQL_Churn_Risk_Score,
    CASE 
        WHEN c.SQL_Churn_Risk_Score >= 75 THEN 'P1 - CRITICAL (Intervene Within 4 Hours)'
        WHEN c.SQL_Churn_Risk_Score BETWEEN 60 AND 74 THEN 'P2 - HIGH (Automated Campaign Within 24 Hours)'
        ELSE 'P3 - MODERATE (Weekly Engagement Nudge)'
    END AS Intervention_SLA_Priority,
    c.Recommended_BA_Retention_Action,
    -- Calculate Maximum Allowable Retention Offer Cost (Capped at 15% of Annual ARR)
    CAST(ROUND(c.Annualized_Revenue_ARR_INR * 0.15, 2) AS DECIMAL(10,2)) AS Max_Allowed_Save_Offer_Budget_INR
FROM dbo.Dim_Customer_Subscriptions c
WHERE c.Is_Churned_Flag = 0
  AND c.SQL_Churn_Risk_Score >= 55;
GO

-- Example: retrieve top 25 active at-risk records for analyst review (not automatic intervention)
SELECT TOP 25 *
FROM dbo.vw_Daily_Proactive_Retention_Queue
ORDER BY SQL_Churn_Risk_Score DESC, Annualized_Revenue_ARR_INR DESC;
GO
