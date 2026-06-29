-- AccountBirthdays to find the start date for each user as the cohort anchor
WITH AccountBirthdays AS (
	SELECT
		account_id,
		DATEFROMPARTS(YEAR(MIN(start_date)), MONTH(MIN(start_date)), 1) AS cohort_month
	FROM ravenstack_subscriptions
	GROUP BY account_id
),
-- CleanedActivity to track each month that each user actively used the app
CleanedActivity AS (
	SELECT
		b.cohort_month,
		s.account_id,
		DATEDIFF(month, b.cohort_month, s.start_date) AS months_active
	FROM ravenstack_subscriptions s
	JOIN AccountBirthdays b ON s.account_id = b.account_id
	GROUP BY b.cohort_month, s.account_id, DATEDIFF(month, b.cohort_month, s.start_date)
),
-- CohortActivityMatrix to count how many users are in each month bucket
CohortActivityMatrix AS (
	SELECT
		cohort_month,
		months_active,
		COUNT(DISTINCT account_id) AS active_users_count
	FROM CleanedActivity
	GROUP BY cohort_month, months_active
)
-- PIVOT function to flip the table into Pivot a cohort triangle
SELECT
	cohort_month,
	ISNULL([0], 0) AS Month_0,
	ISNULL([1], 0) AS Month_1,
	ISNULL([2], 0) AS Month_2,
	ISNULL([3], 0) AS Month_3,
	ISNULL([4], 0) AS Month_4,
	ISNULL([5], 0) AS Month_5
FROM CohortActivityMatrix
PIVOT (
	SUM(active_users_count)
	FOR months_active IN ([0], [1], [2], [3], [4], [5])
) AS PivotTriangle
ORDER BY cohort_month;