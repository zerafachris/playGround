# Introduction
The goal of these notebooks serves to show: 
1. A very simple sentiment analysis application built using [TF-IDF](https://en.wikipedia.org/wiki/Tf%E2%80%93idf) and sentiment classification using Logistic Regression, 
1. Sentiment will be language agnostic, and
1. Deployment and servicing of an ML model model on [PythonAnywhere](https://www.pythonanywhere.com).
1. Use of [Swagger UI](https://swagger.io/tools/swagger-ui/) to encapsulate the API 

You can test out the application [here](https://mybinder.org/v2/gh/zerafachris/playGround/master?filepath=published%2FsentimentAnalysisApp%2F04_interactive_sentiment_analysis.ipynb) by using [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/zerafachris/playGround/master?filepath=published%2FsentimentAnalysisApp%2F04_interactive_sentiment_analysis.ipynb)


# Sentiment Analysis Application
The ML model I wanted to build here makes use of Term Frequency – Inverse Document Frequency (TF-IDF) and use this to get the sentiment of reviews left by people reviewing my GitHub page.

## Data - [01_create_data.ipynb](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/01_create_data.ipynb)
I did not have sentiment data, but page reviews could be considered to be similar to *movie* reviews. Thus, I used the [Large Movie Review Dataset](https://ai.stanford.edu/~amaas/data/sentiment/). This is a set of 50,000 movie reviews and respective binary labels for sentiment. Getting and downloading of this data can be done via [01_create_data.ipynb](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/01_create_data.ipynb). Below you can see a data sample:


```python
import pandas as pd
df = pd.read_csv('./data/test.csv').head(2)
for sent, rev in zip(df['sentiment'], df['review']):
    print('''
    Sentiment: {}
    Review: {}\n'''.format(sent, rev))    
```

    
        Sentiment: pos
        Review:  Years ago when I first read John Irving s The World According to Garp I was astounded that most of the younger adults with whom I had contact didn t like the book when I loved it I began to understand that it was an age and experience thing I experienced somewhat of a d j vu when reading some of the comments on this site that were clearly written by younger viewers Fully enjoying Separate Lies is surely an age and experience thing br br In this film the viewer sees a seemingly happy upper middle class couple he a successful lawyer she the perfect wife of a successful lawyer They have a townhouse in London and a home in the country All s well until there enters the villain in the guise of the son of the richest man in the village This guy appears to be a cad from the word Go He is disdainful of everyone and everything including his own children In the traditional form of nice guys finishing last the lawyer s wife engages in an affair with the bounder You see the lawyer really is a nice guy but with the marriage killing trait of an organized perfectionist Even though he truly loves her he is boring his wife to death The bad boy is far more exciting br br All of this is entangled with the hit and run death of a man in the village in which all the facts point to the cad being the driver of the vehicle br br It s easy to determine that this movie doesn t build to a happy ending however it does lead to a very satisfying ending in that the man and his wife learn and grow from their experiences and probably will be able to conduct their personal lives in a more successful manner br br Three excellent actors play the main characters in this film and it is there performances that make the whole thing a pleasure to watch Tom Wilkinson is perfect as the husband His portrayal shows us a kind man who has so much control over his emotions that he has lost touch with the world Emily Watson shows us a woman who has become so trapped in the role of perfect wife that she has almost lost her knowledge of passion That passion is reborn by the character deftly played by Rupert Everett br br If you have reached that point in life in which you understand that everyone has feet of clay and that everyone even with the gifts of intelligence and opportunities makes many many wrong decisions then you will probably enjoy watching these excellent actors creating the lives of three such people This is a beautifully acted and directed adult film about realistic adults 
    
    
        Sentiment: neg
        Review:  Sometimes changes to novels when they re made into films are not only necessary but a good thing However in the case of Northanger Abbey it s a very very bad thing Not only is the story itself ripped to shreds but the satire is almost completely absent from the film and it s mixture of romance and intrigue doesn t even touch upon the biting commentary that Austen put into her work It fails to be amusing or satirical at all and instead turns the character s fascination with her fantasy world into mostly a drama br br This affects the romance as well It s meandering and aimless Chemistry and interest are never established The reasons Tilney is attracted to Catherine are completely absent from the film leaving the audience to wonder what it is he sees in her at all br br Hopefully some day soon we ll get a more faithful version if Austen s satire 
    


## Model Development - [02_TF_IDF.ipynb](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/02_TF_IDF.ipynb)
The sentiment analysis model utilizes **TF-IDF** to convert the text into numerical features and **Logistic Regression (LR)** for classification. Various pre-processing steps were applied to the data, including:

- Removing HTML tags
- Removing non-letter characters
- Converting text to lowercase
- Tokenization
- Stemming using [NLTK](https://www.nltk.org/)

### Model Performance
The following classification models were tested with their respective **roc_auc** scores:

|   Modelling  | Score (**roc_auc**) |
|-----|:------:|
| Support Vector Machine - Linear|      0.969465 |
| Naive Bayes Classifier - Bernoulli |      0.941231 |
| Multi-Layer Perceptron (MLP) |      0.968113 |
|  Logistic Regrssion (LR)  |   0.969760  |

**Logistic Regression** provided the best **roc_auc** score and was selected as the final model.

## Productionisation - [03_TF_IDF_prod_lr.ipynb](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/03_TF_IDF_prod_lr.ipynb)
This notebook outlines the steps to prepare the model for production, including the creation of pipelines for deploying the machine learning model.

### Deployment - PythonAnywhere
The application was deployed on **PythonAnywhere**, allowing users to interact with the model via a RESTful API. The API is documented and can be tested using [**Swagger UI**](https://swagger.io/tools/swagger-ui/).

You can explore the interactive application on [Binder](https://mybinder.org/v2/gh/zerafachris/playGround/master?filepath=published%2FsentimentAnalysisApp%2F04_interactive_sentiment_analysis.ipynb).

## Conclusion
This project demonstrates how to build, train, and deploy a sentiment analysis model using basic NLP techniques. The deployment on PythonAnywhere with API integration via Swagger UI makes the application accessible for real-world use cases.

For more details, refer to the full notebooks:

- [Data Creation](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/01_create_data.ipynb)
- [TF-IDF and Model Building](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/02_TF_IDF.ipynb)
- [Production Pipelines](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/03_TF_IDF_prod_lr.ipynb)