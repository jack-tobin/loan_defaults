# function to convert dates in the format 'MMM-YYYY' (or '%b-%Y') to 
# R's internal date datatype
convert_dates <- function(x) 
{
    # take column, paste '01-' to the front, convert to date
    x <- x %>%
        paste0('01-', .) %>%
        as.Date('%d-%b-%Y')
    return(x)
}
