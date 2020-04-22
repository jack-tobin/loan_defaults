# function to convert a categorial variable to a factor, but 
# by using numeric datatype rather than Factor datatype
cat_to_num <- function(x) 
{
    # take column, turn into factor then into numeric
    x <- x %>%
        as.factor() %>%
        as.numeric()
    return(x)
}