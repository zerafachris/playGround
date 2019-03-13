#import os
import pandas as pd
import dill
import gzip
from flask import Flask, jsonify, request


# =============================================================================
# Custom Functions
# =============================================================================
from sklearn.base import BaseEstimator, TransformerMixin
from sklearn.preprocessing import LabelEncoder

class ColumnSelector(BaseEstimator, TransformerMixin):
    def __init__(self, columns):
        self.columns = columns

    def fit(self, X, y=None):
        return self

    def transform(self, X):
        return X[self.columns]

class ModifiedLabelEncoder(BaseEstimator, TransformerMixin):
    def __init__(self):
        pass
    
    def fit(self, X, y=None):
        return self

    def transform(self, X):
        le = LabelEncoder().fit(X)
        return le.transform(X).reshape(-1,1)

# =============================================================================
# Setting up the App
# =============================================================================
app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def apicall():
    try:
        test_json = request.get_json()
        test = pd.read_json(test_json, orient='records')

        #Getting the Loan_IDs separated out
        loan_ids = test['Loan_ID']

    except Exception as e:
        raise e

    clf = 'classify_model.pk'

    if test.empty:
        return(bad_request())
    else:
        #Load the saved model
        print("Load the model:")
        loaded_model = None
        with gzip.open('./model/'+clf ,'rb') as f:
            loaded_model = dill.load(f)

        print("Doing predictions:")
        predictions = loaded_model.predict(test)
        prediction_series = list(pd.Series(predictions))
        final_predictions = pd.DataFrame(list(zip(loan_ids, prediction_series)))
        responses = jsonify(predictions=final_predictions.to_json(orient="records"))
        responses.status_code = 200

        return (responses)


@app.errorhandler(400)
def bad_request(error=None):
    message = {'status': 400,
               'message': 'Bad Request: ' + request.url }
    resp = jsonify(message)
    resp.status_code = 400

    return resp