# Description du dataset

## Source du dataset

Le dataset utilisé dans ce projet provient d’un dataset public Kaggle consacré aux ventes d’un coffee shop.

Il s’agit d’un dataset transactionnel simple, adapté à un projet de **Sales Analytics / Business Intelligence**, avec des informations sur :
- la date de vente,
- l’heure de vente,
- le produit vendu,
- le montant de la transaction,
- le moment de la journée,
- le jour de semaine,
- le mois

---

## Colonnes disponibles

Le dataset contient les colonnes suivantes :

- **hour_of_day** : heure de la transaction, de 0 à 23
- **cash_type** : mode de paiement
- **money** : montant de la transaction
- **coffee_name** : produit vendu
- **Time_of_Day** : moment de la journée (`Morning`, `Afternoon`, `Night`)
- **Weekday** : jour de la semaine
- **Month_name** : mois
- **Weekdaysort** : ordre numérique du jour de semaine
- **Monthsort** : ordre numérique du mois
- **Date** : date de transaction
- **Time** : heure exacte de transaction

---

## Grain de la donnée

Le grain analytique principal du dataset est :

**1 ligne = 1 transaction de vente**

Cela signifie que chaque ligne représente une vente individuelle, avec :
- une date,
- une heure,
- un produit,
- et un montant associé.

---

## Période couverte

Le dataset couvre la période suivante :

- **date minimale** : `2024-03-01`
- **date maximale** : `2025-03-23`

L’analyse porte donc sur un peu plus d’un an d’activité.

---

## Limites du dataset

Le dataset présente plusieurs limites importantes à garder en tête dans l’interprétation des résultats :

### 1. Pas d’identifiant client
Le dataset ne contient pas de `customer_id`.

Conséquence :
- impossible d’analyser la fidélité client,
- impossible de mesurer le réachat,
- impossible de construire des cohortes clients.

### 2. Pas de coût ni de marge
Le dataset contient le montant des transactions, mais pas :
- le coût produit,
- la marge,
- les frais opérationnels.

Conséquence :
- l’analyse porte sur le **chiffre d’affaires**, pas sur la **profitabilité**.

### 3. Un seul mode de paiement observé
Dans ce dataset, toutes les transactions observées sont associées au mode de paiement `card`.

Conséquence :
- aucune analyse comparative pertinente n’est possible sur les moyens de paiement.

### 4. Mois partiels au début et à la fin de la période
Le dataset commence le **1er mars 2024** et s’arrête le **23 mars 2025**.

Conséquence :
- **mars 2024** et **mars 2025** sont des mois partiels,
- les comparaisons mensuelles doivent donc être interprétées avec prudence.

### 5. Pas de contexte magasin plus détaillé
Le dataset ne contient pas d’informations sur :
- le stock,
- le personnel,
- les promotions,
- la localisation de plusieurs points de vente.

Conséquence :
- les recommandations restent centrées sur les **patterns de ventes** et non sur l’ensemble de la performance opérationnelle.
