# categorical variable to numeric
cat_to_num <- function(x) 
{
    x <- x %>%
        as.factor() %>%
        as.numeric()
    return(x)
}