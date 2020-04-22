rm(list=ls())

# set working directory where files are stored
setwd('~/Documents/projects/loans')

# source related functions
source('cat_to_ranked.R')
source('cat_to_num.R')
source('convert_dates.R')
source('process_data.R')
source('train_test_split.R')
source('pca.R')
source('install_pkgs.R')

# packages
packages <- c('caret','tree','rpart','nnet','randomForest',
              'gbm','lars','tidyverse','ggplot2','e1071')
install.pkgs(packages)

# read in files from kaggle dataset
train_f <- file.path('data/lc_loan.csv')
loans <- read.csv(train_f, header=TRUE, sep=',', stringsAsFactors=FALSE) #, nrow=10000)

# function to process data from start to finish
loans_scrubbed <- process_data(loans)

# pca
loans.pca <- pca(loans_scrubbed)

# apply train test split
train_test <- train_test_split(loans.pca, 0.7)
train_ <- train_test$train_data
test_ <- train_test$test_data

# begin prediction using logistic regression
model <- caret::train(
    loan_status ~ ., 
    data=train_, 
    method='glm', 
    family='binomial'
)

# predict
pred <- predict(
    model,
    newdata=test_
)

# confusion matrix
conf_mat <- confusionMatrix(
    pred,
    test_$loan_status
)

conf_mat