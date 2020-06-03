# loan_defaults
Predicting Loan Default Rates

Data Source:
https://www.kaggle.com/husainsb/lendingclub-issued-loans
(Ultimate data source: LendingClub.com)

In this project I constructed a simple classification model to predict the likelihood of default (or some similar 'credit event') based on a given loan's characteristics (such as borrower age, salary, credit history, etc). 

This project contains one main script called 'loans.R', which makes use of functions stored in the '/functions' folder. These functions perform a variety of data cleansing and preprocessing tasks.

This 'process_data.R' script covers the data cleansing and processing part of this project. The script converts all the date features to a better format, removes non-informative features, converts categorial data to numeric, fills in missing or NA data, and creates some new features that could prove useful.

This dataset consists of a large number of features, many of which are correlated, so I applied a basic PCA to help produce more independent features (and help avoid overfitting). 

The specific algorithm I used in this project is a Binomial Generalized Linear Model (i.e. logistic regression or logit model).

Below are selected summary statistics of the results of the prediction against the actual statuses of the loans in the testing sample:

| Statistic: | Value: |
| ---------- | ------ |
| Accuracy | 0.9747 |
| Kappa | 0.7935 |
| Sensitivity | 0.9984 |
| Specificity | 0.6887 |

I am generally pleased with results of the prediction. The model has high sensitivity (recall), suggesting it correctly predicts true non-default loans over 99% of the time. It is very good at identifying a good credit risk. However, I am concerned with the specificity statistic, which at 0.6887 suggests that the model only correctly predicts defaulted loans about 69% of the time. The model is less accurate when identifying which loans will default. This is likely a symptom of the imbalanced class proportions in the sample (only 8% of loans in the full sample had defaulted). Ultimately the defaulted loans are the ones that we care about, so more research will be needed to help alleviate this issue. Fixes such as undersampling the non-defaulted loans in the training set are possible improvements. 

I added an undersampling algorithm before the PCA step that helps to balance the number of defaulted and non-defaulted loans in the sample. Below are updated summary statistics of the new prediction:

| Statistic: | Value: |
| ---------- | ------ |
| Accuracy | 0.8802 |
| Kappa | 0.7603 |
| Sensitivity | 0.9559 |
| Specificity | 0.8041 |

While the undersampling algorithm reduced the model's overall accuracy, the specifity rose to 0.80, which is an improvement of prediction ability in the cases for which we are most concerned (defaulted loans). Still, 0.80 suggests even more room for improvement--further research in model selection will be required to find the model that is best suited for this type of classification.
