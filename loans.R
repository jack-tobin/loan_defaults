# set working directory
setwd('~/Documents/projects/loans')

# source related functions - these are stored in the wd
source('functions/cat_to_ranked.R')
source('functions/cat_to_num.R')
source('functions/convert_dates.R')
source('functions/process_data.R')
source('functions/train_test_split.R')
source('functions/pca.R')
source('functions/install_pkgs.R')

# packages we'll need for the analysis
packages <- c('caret','tree','rpart','nnet','randomForest',
              'gbm','lars','tidyverse','ggplot2','e1071','UBL')
install_pkgs(packages)

# read in files from kaggle dataset
# source: https://www.kaggle.com/husainsb/lendingclub-issued-loans
train_f <- file.path('data/lc_loan.csv')
loans <- read.csv(train_f, header=TRUE, sep=',', stringsAsFactors=FALSE)

# apply processing function to the raw data
loans_scrubbed <- process_data(loans)

# undersample the majority class to help with balance issues
loans_balanced <- RandUnderClassif(
  loan_status ~ ., 
  loans_scrubbed, 
  'balance'
)

# apply principal component analysis
loans_pca <- pca(loans_balanced)

# apply train test split function to partition the data
train_test <- train_test_split(loans_pca, 0.7)
train_ <- train_test$train_data
test_ <- train_test$test_data

# begin binary classification using logistic regression
model <- caret::train(
    loan_status ~ ., 
    data=train_, 
    method='glm', 
    family='binomial'
)

# predict using testing data
pred <- predict(
    model,
    newdata=test_
)

# create confusion matrix to show results
conf_mat <- confusionMatrix(
    pred,
    test_$loan_status
)
print(conf_mat)
