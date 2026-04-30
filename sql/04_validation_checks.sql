-- ============================================================
-- 04_validation_checks.sql
-- Coffee Shop Sales Analytics
-- Objectif :
-- Vérifier la cohérence des données entre les couches :
-- raw -> staging -> fact -> marts
-- ============================================================


-- ============================================================
-- 1. VOLUME DE LIGNES PAR COUCHE
-- ============================================================

WITH row_counts AS (
  SELECT
    'raw.transactions_raw' AS table_name,
    COUNT(*) AS row_count
  FROM `myprojet-485110.coffee_raw.transactions_raw`

  UNION ALL

  SELECT
    'staging.stg_transactions' AS table_name,
    COUNT(*) AS row_count
  FROM `myprojet-485110.coffee_staging.stg_transactions`

  UNION ALL

  SELECT
    'mart.fct_transactions' AS table_name,
    COUNT(*) AS row_count
  FROM `myprojet-485110.coffee_mart.fct_transactions`
)

SELECT *
FROM row_counts
ORDER BY table_name;


-- ============================================================
-- 2. COMPARAISON DES VOLUMES ENTRE COUCHES
-- ============================================================

WITH counts AS (
  SELECT
    (SELECT COUNT(*) FROM `myprojet-485110.coffee_raw.transactions_raw`) AS raw_rows,
    (SELECT COUNT(*) FROM `myprojet-485110.coffee_staging.stg_transactions`) AS staging_rows,
    (SELECT COUNT(*) FROM `myprojet-485110.coffee_mart.fct_transactions`) AS fact_rows
)

SELECT
  raw_rows,
  staging_rows,
  fact_rows,
  raw_rows - staging_rows AS rows_removed_between_raw_and_staging,
  staging_rows - fact_rows AS rows_removed_between_staging_and_fact,

  CASE
    WHEN staging_rows > raw_rows THEN 'FAIL - staging has more rows than raw'
    WHEN fact_rows > staging_rows THEN 'FAIL - fact has more rows than staging'
    ELSE 'PASS'
  END AS status
FROM counts;


-- ============================================================
-- 3. CONTRÔLE DE LA CLÉ TECHNIQUE transaction_id
-- ============================================================

SELECT
  COUNT(*) AS row_count,
  COUNT(DISTINCT transaction_id) AS distinct_transaction_ids,
  COUNT(*) - COUNT(DISTINCT transaction_id) AS duplicate_transaction_ids,

  CASE
    WHEN COUNT(*) = COUNT(DISTINCT transaction_id) THEN 'PASS'
    ELSE 'FAIL - duplicated transaction_id'
  END AS status
FROM `myprojet-485110.coffee_mart.fct_transactions`;


-- ============================================================
-- 4. CONTRÔLE DES CHAMPS OBLIGATOIRES DANS LA FACT TABLE
-- ============================================================

SELECT
  COUNT(*) AS row_count,

  COUNTIF(transaction_id IS NULL) AS null_transaction_id,
  COUNTIF(transaction_date IS NULL) AS null_transaction_date,
  COUNTIF(transaction_time IS NULL) AS null_transaction_time,
  COUNTIF(hour_of_day IS NULL) AS null_hour_of_day,
  COUNTIF(time_of_day IS NULL) AS null_time_of_day,
  COUNTIF(weekday IS NULL) AS null_weekday,
  COUNTIF(weekday_sort IS NULL) AS null_weekday_sort,
  COUNTIF(coffee_name IS NULL) AS null_coffee_name,
  COUNTIF(transaction_amount IS NULL) AS null_transaction_amount,

  CASE
    WHEN
      COUNTIF(transaction_id IS NULL) = 0
      AND COUNTIF(transaction_date IS NULL) = 0
      AND COUNTIF(transaction_time IS NULL) = 0
      AND COUNTIF(hour_of_day IS NULL) = 0
      AND COUNTIF(time_of_day IS NULL) = 0
      AND COUNTIF(weekday IS NULL) = 0
      AND COUNTIF(weekday_sort IS NULL) = 0
      AND COUNTIF(coffee_name IS NULL) = 0
      AND COUNTIF(transaction_amount IS NULL) = 0
    THEN 'PASS'
    ELSE 'FAIL - required fields contain null values'
  END AS status

