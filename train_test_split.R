# function that takes in a dataset and a given fraction out of 1.0, spits 
# out a list of dataframes: train and test
train_test_split <- function(data, frac) 
{
    # split out training data, convert status to factor
    train_raw <- data %>% sample_frac(frac)
    train_raw$loan_status <- as.factor(train_raw$loan_status)
    
    # testing data, convert status to factor
    test_raw <- anti_join(data, train_raw, by='id')
    test_raw$loan_status <- as.factor(test_raw$loan_status)

    # return training and testing data
    return(list(train_data=train_raw, test_data=test_raw))
}