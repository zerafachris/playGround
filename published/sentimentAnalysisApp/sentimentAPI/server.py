from flask import Flask
from flask_restplus import Api, Resource, fields
from sentimentAnalysis import sentiment_from_in_sentence

app = Flask(__name__)
api = Api(app,
          version='1.0',
          title='sentiment-analysis',
          description='Sentiment of a string'
          )

ns = api.namespace('sentiment-analysis-tfidf-lr',
                   description='Sentiment of a string using tfidf and lr'
                   )
api.model('sentiment-analysis-tfidf-lr',
          {'in_sentence': fields.String(readonly=True, description='Sentence for sentiment analysis')}
          )


@ns.route('/<string:in_sentence>')
@api.response(404, 'String not good.')
class Item(Resource):
    @api.response(200, 'Successful sentiment parse.')
    def get(self, in_sentence):
        """ Returns sentiment for the review (in_sentence).
           Try in_sentence = 'this is a good api'
        """
        return sentiment_from_in_sentence(in_sentence, 'model_sentiment_analysis.pk')


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
