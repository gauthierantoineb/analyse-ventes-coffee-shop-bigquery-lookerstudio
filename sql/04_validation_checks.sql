SELECT COUNT(*) AS row_count
FROM `myprojet-485110.coffee_raw.transactions_raw`;

SELECT COUNT(*) AS row_count
FROM `myprojet-485110.coffee_staging.stg_transactions`;

SELECT COUNT(*) AS row_count
FROM `myprojet-485110.coffee_mart.fct_transactions`;

SELECT
  SUM(transaction_amount) AS total_revenue,
  AVG(transaction_amount) AS avg_transaction_value
FROM `myprojet-485110.coffee_mart.fct_transactions`;

SELECT SUM(transaction_amount) AS revenue_fact
FROM `myprojet-485110.coffee_mart.fct_transactions`;

SELECT SUM(total_revenue) AS revenue_daily
FROM `myprojet-485110.coffee_mart.mart_sales_overview_daily`;

SELECT SUM(total_revenue) AS revenue_product
FROM `myprojet-485110.coffee_mart.mart_sales_by_product`;

SELECT SUM(total_revenue) AS revenue_time_of_day
FROM `myprojet-485110.coffee_mart.mart_sales_by_time_of_day`;

SELECT *
FROM `myprojet-485110.coffee_mart.mart_sales_by_product`;

SELECT *
FROM `myprojet-485110.coffee_mart.mart_sales_by_weekday`;

SELECT *
FROM `myprojet-485110.coffee_mart.mart_sales_by_hour`;

SELECT *
FROM `myprojet-485110.coffee_mart.mart_sales_by_year_month`;
