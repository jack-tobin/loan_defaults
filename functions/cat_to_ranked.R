# function that converts a categorial variable with some implicit 
# ranking into a numeric variable. categories is a named number vector
# outlining the numeric assignment to each category
cat_to_ranked <- function(df, categories) 
{
    # turn df column into factor with levels given 
    # by names of categories object
    A <- factor(df, levels=names(categories))
    
    # values is the correspondig numeric value 
    values <- unname(categories)
    
    # return the df column but as anumeric variable
    return(values[A])
}
