import gzip
import re

import nltk
from bs4 import BeautifulSoup
from googletrans import Translator

nltk.download('punkt')
import dill as pickle
import json


def text_clean(in_sentence):
    in_sentence = BeautifulSoup(in_sentence, 'html.parser').get_text()  # Remove HTML tags.
    in_sentence = re.sub('[^a-zA-Z]', ' ', in_sentence)  # Remove non-letters
    in_sentence = in_sentence.lower()  # Lower case
    token = nltk.word_tokenize(in_sentence)  # Tokenize to each word.
    in_sentence = [nltk.stem.SnowballStemmer('english').stem(w) for w in token]  # Stemming
    # Join the words back into one string separated by space, and return the result.
    return " ".join(in_sentence)


def logResponse(in_sentence, prediction_label, response):
    import datetime
    with open('./log_request.txt', "a+") as f:
        f.write('{} - {} - {} - {} \n'.format(datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"), in_sentence,
                                              prediction_label, response))


def sentiment_from_in_sentence(in_sentence, sa_model, class_label=['Negative', 'Positive']):
    translated = Translator().translate(in_sentence, dest='en')
    with gzip.open(sa_model, 'rb') as f:
        loaded_model = pickle.load(f)
    prediction = loaded_model.predict([text_clean(translated.text)])[0]
    prediction_label = class_label[prediction]
    logResponse(in_sentence, prediction_label, prediction)  # add logging to the app
    return json.dumps({'prediction': str(prediction),
                       'prediction_label': prediction_label,
                       'lang_source': translated.src,
                       'translated_review': translated.text})
