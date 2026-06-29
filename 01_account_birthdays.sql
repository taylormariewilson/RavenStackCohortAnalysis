-- AccountBirthdays CTE to group users into cohort by their signup month
WITH AccountBirthdays AS (
    SELECT 
        account_id,
        DATEFROMPARTS(YEAR(MIN(start_date)), MONTH(MIN(start_date)), 1) AS cohort_month
    FROM ravenstack_subscriptions
    GROUP BY account_id
)
SELECT 
    b.cohort_month,
    s.account_id,
    DATEDIFF(month, b.cohort_month, s.start_date) AS months_active
FROM ravenstack_subscriptions s
JOIN AccountBirthdays b ON s.account_id = b.account_id
-- Grouping by these three elements to collapse any mid-month subscription changes into a single record
GROUP BY b.cohort_month, s.account_id, DATEDIFF(month, b.cohort_month, s.start_date)
ORDER BY b.cohort_month, s.account_id, months_active;
