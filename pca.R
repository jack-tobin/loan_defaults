# pca function
pca <- function(data) 
{
    # remove zero variance columns from the dataset
    data <- data[ , which(apply(data, 2, var) != 0)]
    
    # begin to process for prediction
    y <- data[, c('id','loan_status')]
    X <- data[, !(names(data) %in% c('loan_status'))]

    # scale data using PCA--without id
    X.pca <- prcomp(X[, 2:length(X[1, ])], center=TRUE, scale=TRUE)$x %>%
        as.data.frame()
    
    # add id and status back
    data.pca <- cbind(X$id, y$loan_status, X.pca)
    colnames(data.pca) <- c('id','loan_status', colnames(X.pca))
    
    return(data.pca)
}