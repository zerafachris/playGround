# Deploying ML Classifier as an API using Flask

In this repository, I demonstrate how to deploy a machine learning classifier as an API using Flask for production use.

## Task
The task is to predict whether a loan application will be approved or denied using a provided dataset. The dataset used for this task is available as the [Loan Prediction Dataset](https://github.com/PayelGanguly96/Loan-Prediction).

## Repository Contents

### [1_PreProcess_Model_Serialize](https://github.com/zerafachris/playGround/blob/master/published/deployingML/1_PreProcess_Model_Serialize.ipynb)
This notebook contains the following steps:
- **Pre-processing Flow**: Data cleaning and feature engineering.
- **Model Creation**: Training a machine learning model to predict loan approval.
- **Serialization**: Saving the trained model using joblib for later use in the Flask API.

### Flask API Overview
Once the model is serialized, we integrate it into a Flask application:
- The Flask app runs on **http://0.0.0.0:5000**.
- A **POST method** is exposed at `/predict`, which takes input data and returns a JSON response.
- The response contains a dictionary with predicted outcomes, where:
  - `1` represents *Approved*.
  - `0` represents *Denied*.

## Usage
To use this API:
1. Run the Flask application.
2. Send a POST request to `http://0.0.0.0:5000/predict` with the input data.
3. The response will be a JSON containing the predicted approval status.

Explore the full project [here](https://github.com/zerafachris/playGround/blob/master/published/deployingML/0_readme.ipynb).
