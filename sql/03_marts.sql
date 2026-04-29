CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_kpi_overview` AS
SELECT
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value,
  COUNT(DISTINCT transaction_date) AS active_days,
  SAFE_DIVIDE(SUM(transaction_amount), COUNT(DISTINCT transaction_date)) AS revenue_per_day
FROM `myprojet-485110.coffee_mart.fct_transactions`;

CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_sales_overview_daily` AS
SELECT
  transaction_date,
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY transaction_date
ORDER BY transaction_date;

CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_sales_by_product` AS
SELECT
  coffee_name,
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value,
  SAFE_DIVIDE(
    SUM(transaction_amount),
    SUM(SUM(transaction_amount)) OVER ()
  ) AS revenue_share
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY coffee_name
ORDER BY total_revenue DESC;

CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_sales_by_hour` AS
SELECT
  hour_of_day,
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY hour_of_day
ORDER BY hour_of_day;

CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_sales_by_time_of_day` AS
SELECT
  time_of_day,
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY time_of_day
ORDER BY total_revenue DESC;

CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_sales_by_time_of_day_sorted` AS
SELECT
  time_of_day,
  CASE
    WHEN time_of_day = 'Morning' THEN 1
    WHEN time_of_day = 'Afternoon' THEN 2
    WHEN time_of_day = 'Night' THEN 3
    ELSE 99
  END AS time_of_day_sort,
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY time_of_day;

CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_sales_by_weekday` AS
SELECT
  weekday,
  weekday_sort,
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY weekday, weekday_sort
ORDER BY weekday_sort;

CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_sales_by_month` AS
SELECT
  month_name,
  month_sort,
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY month_name, month_sort
ORDER BY month_sort;

CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_sales_by_year_month` AS
SELECT
  DATE_TRUNC(transaction_date, MONTH) AS year_month_date,
  FORMAT_DATE('%Y-%m', DATE_TRUNC(transaction_date, MONTH)) AS year_month_label,
  EXTRACT(YEAR FROM transaction_date) AS year_num,
  EXTRACT(MONTH FROM transaction_date) AS month_num,
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY 1, 2, 3, 4
ORDER BY year_month_date;

CREATE OR REPLACE TABLE `myprojet-485110.coffee_mart.mart_sales_hour_weekday` AS
SELECT
  weekday,
  weekday_sort,
  hour_of_day,
  COUNT(*) AS total_transactions,
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY weekday, weekday_sort, hour_of_day
ORDER BY weekday_sort, hour_of_day;

