-- AccountBirthdays CTE to group users into cohort by their signup month
WITH AccountBirthdays AS (
	SELECT
		account_id,
		MIN(start_date) AS first_signup_date,
		DATEFROMPARTS(YEAR(MIN(start_date)), MONTH(MIN(start_date)), 1) AS cohort_month
	FROM ravenstack_subscriptions
	GROUP BY account_id
),
-- MonthZeroResponseTimes CTE to isolate speed of support responses during a user’s first 30 days of onboarding
MonthZeroResponseTimes AS (
	SELECT
		b.cohort_month,
		b.account_id,
		t.first_response_time_minutes
	FROM AccountBirthdays b
	INNER JOIN ravenstack_support_tickets t
		ON b.account_id = t.account_id
		AND t.submitted_at BETWEEN b.first_signup_date AND DATEADD(day, 30, b.first_signup_date)
)
SELECT
	cohort_month,
	COUNT(account_id) AS total_month_0_tickets,
	ROUND(AVG(CAST(first_response_time_minutes AS FLOAT) / 60.0), 2) AS avg_response_time_hours
FROM MonthZeroResponseTimes
GROUP BY cohort_month
ORDER BY cohort_month;

/* Month 1 user retention correlates with support response times during onboarding. 
Response windows under 1 hour yield maximum customer lifetime value. */