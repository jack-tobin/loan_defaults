# train test split function
train_test_split <- function(data, frac) 
{
    # split out training data
    train_raw <- data %>% sample_frac(frac)
    train_raw$loan_status <- as.factor(train_raw$loan_status)
    
    # testing data
    test_raw <- anti_join(data, train_raw, by='id')
    test_raw$loan_status <- as.factor(test_raw$loan_status)

    return(list(train_data=train_raw, test_data=test_raw))
}