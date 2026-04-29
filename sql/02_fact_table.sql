CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.fct_transactions`
PARTITION BY transaction_date
CLUSTER BY coffee_name, time_of_day, weekday_sort AS
SELECT
  transaction_id,
  transaction_date,
  transaction_time,
  hour_of_day,
  time_of_day,
  weekday,
  weekday_sort,
  month_name,
  month_sort,
  payment_method,
  coffee_name,
  transaction_amount,
  is_weekend
FROM `myprojet-485110.coffee_staging.stg_transactions`;
