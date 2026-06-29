-- AccountBirthdays CTE to group users into cohort by their signup month
WITH AccountBirthdays AS (
	SELECT
		account_id,
		MIN(start_date) AS first_signup_date,
		DATEFROMPARTS(YEAR(MIN(start_date)), MONTH(MIN(start_date)), 1) AS cohort_month
	FROM ravenstack_subscriptions
	GROUP BY account_id
),
-- CleanedActivity CTE to join subscription history to AccountBirthdays
CleanedActivity AS (
	SELECT
		b.cohort_month,
		s.account_id,
-- DATEDIFF to convert calendar dates into standardized milestone
		DATEDIFF(month, b.cohort_month, s.start_date) AS months_active
	FROM ravenstack_subscriptions s
	JOIN AccountBirthdays b ON s.account_id = b.account_id
	GROUP BY b.cohort_month, s.account_id, DATEDIFF(month, b.cohort_month, s.start_date)
),
/* CohortSizes CTE to calculate the total denominator for the cohort and count how many unique
users are active at 'months_active = 1' to isolate our absolute Month 1 baseline. */
CohortSizes AS (
	SELECT
		cohort_month,
		COUNT(DISTINCT account_id) AS starting_size,
		COUNT(DISTINCT CASE WHEN months_active = 1 THEN account_id END) AS month_1_users
	FROM CleanedActivity
	GROUP BY cohort_month
), 
/* SupportMetrics CTE to calculate customer support interactions within a user's first  30 days. 
avg_tickets_per_user to track onboarding friction volume. 
avg_response_time_hours to track customer support responsiveness. */
SupportMetrics AS (
	SELECT
		b.cohort_month,
		CAST(SUM(CASE WHEN t.submitted_at BETWEEN b.first_signup_date AND DATEADD(day, 30, b.first_signup_date)
		THEN 1 ELSE 0 END) AS FLOAT) / COUNT(DISTINCT b.account_id) AS avg_tickets_per_user,
		ROUND(AVG(CASE WHEN t.submitted_at BETWEEN b.first_signup_date AND DATEADD(day, 30, b.first_signup_date)
		THEN CAST(t.first_response_time_minutes AS FLOAT) / 60.0 END), 2) AS avg_response_time_hours
	FROM AccountBirthdays b
	LEFT JOIN ravenstack_support_tickets t ON b.account_id = t.account_id
	GROUP BY b.cohort_month
	)
-- Merging CohortSizes with SupportMetrics. Formatting variables to translate calculations into clean metrics. 
	SELECT
		c.cohort_month,
		c.starting_size,
		FORMAT(CAST(c.month_1_users AS FLOAT) / NULLIF(c.starting_size, 0), 'P1') AS [Month 1 Retention],
		ROUND(s.avg_tickets_per_user, 2) AS [Avg Tickets Per user],
		ISNULL(CAST(s.avg_response_time_hours AS VARCHAR), 'No Tickets') AS [Avg Response Hours]
	FROM CohortSizes c
	LEFT JOIN SupportMetrics s ON c.cohort_month = s.cohort_month
	ORDER BY c.cohort_month;