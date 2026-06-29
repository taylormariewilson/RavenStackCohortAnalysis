WITH AccountBirthdays AS (
	SELECT
		account_id,
		DATEFROMPARTS(YEAR(MIN(start_date)), MONTH(MIN(start_date)), 1) AS
cohort_month
	FROM ravenstack_subscriptions
	GROUP BY account_id
),
CleanedActivity AS (
	SELECT
		b.cohort_month,
		s.account_id,
		DATEDIFF(month, b.cohort_month, s.start_date) AS months_active
	FROM ravenstack_subscriptions s
	JOIN AccountBirthdays b ON s.account_id = b.account_id
	GROUP BY b.cohort_month, s.account_id, DATEDIFF(month, b.cohort_month, s.start_date)
)
SELECT
	cohort_month,
	months_active,
	COUNT(DISTINCT account_id) AS active_users_count
FROM CleanedActivity
GROUP BY cohort_month, months_active
ORDER BY cohort_month, months_active;