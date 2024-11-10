# Simple Sentiment Analysis

This repository demonstrates a simple sentiment analysis application using **TF-IDF** for feature extraction and **Logistic Regression** for sentiment classification. The application is designed to be language-agnostic and is deployed on **PythonAnywhere** with an API encapsulated using **Swagger UI**. The full pipeline, from model development to deployment, is showcased here.

## Project Overview

This project aims to build a basic sentiment analysis application that:
1. Uses **TF-IDF** and **Logistic Regression** for sentiment classification.
2. Is language agnostic, meaning it can process text in various languages.
3. Deploys the model as a web service on **PythonAnywhere**.
4. Encapsulates the model API using **Swagger UI** for easy testing and interaction.

You can interact with the live application using this [Binder link](https://mybinder.org/v2/gh/zerafachris/playGround/master?filepath=published%2FsentimentAnalysisApp%2F04_interactive_sentiment_analysis.ipynb).

## Data Preparation - [01_create_data.ipynb](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/01_create_data.ipynb)

For sentiment analysis, we used the **Large Movie Review Dataset** from [Stanford AI](https://ai.stanford.edu/~amaas/data/sentiment/). This dataset contains 50,000 movie reviews, each labeled as positive or negative. The data was processed and cleaned, and a sample is shown below:
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
    


## ML modelling - [02_TF_IDF.ipynb](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/02_TF_IDF.ipynb)
### Pre-Processing
Initial  data is cleaned via pre-processing in the form of:
- Removing HTML tags,
- Removing non-letters,
- To lower case,
- Tokenization to each word,
- Stemming
    - Tokenization and Stemming was simplified by using Natural Language Toolkit ([NLTK](https://www.nltk.org/))

### TF-IDF application

### ML-modelling
I tried out multiple classification techniques. Results for this are given by:
	
|   Modelling  | Score (**roc_auc**) |
|-----|:------:|
| Support Vector Machine - Linear|      0.969465 |
| Naive Bayes Classifier - Bernoulli |      0.941231 |
| Multi-Layer Perceptron (MLP) |      0.968113 |
|  Logistic Regrssion (LR)  |   0.969760  |

LR was the quickest to model and produced the best **roc_auc** score. I decided to proceed with this. Alternatively, I could have considered having an ensemble of models. However, I feel this goes beyond the scope of this notebook.


## Productionization of App - [03_TF_IDF_prod_lr.ipynb](https://github.com/zerafachris/playGround/blob/master/published/sentimentAnalysisApp/03_TF_IDF_prod_lr.ipynb)
The next notebook prepares pipelines for productionization.

# App deployment
## PythonAnywhere



```python

```
