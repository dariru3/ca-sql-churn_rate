--3~
WITH months AS (
  SELECT
    '2017-01-01' AS first_day,
    '2017-01-31' AS last_day
  UNION
  SELECT
    '2017-02-01' AS first_day,
    '2017-02-28' AS last_day
  UNION
  SELECT
    '2017-03-01' AS first_day,
    '2017-03-31' AS last_day
),
cross_join AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS (
  SELECT
    id,
    first_day month,
    CASE
      WHEN segment = 87
        AND subscription_start < first_day
        THEN 1
      ELSE 0
    END AS is_active_87,
    CASE
      WHEN segment = 30
        AND subscription_start < first_day
        THEN 1
      ELSE 0
    END AS is_active_30,
    CASE
      WHEN segment = 87
        AND subscription_end BETWEEN first_day AND last_day
        THEN 1
      ELSE 0
    END AS is_cancelled_87,
    CASE
      WHEN segment = 30
        AND subscription_end BETWEEN first_day AND last_day
        THEN 1
      ELSE 0
    END AS is_cancelled_30
  FROM cross_join
),
status_aggregate AS (
  SELECT
    month,
    SUM(is_active_87) sum_active_87,
    SUM(is_active_30) sum_active_30,
    SUM(is_cancelled_87) sum_canceled_87,
    SUM(is_cancelled_30) sum_canceled_30
  FROM status
  GROUP BY month
)
SELECT
  month,
  1.0 * sum_canceled_87 / sum_active_87 AS churn_87,
  1.0 * sum_canceled_30 / sum_active_30 AS churn_30
FROM status_aggregate
;
