/* =========================================================================================
   PROJECT:   CUSTOMER CHURN & REVENUE RETENTION DECISION SUPPORT SYSTEM (BA + SQL PROJECT)
   SCRIPT 01: RELATIONAL DATABASE SCHEMA & TABLE CREATION (T-SQL / SQL SERVER)
   AUTHOR:    Shruti Thacker (@shrutithacker14) | Portfolio: shrutithacker.dev
   PURPOSE:   Creates the 2 core tables used by the Business Analyst to diagnose churn drivers
              and power the automated retention rules engine.
   ========================================================================================= */

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'CustomerRetentionBA_DB')
BEGIN
    CREATE DATABASE CustomerRetentionBA_DB;
END
GO

USE CustomerRetentionBA_DB;
GO

IF OBJECT_ID('dbo.Fact_Support_And_Payment_Events', 'U') IS NOT NULL
    DROP TABLE dbo.Fact_Support_And_Payment_Events;
IF OBJECT_ID('dbo.Dim_Customer_Subscriptions', 'U') IS NOT NULL
    DROP TABLE dbo.Dim_Customer_Subscriptions;
GO

-- 1. Master Customer Subscription & Risk Table (3,000 Subscriber Accounts)
CREATE TABLE dbo.Dim_Customer_Subscriptions (
    Customer_ID                     VARCHAR(15)     NOT NULL PRIMARY KEY,
    State                           VARCHAR(30)     NOT NULL,
    Region_Zone                     VARCHAR(15)     NOT NULL,
    Plan_Name                       VARCHAR(40)     NOT NULL,
    Billing_Cycle                   VARCHAR(15)     NOT NULL CHECK (Billing_Cycle IN ('Monthly', 'Annual')),
    Payment_Method                  VARCHAR(30)     NOT NULL,
    Tenure_Months                   INT             NOT NULL CHECK (Tenure_Months >= 1),
    Onboarding_Completed_Flag       BIT             NOT NULL,
    Active_Days_Last_30D            INT             NOT NULL CHECK (Active_Days_Last_30D BETWEEN 0 AND 31),
    Usage_Drop_MoM_Pct              DECIMAL(5, 2)   NOT NULL,
    Support_Tickets_90D             INT             NOT NULL CHECK (Support_Tickets_90D >= 0),
    Avg_Ticket_Resolution_Hours     DECIMAL(6, 2)   NOT NULL CHECK (Avg_Ticket_Resolution_Hours >= 0),
    SLA_Breach_Over_24H_Flag        BIT             NOT NULL,
    Payment_Failures_90D            INT             NOT NULL CHECK (Payment_Failures_90D >= 0),
    Monthly_Recurring_Revenue_INR   DECIMAL(10, 2)  NOT NULL CHECK (Monthly_Recurring_Revenue_INR > 0),
    Annualized_Revenue_ARR_INR      DECIMAL(12, 2)  NOT NULL CHECK (Annualized_Revenue_ARR_INR > 0),
    Lifetime_Revenue_LTV_INR        DECIMAL(12, 2)  NOT NULL,
    SQL_Churn_Risk_Score            INT             NOT NULL CHECK (SQL_Churn_Risk_Score BETWEEN 0 AND 100),
    Subscription_Status             VARCHAR(25)     NOT NULL,
    Is_Churned_Flag                 BIT             NOT NULL,
    Churn_Category                  VARCHAR(45)     NOT NULL,
    Primary_Churn_Root_Cause        VARCHAR(60)     NOT NULL,
    Recommended_BA_Retention_Action VARCHAR(120)    NOT NULL
);
GO

-- 2. Child Operational Event Log Table (Support Tickets & Payment Gateway Events)
CREATE TABLE dbo.Fact_Support_And_Payment_Events (
    Event_ID                        VARCHAR(15)     NOT NULL PRIMARY KEY,
    Customer_ID                     VARCHAR(15)     NOT NULL,
    Event_Date                      DATE            NOT NULL,
    Event_Category                  VARCHAR(35)     NOT NULL,
    Event_SubType                   VARCHAR(50)     NOT NULL,
    Resolution_Duration_Hours       DECIMAL(6, 2)   NOT NULL,
    SLA_Breached_Flag               BIT             NOT NULL,
    Post_Interaction_CSAT_1to5      INT             NOT NULL CHECK (Post_Interaction_CSAT_1to5 BETWEEN 1 AND 5),
    CONSTRAINT FK_Events_Customer FOREIGN KEY (Customer_ID)
        REFERENCES dbo.Dim_Customer_Subscriptions (Customer_ID)
);
GO

CREATE NONCLUSTERED INDEX IX_Cust_Risk_State 
    ON dbo.Dim_Customer_Subscriptions (Subscription_Status, SQL_Churn_Risk_Score DESC, State)
    INCLUDE (Monthly_Recurring_Revenue_INR, Annualized_Revenue_ARR_INR, Recommended_BA_Retention_Action);

CREATE NONCLUSTERED INDEX IX_Events_Customer_Type
    ON dbo.Fact_Support_And_Payment_Events (Customer_ID, Event_Category, SLA_Breached_Flag);
GO
