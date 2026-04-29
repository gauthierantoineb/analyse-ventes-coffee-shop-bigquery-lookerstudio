CREATE OR REPLACE TABLE `myprojet-485110.coffee_staging.stg_transactions` AS
SELECT
  ROW_NUMBER() OVER (
    ORDER BY `Date`, `Time`, coffee_name, money
  ) AS transaction_id,
  CAST(`Date` AS DATE) AS transaction_date,
  CAST(`Time` AS TIME) AS transaction_time,
  CAST(hour_of_day AS INT64) AS hour_of_day,
  TRIM(Time_of_Day) AS time_of_day,
  TRIM(Weekday) AS weekday,
  CAST(Weekdaysort AS INT64) AS weekday_sort,
  TRIM(Month_name) AS month_name,
  CAST(Monthsort AS INT64) AS month_sort,
  TRIM(cash_type) AS payment_method,
  TRIM(coffee_name) AS coffee_name,
  CAST(money AS NUMERIC) AS transaction_amount,
  CASE
    WHEN CAST(Weekdaysort AS INT64) IN (6, 7) THEN TRUE
    ELSE FALSE
  END AS is_weekend
FROM `myprojet-485110.coffee_raw.transactions_raw`
WHERE money IS NOT NULL
  AND coffee_name IS NOT NULL
  AND `Date` IS NOT NULL
  AND `Time` IS NOT NULL;