FROM `myprojet-485110.coffee_mart.fct_transactions`;


-- ============================================================
-- 5. CONTRÔLE DES MONTANTS
-- ============================================================

SELECT
  COUNT(*) AS row_count,
  COUNTIF(transaction_amount IS NULL) AS null_amounts,
  COUNTIF(transaction_amount <= 0) AS invalid_amounts,
  MIN(transaction_amount) AS min_transaction_amount,
  MAX(transaction_amount) AS max_transaction_amount,
  ROUND(AVG(transaction_amount), 2) AS avg_transaction_amount,
  ROUND(SUM(transaction_amount), 2) AS total_revenue,

  CASE
    WHEN COUNTIF(transaction_amount IS NULL) > 0 THEN 'FAIL - null amounts'
    WHEN COUNTIF(transaction_amount <= 0) > 0 THEN 'FAIL - negative or zero amounts'
    ELSE 'PASS'
  END AS status

FROM `myprojet-485110.coffee_mart.fct_transactions`;


-- ============================================================
-- 6. CONTRÔLE DES DATES ET DES HEURES
-- ============================================================

SELECT
  MIN(transaction_date) AS min_transaction_date,
  MAX(transaction_date) AS max_transaction_date,

  COUNTIF(hour_of_day < 0 OR hour_of_day > 23) AS invalid_hours,
  COUNTIF(weekday_sort < 1 OR weekday_sort > 7) AS invalid_weekday_sort,

  CASE
    WHEN COUNTIF(hour_of_day < 0 OR hour_of_day > 23) > 0 THEN 'FAIL - invalid hour_of_day'
    WHEN COUNTIF(weekday_sort < 1 OR weekday_sort > 7) > 0 THEN 'FAIL - invalid weekday_sort'
    ELSE 'PASS'
  END AS status

FROM `myprojet-485110.coffee_mart.fct_transactions`;


-- ============================================================
-- 7. CONTRÔLE DE COHÉRENCE WEEK-END
-- Hypothèse : weekday_sort = 1 à 7, avec 6 et 7 = week-end
-- ============================================================

SELECT
  COUNT(*) AS row_count,
  COUNTIF(is_weekend != (weekday_sort IN (6, 7))) AS weekend_flag_errors,

  CASE
    WHEN COUNTIF(is_weekend != (weekday_sort IN (6, 7))) = 0 THEN 'PASS'
    ELSE 'FAIL - inconsistent is_weekend flag'
  END AS status

FROM `myprojet-485110.coffee_mart.fct_transactions`;


-- ============================================================
-- 8. CONTRÔLE DES DOUBLONS POTENTIELS AU GRAIN TRANSACTIONNEL
-- Attention :
-- Plusieurs transactions peuvent avoir le même produit, la même heure
-- et le même montant. Ce contrôle sert donc d'alerte, pas de preuve.
-- ============================================================

SELECT
  transaction_date,
  transaction_time,
  coffee_name,
  transaction_amount,
  COUNT(*) AS duplicate_count
FROM `myprojet-485110.coffee_mart.fct_transactions`
GROUP BY
  transaction_date,
  transaction_time,
  coffee_name,
  transaction_amount
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 50;


-- ============================================================
-- 9. RÉCONCILIATION DU CHIFFRE D'AFFAIRES ENTRE FACT ET MARTS
-- ============================================================

WITH fact AS (
  SELECT
    ROUND(SUM(transaction_amount), 2) AS revenue_fact
  FROM `myprojet-485110.coffee_mart.fct_transactions`
),

