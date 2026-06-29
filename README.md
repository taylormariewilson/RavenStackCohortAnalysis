# RavenStack SaaS Subscription Onboarding Optimization: Cohort Analysis 

## Summary
End-to-end cohort analysis that investigates the direct correlation between customer support operational metrics (SLA response times and ticket volumes) and customer retention outcomes across 24 historical cohorts. By joining raw support ticket databases with subscription tables, this analysis answers a core business question: *Does a slower support response time during user onboarding directly result in lower user retention?*

**[View the Interactive Dashboard on Tableau Public](https://public.tableau.com/views/RavenStack_Project/Dashboard1?:language=en-US&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**

---
<img width="1920" height="1080" alt="RavenStackCohortAnalysis" src="https://github.com/user-attachments/assets/ee35bfc7-39e2-48d8-9a77-78a0ce9c680e" />

### Key Insights
* **The Negative SLA Impact:** Quantitative analysis proves a strong negative correlation between onboarding response times and Month 1 retention. For every hour response time creeps past 1.5 hours, Month 1 retention experiences a significant decline.
* **Volume Seasonality Drivers:** A dual-axis trend analysis revealed that ticket volume spikes (e.g., August 2023) actively drive down operational response speeds, directly leading to subsequent drops in cohort retention.
* **Sustained Stability:** The stabilization of onboarding ticket volumes throughout mid-2024 directly correlated with a massive multi-month climb in customer retention, peaking with the star July 2024 cohort.

---

### Technical Stack & Methodology

#### 1. Data Engineering & Aggregation (SQL Server)
* Wrote relational queries utilizing Common Table Expressions (CTEs), window functions, and multi-table joins to blend subscription histories with active support ticket logs.
* Cleaned and transformed date-stamps into discrete chronological cohort grains to track operational velocity.
* Developed a production-ready database view (`v_cohort_onboarding_insights`) to serve as a clean, single-source-of-truth semantic layer for business intelligence tools.

#### 2. Business Intelligence & Statistical Analysis (Tableau)
* Developed an executive-grade dashboard combining bivariate scatter plots with time-series trends.
* Implemented custom linear trend lines to prove the statistical relationship between customer service velocity and user loyalty.
* Configured advanced dashboard filter actions passing background date grains across disparate visualization types to build a fully dynamic user experience.

---

### How to Explore the Repository
* `/SQL_Scripts/`: Contains the complete data cleaning, modeling, and view-creation scripts.
* `/Tableau/`: Contains the packaged Tableau Workbook (`.twbx`) file.

  ---

**Let's Connect:** If you have questions about the methodology, the backend SQL modeling, or want to discuss these findings, feel free to reach out to me via **[LinkedIn](http://www.linkedin.com/in/taylorwilson9280)** .



