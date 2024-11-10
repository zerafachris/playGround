.# ML Templates

A set of templates used for model selection for Binary- and Multi-Class Classification.

## Overview

This repository provides a set of templates for selecting machine learning models for classification tasks, particularly focusing on binary and multi-class classification problems. The templates guide you through importing your dataset, selecting the appropriate models, evaluating them using different metrics, and finalizing the best model using ensemble methods.

### High-Level Overview of the Templates

The steps in this template involve the following:

1. **Data Import & Preparation**: Load your dataset and split it into training and test sets.
2. **Model Selection**: Use various models such as Logistic Regression, Support Vector Classifier, Decision Trees, Random Forests, etc., and apply hyperparameter tuning using grid search.
3. **Evaluation**: Assess each model using metrics like recall, balanced accuracy, F1 score, and ROC AUC.
4. **Ensemble**: Combine the best-performing models into a voting classifier.
5. **Serialization**: Once the final model is selected, it can be serialized and saved for deployment.


## Conclusion
These templates ensures flexibility for various binary and multi-class classification tasks, guiding users step-by-step through data preparation, model selection, evaluation, and final deployment.