mart_revenues AS (
  SELECT
    'mart_sales_overview_daily' AS mart_name,
    ROUND(SUM(total_revenue), 2) AS revenue_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_overview_daily`

  UNION ALL

  SELECT
    'mart_sales_by_product' AS mart_name,
    ROUND(SUM(total_revenue), 2) AS revenue_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_product`

  UNION ALL

  SELECT
    'mart_sales_by_time_of_day' AS mart_name,
    ROUND(SUM(total_revenue), 2) AS revenue_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_time_of_day`

  UNION ALL

  SELECT
    'mart_sales_by_weekday' AS mart_name,
    ROUND(SUM(total_revenue), 2) AS revenue_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_weekday`

  UNION ALL

  SELECT
    'mart_sales_by_hour' AS mart_name,
    ROUND(SUM(total_revenue), 2) AS revenue_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_hour`

  UNION ALL

  SELECT
    'mart_sales_by_year_month' AS mart_name,
    ROUND(SUM(total_revenue), 2) AS revenue_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_year_month`
)

SELECT
  mart_name,
  fact.revenue_fact,
  mart_revenues.revenue_mart,
  ROUND(fact.revenue_fact - mart_revenues.revenue_mart, 2) AS revenue_diff,

  CASE
    WHEN ABS(fact.revenue_fact - mart_revenues.revenue_mart) <= 0.01 THEN 'PASS'
    ELSE 'FAIL - revenue mismatch'
  END AS status

FROM mart_revenues
CROSS JOIN fact
ORDER BY mart_name;


-- ============================================================
-- 10. RÉCONCILIATION DU NOMBRE DE TRANSACTIONS ENTRE FACT ET MARTS
-- ============================================================

WITH fact AS (
  SELECT
    COUNT(*) AS transactions_fact
  FROM `myprojet-485110.coffee_mart.fct_transactions`
),

