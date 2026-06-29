-- AccountBirthdays CTE to group users into cohort by their signup month
WITH AccountBirthdays AS (    
    SELECT 
        account_id,
        DATEFROMPARTS(YEAR(MIN(start_date)), MONTH(MIN(start_date)), 1) AS cohort_month
    FROM ravenstack_subscriptions
    GROUP BY account_id
),
-- CleanedActivity CTE to track each month that each user actively used the app
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
),
-- PIVOT function to flip the table into Pivot a cohort triangle
RawPivotTriangle AS (
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
)
SELECT 
    cohort_month,
    Month_0 AS Starting_Size,
/* Casting integers as FLOAT to use decimal math. 
Using NULLIF to safely avoid any accidental divide-by-zero errors.
FORMAT (..., 'P1') to format as a percentage with 1 decimal place. */
    '100.0%' AS [Month 0 %],
    FORMAT(CAST(Month_1 AS FLOAT) / NULLIF(Month_0, 0), 'P1') AS [Month 1 %],
    FORMAT(CAST(Month_2 AS FLOAT) / NULLIF(Month_0, 0), 'P1') AS [Month 2 %],
    FORMAT(CAST(Month_3 AS FLOAT) / NULLIF(Month_0, 0), 'P1') AS [Month 3 %],
    FORMAT(CAST(Month_4 AS FLOAT) / NULLIF(Month_0, 0), 'P1') AS [Month 4 %],
    FORMAT(CAST(Month_5 AS FLOAT) / NULLIF(Month_0, 0), 'P1') AS [Month 5 %]
FROM RawPivotTriangle
ORDER BY cohort_month;