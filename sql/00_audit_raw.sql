-- Compter les lignes
SELECT COUNT(*) AS row_count
FROM `myprojet-485110.coffee_raw.transactions_raw`;


-- Aperçu rapide
SELECT *
FROM `myprojet-485110.coffee_raw.transactions_raw`
LIMIT 10;

-- Vérifier les valeurs de paiement
SELECT
  cash_type,
  COUNT(*) AS transactions
FROM `myprojet-485110.coffee_raw.transactions_raw`
GROUP BY cash_type
ORDER BY transactions DESC;


--Vérifier les produits
SELECT
  coffee_name,
  COUNT(*) AS transactions
FROM `myprojet-485110.coffee_raw.transactions_raw`
GROUP BY coffee_name
ORDER BY transactions DESC;

-- Vérifier les montants nuls ou négatifs
SELECT
  COUNTIF(money IS NULL) AS null_money,
  COUNTIF(money < 0) AS negative_money
FROM `myprojet-485110.coffee_raw.transactions_raw`;

--Vérifier les dates min / max
SELECT
  MIN(Date) AS min_date,
  MAX(Date) AS max_date
FROM `myprojet-485110.coffee_raw.transactions_raw`;

--Vérifier Time_of_Day
SELECT
  Time_of_Day,
  COUNT(*) AS transactions
FROM `myprojet-485110.coffee_raw.transactions_raw`
GROUP BY Time_of_Day
ORDER BY transactions DESC;

--Vérifier Weekday + Weekdaysort
SELECT DISTINCT
  Weekday,
  Weekdaysort
FROM `myprojet-485110.coffee_raw.transactions_raw`
ORDER BY Weekdaysort;


-- Vérifier Month_name + Monthsort
SELECT DISTINCT
  Month_name,
  Monthsort
FROM `myprojet-485110.coffee_raw.transactions_raw`
ORDER BY Monthsort;
