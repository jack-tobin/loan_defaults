# convert mmm-yyyy dates to R dates
convert_dates <- function(x) 
{
    x <- x %>%
        paste0('01-', .) %>%
        as.Date('%d-%b-%Y')
    return(x)
}