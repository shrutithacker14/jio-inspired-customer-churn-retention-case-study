# Business Requirements Document and SQL Discovery Summary

**Project:** Customer Churn & Retention Decision Support — Portfolio Case Study  
**Scenario:** Jio-inspired Indian subscription business (hypothetical)  
**Document status:** Draft for review · Version 1.0  
**Prepared by:** Shruti Thacker

> **Disclosure:** This is an independent portfolio exercise. It is not a Reliance Jio/Jio Platforms project and is not based on company-confidential information. The included records are synthetic. All requirements and stakeholder roles are proposed, not approved by a real organisation.

## 1. Business problem

The fictional business has a customer-level subscription snapshot and a related support/payment event log. The objective is to explore whether churn patterns can inform a more structured retention process and to define what a future solution should do.

The analysis is exploratory. The dataset alone cannot establish causation, prove a customer’s stated reason for leaving, or quantify the impact of any proposed intervention.

## 2. Data profile

| Item | Value |
|---|---:|
| Customer/subscription records | 3,000 |
| Support/payment event records | 4,118 |
| Records marked churned | 632 |
| Churn share in supplied snapshot | 21.07% |
| Total annualized revenue represented | ₹20,868,000 |
| Annualized revenue associated with churned records | ₹4,332,816 |

These figures are calculated from the supplied CSVs. ARR is an annualized field in the synthetic dataset; churned ARR should not be described as actual cash lost, recovered revenue, or validated savings.

## 3. Scope

### In scope
- Explore churn distribution by recorded category, state, tenure, payment method, and risk-score band.
- Review support and payment event patterns.
- Define proposed retention queue criteria and business rules.
- Document functional requirements, user stories, KPIs, traceability, and UAT scenarios.
- Provide SQL Server scripts for repeatable local analysis.

### Out of scope
- A live connection to Jio or any real company's systems.
- Production deployment, CRM/WhatsApp integration, payment processing, or customer communications.
- A validated predictive churn model or causal impact assessment.
- Approved pricing, credits, incentive budgets, or financial ROI.

## 4. Stakeholder personas

The following are hypothetical roles to validate during discovery: business sponsor, retention operations lead, billing/payments product manager, customer support lead, data/BI analyst, privacy/legal representative, and customer representative. No real stakeholder interviews were conducted for this portfolio exercise.

## 5. Proposed business requirements

| ID | Requirement | Priority | Acceptance summary |
|---|---|---|---|
| BR-01 | The analyst must be able to segment churned and active accounts by key customer attributes. | Must | Query outputs reconcile to source row counts and documented definitions. |
| BR-02 | The process should identify active accounts meeting an agreed risk threshold. | Must | Only active accounts meeting the approved threshold appear in the queue. |
| BR-03 | The queue should display a reason/action recommendation that can be reviewed by an agent. | Must | Each queued record has a documented rule match and readable recommendation. |
| BR-04 | Offer costs must follow a formally approved budget guardrail. | Should | Rule configuration and boundary tests demonstrate the cap; no offer is sent automatically in this prototype. |
| BR-05 | Analysts must be able to trace requirements to user stories, SQL components, and UAT scenarios. | Must | Each in-scope requirement has a traceable artefact or a documented gap. |
| BR-06 | Customer outreach must respect consent, channel preferences, privacy, and opt-out requirements. | Must | Legal/privacy review and consent checks are defined before any real deployment. |

## 6. Proposed business rules (not approved)

- **RULE-01 — Payment friction:** If an active account has a high risk score and recent payment failures, flag it for billing review.
- **RULE-02 — Support friction:** If an active account is high risk and has a recorded SLA-breach indicator, flag it for support review.
- **RULE-03 — Usage decline:** If an active account is high risk and usage decline exceeds an agreed threshold, consider a pause/downgrade option for review.
- **RULE-04 — Early tenure:** If an active account is in early tenure and onboarding is incomplete, consider an onboarding nudge after consent and channel validation.
- **RULE-05 — Discount guardrail:** Do not offer discounts solely because a record is present in the queue; offers require approved eligibility, budget, and agent/business controls.

These rules are design proposals. The current SQL view is a prioritisation queue based on the stored risk score; it is not a predictive model and does not send communications.

## 7. KPI catalogue — definitions before targets

| KPI | Definition | Notes |
|---|---|---|
| Snapshot churn share | Churned records ÷ all customer records | A snapshot proportion, not a cohort-based period churn rate. |
| Churned ARR represented | Sum of ARR for records marked churned | Descriptive annualized value; not a realised cash loss or recoverable benefit. |
| Active at-risk ARR represented | Sum of ARR for active records meeting the agreed risk threshold | Depends on threshold and active-status definitions. |
| Payment failure rate | Accounts/events with payment failure ÷ eligible payment attempts/accounts | Requires a clearly defined denominator and event-level data. |
| Support SLA compliance | Eligible support tickets resolved within SLA ÷ eligible support tickets | Event data and business calendar rules must be confirmed. |
| Retention save rate | Eligible targeted accounts retained after a defined observation window ÷ eligible targeted accounts | Requires intervention logs, a time window, and a comparison design. |

No post-implementation targets or ROI are treated as validated in this portfolio. A real project would set baselines, targets, measurement windows, owners, and guardrails with stakeholders.

## 8. Assumptions, dependencies, and risks

- Synthetic fields accurately represent the stated schema for learning purposes.
- A real solution would need event timestamps, renewal dates, consent/channel preferences, offer history, and intervention outcomes.
- Risk-score quality and calibration are unknown.
- Outreach rules require privacy, legal, customer-experience, and operational review.
- Proposed credits/discounts require unit-economics and fraud review.
- Observed associations may be confounded; correlation is not causation.

## 9. UAT approach

UAT cases are scenarios to execute after loading the CSVs and running the SQL in a local test database. They are marked **Not Run** because this repository does not contain a live application or evidence of execution. Record actual output, tester, date, defect ID, and retest result before changing a status.

## 10. Open questions for discovery

1. What is the official definition and measurement window for churn?
2. Is the supplied risk score calibrated and approved for operational use?
3. What is the source of truth for renewal/payment failures?
4. What SLA applies by ticket type and business hours?
5. Which communication channels have valid consent and opt-out handling?
6. What is the approved maximum incentive cost and eligibility policy?
7. What outcome window and control group will be used to evaluate retention impact?

## 11. Sign-off

**Status:** Draft for portfolio demonstration only.  
**Approvals:** Not applicable; no real organisation or project sponsor is involved.
