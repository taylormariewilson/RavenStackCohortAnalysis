-- AccountBirthdays CTE to group users into cohort by their signup month
WITH AccountBirthdays AS (
	SELECT
		account_id,
		MIN(start_date) AS first_signup_date,
		DATEFROMPARTS(YEAR(MIN(start_date)), MONTH(MIN(start_date)), 1) AS cohort_month
	FROM ravenstack_subscriptions
	GROUP BY account_id
),
MonthZeroTickets AS (
	SELECT
		b.cohort_month,
		b.account_id,
		COUNT(DISTINCT t.ticket_id) AS tickets_submitted
	FROM AccountBirthdays b
	LEFT JOIN ravenstack_support_tickets t
		ON b.account_id = t.account_id
		AND t.submitted_at BETWEEN b.first_signup_date AND DATEADD(day, 30, b.first_signup_date)
	GROUP BY b.cohort_month, b.account_id
)
SELECT
	cohort_month,
	COUNT(account_id) AS total_users,
	SUM(tickets_submitted) AS total_month_0_tickets,
	CAST(SUM(tickets_submitted) AS FLOAT) / COUNT(account_id) AS avg_tickets_per_user
FROM MonthZeroTickets
GROUP BY cohort_month
ORDER BY cohort_month;

/* Insight: January 2023 cohort averages 0.50 tickets per user in Month 0 followed by 50% Month 1 retention rate.
July 2024 cohort had a low friction score of 0.14 tickets per user followed by a 96.4% Month 1 retention rate.
High tickets per user may be related to lower retention. */