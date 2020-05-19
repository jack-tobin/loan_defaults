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
| Accuracy | 0.9831 |
| Kappa | 0.9224 |
| Sensitivity | 0.9995 |
| Specificity | 0.8758 |

The model is clearly good at predicting when a borrower will not default--it can identify a good credit risk. However, the model is only 87% accurate with respect to loans that are true defaults--bad credit risks are a bit trickier to detect. This is likely related to the skewed class proportions within the sample--non-defaulted loans are simply more common than defaulted loans. Accuracy metrics are likely skewed as a result, and more research is necessary to help alleviate this issue.
