# COVID-19 Predictions for Malta

This repository contains a Jupyter notebook that tracks and predicts the spread of COVID-19 in Malta. The goal is to analyze the current state of the pandemic, explore trends, and build predictive models to understand the trajectory of the virus.

COVID-19 is a contagious respiratory virus that first started in Wuhan, China, in December 2019. For more information, you can visit the [WHO](https://www.who.int/emergencies/diseases/novel-coronavirus-2019) or [CDC](https://www.cdc.gov/coronavirus/2019-ncov).

## Contents
- Data loading and cleaning
- Time-series visualization for confirmed cases, deaths, and recoveries in Malta and worldwide
- Growth rate and mortality rate analysis
- Exponential and linear regression models for predicting future cases
- Use of Facebook Prophet for more advanced forecasting

## Key Features
- **Data Visualization**: Interactive visualizations for tracking the progress of the pandemic.
- **Modeling**: Multiple models used to predict the growth of COVID-19 cases in Malta, including exponential growth models and Prophet forecasting.
- **Growth Rate Analysis**: Tracking growth rates, recovery rates, and mortality rates for Malta and other countries.

## Dependencies

To run the code in this repository, make sure you have the following Python libraries installed:
- `numpy`
- `pandas`
- `matplotlib`
- `seaborn`
- `plotly`
- `folium`
- `fbprophet`
- `scipy`
- `sklearn`

These libraries can be installed via `pip`:
```bash
pip install numpy pandas matplotlib seaborn plotly folium fbprophet scipy scikit-learn
```

## Data
The notebook uses publicly available data from the following sources:

- **Confirmed cases**: Data on confirmed COVID-19 cases worldwide.
- **Deaths and recoveries**: Information on COVID-19 deaths and recoveries.

The data is retrieved from the (novel-corona-virus-2019)[./novel-corona-virus-2019-dataset] dataset.

## Code Overview
### Data Preprocessing
The dataset is loaded and cleaned, removing columns with missing data and restructuring it into a tidy format. The relevant columns are `Date`, `Country`, `Confirmed`, `Deaths`, and `Recoveries`.

### Visualizations
The code generates interactive time-series plots for confirmed cases, deaths, recoveries, and growth rates. Plotly is used for creating these visualizations, allowing the user to explore different metrics and track the trends over time.

### Growth Rate and Exponential Models
Exponential growth models are used to predict the future number of confirmed COVID-19 cases. Linear regression is applied to the most recent data to estimate growth rates, and forecasts are extrapolated based on these models.

### Facebook Prophet
A more advanced forecasting method, Prophet, is applied to model the growth of COVID-19 in Malta. Prophet is useful for capturing complex trends and changepoints in the data.

# Conclusion
This notebook demonstrates the use of data science techniques to analyze and predict the spread of COVID-19 in Malta. By understanding the trends and growth rates, we can make more informed decisions about how to respond to the pandemic.

For more information or questions about the analysis, feel free to open an issue or contact me directly.