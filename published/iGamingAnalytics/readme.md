# Early Segmentation for Online Casino Players

This repository provides an in-depth analysis and approach to segmenting online casino players and using these segments to optimize marketing campaigns. The notebook demonstrates the process of Exploratory Data Analysis (EDA) and early customer classification based on three provided datasets.

## Datasets Overview

The data used for this project consists of three datasets:

### 1. Transactions
This dataset contains hourly aggregated player transaction data from January to March 2017. The transactions are grouped into four types: wager, winning, deposit, and withdrawal. The amounts for deposits and winnings are positive, while wagers and withdrawals are negative.

| Field                | Description                                                             |
|----------------------|-------------------------------------------------------------------------|
| playerid             | Unique player identifier                                                |
| created_date_time    | Timestamp of the transaction (aggregated by hour)                       |
| account_currency     | Currency used in the account                                            |
| gameid               | Game played by the player                                               |
| cashier_method_id    | Payment method used by the player                                        |
| account_type         | Indicates the type of transaction ('CASH%' or 'BONUS%')                 |
| trans_type           | Type of transaction (wager, winning, deposit, withdraw)                 |
| payment_status       | Status of the transaction (accepted = successful)                       |
| payment_result_code  | Detailed transaction status                                             |
| payment_channel      | Transaction channel (mobile or desktop)                                 |
| transaction_count    | Number of transactions aggregated                                       |
| account_amount       | Amount in the account currency                                          |

### 2. Player Details
This dataset contains player-specific details such as sign-up date, demographic data, and financial activity.

| Field              | Description                                                                |
|--------------------|----------------------------------------------------------------------------|
| playerid           | Unique player identifier                                                   |
| signup_completed   | Date the player signed up                                                  |
| first_deposit      | Date of the first successful deposit (null values = '1900-01-01')          |
| first_deposit_amt  | Amount of the first deposit                                                |
| city               | Player's city                                                              |
| birth_date         | Player's birthdate                                                         |
| gender             | Player's gender                                                            |

### 3. Games
This dataset contains details about the games available to players.

| Field              | Description                                                                |
|--------------------|----------------------------------------------------------------------------|
| gameid             | Unique game identifier                                                     |
| gameid_root        | Root identifier for games available across different platforms (desktop, mobile) |
| categoryid         | ID of the game category (e.g., slots, table games)                         |
| rtp                | Return to Player (RTP) for the game                                         |
| channel            | Platform on which the game is available (desktop or mobile)                |
| categorycode       | Type of game (e.g., slots, table games, etc.)                              |

## Objective

Given these datasets (transactions, player details, and games), the goal is to segment players effectively and provide actionable insights for targeting marketing campaigns.

## Notebooks

### [1_get_data](https://github.com/zerafachris/playGround/blob/master/published/iGamingAnalytics/1_get_data.ipynb)

This notebook handles data cleaning and augmentation. The cleaned datasets are saved in the *./cleanedData/* directory.

Key operations performed:
- **Player Dataset:**
  - Renaming a city field value to correct an anomaly.
  - Adding city and country information based on third-party datasets.
  - Adding player age-related features.
- **Transaction Dataset:**
  - Aggregating the transaction data from multiple CSV files.
  - Converting transaction amounts to EUR.
  - Adding time-based features.
- **Games Data:**
  - No alterations were made.

### [2_viz_data](https://github.com/zerafachris/playGround/blob/master/published/iGamingAnalytics/2_viz_data.ipynb)

In this notebook, Exploratory Data Analysis (EDA) is conducted with visualizations focusing on:
- Daily transaction volumes.
- Busiest game categories.
- Player demographics and their playing habits.

### [3_player_classification_data_prep](https://github.com/zerafachris/playGround/blob/master/published/iGamingAnalytics/3_early_player_classification_data_prep.ipynb)

This notebook prepares the dataset for player classification. Features are derived from:
- **Geographic & Demographic Traits**
- **Behavioral Traits**
- **Value Traits**

The final dataset includes 17,313 unique player profiles.

### [4_early_player_classification_modelling](https://github.com/zerafachris/playGround/blob/master/published/iGamingAnalytics/4_early_player_classification_modelling.ipynb)

The final notebook focuses on clustering and classification of players:
1. **Clustering players:** 
   - K-Means clustering is used to group players into clusters based on their features.
   - The optimal number of clusters is determined using the Silhouette Coefficient and visualized using radar charts and t-SNE plots.
2. **Building a Classification Model:**
   - Multiple models are tested, including Support Vector Machine (SVM), Logistic Regression (LR), k-Nearest Neighbors (KNN), Decision Tree (DT), Random Forest (RF), Gradient Boosting (GB), and an Ensemble Model.
   - Precision scores for each model are as follows:
   
| Model                     | Precision |
|---------------------------|-----------|
| Support Vector Machine     | 98.50%    |
| Logistic Regression        | 98.96%    |
| k-Nearest Neighbors        | 97.75%    |
| Decision Tree              | 90.01%    |
| Random Forest              | 98.73%    |
| Gradient Boosting          | 99.25%    |
| Voting Classifier          | 99.19%    |

## Conclusion

This repository demonstrates an end-to-end process for segmenting online casino players and building a model to optimize marketing campaigns based on player behaviour and demographics.
