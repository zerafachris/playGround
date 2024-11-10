# House Price Prediction for the Maltese Market

This project was put together for the [Data X - An Introduction to Data Science: Storage, Visualisation and Analysis](https://www.um.edu.mt/courses/studyunit/las3004). It used data scraped from the [Times of Malta Property](https://www.timesofmalta.com/classifieds/property-for-sale) page between April 2015 and November 2016. The code is available [here](https://github.com/zerafachris/playGround/tree/master/published/maltaHousePricing/code).

## Exploratory Data Analysis (EDA)

The dataset consisted of 78 HTML files, with a 3.1MB gzip archive. Key observations include:
- 75% of the data was scraped within a 7-day interval.
- 58% of the data was extracted on Mondays.

### Key Extracted Features:
- **Date Features:** Month, Day Number, Year, Quarter.
- **Locality:** After cleaning and grouping similar localities, 110 unique localities remained.
- **Districts:** Six statistical districts identified (Western, Northern, North Harbour, South Eastern, South Harbour, Gozo).
- **Property Type:** Grouped into House, Villa, Commercial, Maisonette, and Apartment.
- **Additional Features:** Phone, Bedrooms, Garage, Shell, Furnished, Pool, Ensuite, Bathrooms.
- **Price:** Imputed with mean values separated by locality, type, and other features. Outliers were removed using median filtering.

### Key Observations:
- Higher-priced properties are concentrated in Northern and North Harbour areas.
- Villas are more expensive than garages.
- The best time to buy property is in April and July, while February, March, May, and December are the most expensive months.

## Categorical Features Analysis
- **Locality Distribution:** 93.5% of properties are in Malta, with the rest in Gozo.
- **Market Trends:** North Harbour is the most active, and the market is heavily saturated with apartments.

## Continuous Features Analysis
- Most properties have 2+ bedrooms and bathrooms.
- Owning a pool or an ensuite is uncommon, seen as a luxury.
- The price distribution is heavily skewed, and log transformation is recommended for a better fit.

## Correlation Matrix
- The highest correlation was found between **POOL** and **PRICE**.
- Scatter plots show no strong linear correlations.

## Modelling

The dataset was split into:
- **90%** for training.
- **10%** for testing.

Models used:
- **Ridge Regression**: All coefficients must exist and be constrained to positive or negative values.
- **Lasso Regression**: Some coefficients can be set to zero.

### Model Results:
The model's **RMSE** was €128,204, indicating poor performance.

## Way Forward
- Scaling of data.
- Adding additional features, such as proximity to public transport or the number of registered companies in the locality.
- Experimenting with **XGBoost** and feature selection using **Boruta**.

Explore the full project [here](https://github.com/zerafachris/playGround/blob/master/published/maltaHousePricing/00_MaltaHousePrices.ipynb).
