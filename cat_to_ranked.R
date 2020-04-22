# categorical to ranked numeric
cat_to_ranked <- function(df, categories) 
{
    A <- factor(df, levels=names(categories))
    values <- unname(categories)
    return(values[A])
}