mart_transactions AS (
  SELECT
    'mart_sales_overview_daily' AS mart_name,
    SUM(total_transactions) AS transactions_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_overview_daily`

  UNION ALL

  SELECT
    'mart_sales_by_product' AS mart_name,
    SUM(total_transactions) AS transactions_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_product`

  UNION ALL

  SELECT
    'mart_sales_by_time_of_day' AS mart_name,
    SUM(total_transactions) AS transactions_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_time_of_day`

  UNION ALL

  SELECT
    'mart_sales_by_weekday' AS mart_name,
    SUM(total_transactions) AS transactions_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_weekday`

  UNION ALL

  SELECT
    'mart_sales_by_hour' AS mart_name,
    SUM(total_transactions) AS transactions_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_hour`

  UNION ALL

  SELECT
    'mart_sales_by_year_month' AS mart_name,
    SUM(total_transactions) AS transactions_mart
  FROM `myprojet-485110.coffee_mart.mart_sales_by_year_month`
)

SELECT
  mart_name,
  fact.transactions_fact,
  mart_transactions.transactions_mart,
  fact.transactions_fact - mart_transactions.transactions_mart AS transaction_diff,

  CASE
    WHEN fact.transactions_fact = mart_transactions.transactions_mart THEN 'PASS'
    ELSE 'FAIL - transaction count mismatch'
  END AS status

FROM mart_transactions
CROSS JOIN fact
ORDER BY mart_name;


-- ============================================================
-- 11. CONTRÔLE DES MARTS : VALEURS NÉGATIVES OU INCOHÉRENTES
-- ============================================================

WITH mart_quality_checks AS (
  SELECT
    'mart_sales_overview_daily' AS mart_name,
    COUNTIF(total_revenue < 0) AS negative_revenue_rows,
    COUNTIF(total_transactions <= 0) AS invalid_transaction_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_overview_daily`

  UNION ALL

  SELECT
    'mart_sales_by_product' AS mart_name,
    COUNTIF(total_revenue < 0) AS negative_revenue_rows,
    COUNTIF(total_transactions <= 0) AS invalid_transaction_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_product`

  UNION ALL

  SELECT
    'mart_sales_by_time_of_day' AS mart_name,
    COUNTIF(total_revenue < 0) AS negative_revenue_rows,
    COUNTIF(total_transactions <= 0) AS invalid_transaction_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_time_of_day`

  UNION ALL

  SELECT
    'mart_sales_by_weekday' AS mart_name,
    COUNTIF(total_revenue < 0) AS negative_revenue_rows,
    COUNTIF(total_transactions <= 0) AS invalid_transaction_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_weekday`

  UNION ALL

  SELECT
    'mart_sales_by_hour' AS mart_name,
    COUNTIF(total_revenue < 0) AS negative_revenue_rows,
    COUNTIF(total_transactions <= 0) AS invalid_transaction_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_hour`

  UNION ALL

  SELECT
    'mart_sales_by_year_month' AS mart_name,
    COUNTIF(total_revenue < 0) AS negative_revenue_rows,
    COUNTIF(total_transactions <= 0) AS invalid_transaction_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_year_month`
)

SELECT
  mart_name,
  negative_revenue_rows,
  invalid_transaction_rows,

  CASE
    WHEN negative_revenue_rows = 0 AND invalid_transaction_rows = 0 THEN 'PASS'
    ELSE 'FAIL - mart contains invalid values'
  END AS status

FROM mart_quality_checks
ORDER BY mart_name;


-- ============================================================
-- 12. CONTRÔLE DES TICKETS MOYENS DANS LES MARTS
-- Objectif :
-- Vérifier que avg_transaction_value correspond bien à :
-- total_revenue / total_transactions
-- ============================================================

WITH avg_checks AS (
  SELECT
    'mart_sales_overview_daily' AS mart_name,
    COUNTIF(
      ABS(avg_transaction_value - SAFE_DIVIDE(total_revenue, total_transactions)) > 0.01
    ) AS avg_mismatch_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_overview_daily`

  UNION ALL

  SELECT
    'mart_sales_by_product' AS mart_name,
    COUNTIF(
      ABS(avg_transaction_value - SAFE_DIVIDE(total_revenue, total_transactions)) > 0.01
    ) AS avg_mismatch_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_product`

  UNION ALL

  SELECT
    'mart_sales_by_time_of_day' AS mart_name,
    COUNTIF(
      ABS(avg_transaction_value - SAFE_DIVIDE(total_revenue, total_transactions)) > 0.01
    ) AS avg_mismatch_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_time_of_day`

  UNION ALL

  SELECT
    'mart_sales_by_weekday' AS mart_name,
    COUNTIF(
      ABS(avg_transaction_value - SAFE_DIVIDE(total_revenue, total_transactions)) > 0.01
    ) AS avg_mismatch_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_weekday`

  UNION ALL

  SELECT
    'mart_sales_by_hour' AS mart_name,
    COUNTIF(
      ABS(avg_transaction_value - SAFE_DIVIDE(total_revenue, total_transactions)) > 0.01
    ) AS avg_mismatch_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_hour`

  UNION ALL

  SELECT
    'mart_sales_by_year_month' AS mart_name,
    COUNTIF(
      ABS(avg_transaction_value - SAFE_DIVIDE(total_revenue, total_transactions)) > 0.01
    ) AS avg_mismatch_rows
  FROM `myprojet-485110.coffee_mart.mart_sales_by_year_month`
)

SELECT
  mart_name,
  avg_mismatch_rows,

  CASE
    WHEN avg_mismatch_rows = 0 THEN 'PASS'
    ELSE 'FAIL - avg_transaction_value mismatch'
  END AS status

FROM avg_checks
ORDER BY mart_name;


-- ============================================================
-- 13. APERÇU DES MARTS POUR CONTRÔLE VISUEL
-- Ces requêtes ne sont pas des tests bloquants.
-- Elles servent à vérifier rapidement la cohérence métier.
-- ============================================================

SELECT *
FROM `myprojet-485110.coffee_mart.mart_sales_by_product`
ORDER BY total_revenue DESC;

SELECT *
FROM `myprojet-485110.coffee_mart.mart_sales_by_weekday`
ORDER BY weekday_sort;

SELECT *
FROM `myprojet-485110.coffee_mart.mart_sales_by_hour`
ORDER BY hour_of_day;

SELECT *
FROM `myprojet-485110.coffee_mart.mart_sales_by_year_month`
ORDER BY year_month_date;
