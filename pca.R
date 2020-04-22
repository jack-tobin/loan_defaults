# function to apply principal component analysis to the features
# returns dataframe with original ID and status but features
# have been converted into principal components
pca <- function(data) 
{
    # remove zero variance columns from the dataset
    data <- data[ , which(apply(data, 2, var) != 0)]
    
    # separate out y and X variables. y is just the ID and 
    # status, X is everything but status
    y <- data[, c('id','loan_status')]
    X <- data[, !(names(data) %in% c('loan_status'))]    
    
    # apply PCA, convert to dataframe
    X.pca <- prcomp(X[, 2:length(X[1, ])], center=TRUE, scale=TRUE)$x %>%
        as.data.frame()
    
    # add id and status back to transformed data
    data.pca <- cbind(X$id, y$loan_status, X.pca)
    colnames(data.pca) <- c('id','loan_status', colnames(X.pca))    
    
    return(data.pca)
}