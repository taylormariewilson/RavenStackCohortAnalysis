-- AccountBirthdays CTE to group users into cohort by their signup month
WITH AccountBirthdays AS (
	SELECT
		account_id,
		MIN(start_date) AS first_signup_date,
		DATEFROMPARTS(YEAR(MIN(start_date)), MONTH(MIN(start_date)), 1) AS cohort_month
	FROM ravenstack_subscriptions
	GROUP BY account_id
),
-- MonthZeroTickets CTE to isolate only the support tickets submitted during a user's absolute first 30 days on the platform
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
	MAX(tickets_submitted) AS max_tickets_single_user,
	SUM(CASE WHEN tickets_submitted > 2 THEN 1 ELSE 0 END) AS crisis_users_count
FROM MonthZeroTickets
GROUP BY cohort_month
ORDER BY cohort_month;
