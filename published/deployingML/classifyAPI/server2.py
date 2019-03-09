#import os
import pandas as pd
import dill as pickle
from flask import Flask, jsonify, request
from sklearn.base import BaseEstimator, TransformerMixin
import warnings
warnings.filterwarnings("ignore")


# =============================================================================
# PreProcessing
# =============================================================================
class PreProcessing(BaseEstimator, TransformerMixin):
    def __init__(self):
        pass

    def transform(self, df, y=None):
        pred_var = ['Gender','Married','Dependents','Education','Self_Employed','ApplicantIncome',
                    'CoapplicantIncome','LoanAmount','Loan_Amount_Term','Credit_History','Property_Area']

        df = df[pred_var]

        df['Dependents'] = df['Dependents'].fillna(0)
        df['Self_Employed'] = df['Self_Employed'].fillna('No')
        df['Loan_Amount_Term'] = df['Loan_Amount_Term'].fillna(self.term_mean_)
        df['Credit_History'] = df['Credit_History'].fillna(1)
        df['Married'] = df['Married'].fillna('No')
        df['Gender'] = df['Gender'].fillna('Male')
        df['LoanAmount'] = df['LoanAmount'].fillna(self.amt_mean_)

        gender_values = {'Female' : 0, 'Male' : 1}
        married_values = {'No' : 0, 'Yes' : 1}
        education_values = {'Graduate' : 0, 'Not Graduate' : 1}
        employed_values = {'No' : 0, 'Yes' : 1}

        col_OHE = ['Property_Area','Dependents']
        for col in col_OHE:
            for enum, lbl in enumerate(set(df[col])):
                col_name = col+'_'+lbl
                Xt = df[col].replace(lbl,1)
                Xt[Xt!=1]=0
                df[col_name] = Xt
        df.drop(col_OHE, axis=1, inplace=True)

        df.replace({'Gender': gender_values,
                    'Married': married_values,
                    'Education': education_values,
                    'Self_Employed': employed_values
                   }, inplace=True)

        # Standard Scalar for Continuous Functions
        colCONT = ['ApplicantIncome','CoapplicantIncome','LoanAmount', 'Loan_Amount_Term']
        for col in colCONT:
            df[col] = (df[col] - df[col].mean())/df[col].std(ddof=0)

        return df

    def fit(self, df, y=None):
        self.term_mean_ = df['Loan_Amount_Term'].mean()
        self.amt_mean_ = df['LoanAmount'].mean()

        return self

# =============================================================================
# Setting up the App
# =============================================================================
app = Flask(__name__)

@app.route('/predict', methods=['POST'])
def apicall():
	"""API Call"""
	try:
		test_json = request.get_json()
		test = pd.read_json(test_json, orient='records')

		#Getting the Loan_IDs separated out
		loan_ids = test['Loan_ID']

	except Exception as e:
		raise e

	clf = 'classify_model2.pk'

	if test.empty:
		return(bad_request())
	else:
		#Load the saved model
		print("Load the model:")
		loaded_model = None
		with open('./model/'+clf,'rb') as f:
			loaded_model = pickle.load(f)

		print("Doing predictions:")
		predictions = loaded_model.predict(test)

		prediction_series = list(pd.Series(predictions))

		final_predictions = pd.DataFrame(list(zip(loan_ids, prediction_series)))

		responses = jsonify(predictions=final_predictions.to_json(orient="records"))
		responses.status_code = 200

		return (responses)


@app.errorhandler(400)
def bad_request(error=None):
	message = {
			'status': 400,
			'message': 'Bad Request: ' + request.url }
	resp = jsonify(message)
	resp.status_code = 400

	return resp