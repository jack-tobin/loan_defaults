# function to scrub loan data, mostly convert to numeric where applicable
process_data <- function(loan_data) 
{

# drop cols right off the bat
drop_cols <- c('emp_title','member_id','url','desc','title',
               'zip_code','sub_grade', 'initial_list_status','policy_code')
loan_data <- loan_data[, -which(names(loan_data) %in% drop_cols)]

# convert issue_d to date
loan_data$issue_d <- loan_data$issue_d %>% convert_dates()

# specify date data is as of
max_dt <- as.Date('2015-12-01')

# fill nas here with max date
loan_data[which(is.na(loan_data$earliest_cr_line)), 'earliest_cr_line'] <- max_dt

# fill.nas with zeros
fill_zero_cols <- c('annual_inc','delinq_2yrs','tot_coll_amt','tot_cur_bal',
                    'open_acc','pub_rec','total_acc','revol_util','open_acc_6m',
                    'open_il_6m','open_il_12m','open_il_24m','acc_now_delinq',
                    'mths_since_rcnt_il','collections_12_mths_ex_med','total_bal_il',
                    'il_util','open_rv_12m','open_rv_24m','max_bal_bc','all_util',
                    'total_rev_hi_lim','total_cu_tl','inq_last_6mths','inq_last_12m',
                    'mths_since_last_delinq','mths_since_last_record',
                    'inq_fi','mths_since_last_major_derog')

# fill each with zeros
for (col in fill_zero_cols) {
    loan_data[which(is.na(loan_data[, col])), col] <- 0
}

# fill nas for joint columns with regular answers for joint counterpart
joint_cols <- c('annual_inc_joint','dti_joint','verification_status_joint')
for (col in joint_cols) {
    reg_col <- gsub('_joint', '', col)
    loan_data[which(is.na(loan_data[, col])), col] <- loan_data[which(is.na(loan_data[, col])), reg_col]
}

# convert term to numeric
loan_data$term <- loan_data$term %>%
    gsub(' months', '', .) %>%
    trimws() %>%
    as.numeric()

# convert grade to factor
cats <- c("B"=2, "C"=3, "A"=1, "E"=5, "F"=6, "D"=4, "G"=7)
loan_data$grade <- loan_data$grade %>% cat_to_ranked(cats)

# convert home ownership to factor
cats <- c('RENT'=3,'OWN'=1,'MORTGAGE'=2,'OTHER'=4,'NONE'=5,'ANY'=6)
loan_data$home_ownership <- loan_data$home_ownership %>% cat_to_ranked(cats)

# convert verification status to factor
cats <- c('Verified'=1,'Source Verified'=2,'Not Verified'=3)
loan_data$verification_status <- loan_data$verification_status %>% cat_to_ranked(cats)

# do same for joint verification status
loan_data[which(loan_data$verification_status_joint == ''), 'verification_status_joint'] <- 'Not Verified'
loan_data$verification_status_joint <- loan_data$verification_status_joint %>% cat_to_ranked(cats)

# convert employment length
loan_data$emp_length <- loan_data$emp_length %>%
    gsub('years', '', .) %>%
    gsub('year', '', .) %>%
    gsub('< 1', '0', .) %>%
    gsub('n/a', '0', .) %>%
    gsub('\\+', '', .) %>%
    trimws() %>%
    as.numeric()

# create feature called loan age = diff b/w loan issue date and latest df date
loan_data$loan_age <- max_dt - loan_data$issue_d
loan_data$loan_age <- as.numeric(loan_data$loan_age)
loan_data$issue_d <- NULL

# loan status to default y/n dummy -- keep this range later? TODO
cats <- c('Fully Paid'=0, 'Charged Off'=1, 'Current'=0, 'Default'=1, 'Late (31-120 days)'=1, 
          'In Grace Period'=1, 'Late (16-30 days)'=1,
          'Does not meet the credit policy. Status:Fully Paid'=0,
          'Does not meet the credit policy. Status:Charged Off'=1, 'Issued'=0)
loan_data$loan_status <- loan_data$loan_status %>% cat_to_ranked(cats)

# payment plan to factor
loan_data$pymnt_plan <- loan_data$pymnt_plan %>% cat_to_num()

# convert purpose to factor
loan_data$purpose <- loan_data$purpose %>% cat_to_num()

# state to factor?
loan_data$addr_state <- loan_data$addr_state %>% cat_to_num()

# convert date of earliest_cr_line, create credit history length
loan_data[which(loan_data$earliest_cr_line == ''), 'earliest_cr_line'] <- format(max_dt, '%b-%Y')
loan_data$earliest_cr_line <- loan_data$earliest_cr_line %>% convert_dates()

# create history length feature - length of credit history
loan_data$history_length <- max_dt - loan_data$earliest_cr_line
loan_data$history_length <- as.numeric(loan_data$history_length)
loan_data$earliest_cr_line <- NULL

# last_pymnt_d convert to date
loan_data[which(loan_data$last_pymnt_d == ''), 'last_pymnt_d'] <- format(max_dt, '%b-%Y')
loan_data$last_pymnt_d <- loan_data$last_pymnt_d %>% convert_dates()

# create days since last payment
loan_data$days_since_last_pmt <- max_dt - loan_data$last_pymnt_d
loan_data$days_since_last_pmt <- as.numeric(loan_data$days_since_last_pmt)
loan_data$last_pymnt_d <- NULL

# create last payment amount - installment to get shortage/overpayment
loan_data$overpayment <- loan_data$last_pymnt_amnt - loan_data$installment

# convert next_pymnt_d feature to date
loan_data[which(loan_data$next_pymnt_d == ''), 'next_pymnt_d'] <- format(max_dt, '%b-%Y')
loan_data$next_pymnt_d <- loan_data$next_pymnt_d %>% convert_dates()

# get days to next payment
loan_data$days_to_next_pmt <- loan_data$next_pymnt_d - max_dt
loan_data$days_to_next_pmt <- as.numeric(loan_data$days_to_next_pmt)
loan_data$next_pymnt_d <- NULL

# application type to factor
loan_data$application_type <- loan_data$application_type %>% cat_to_num()

# last credit pull date - turn into days since last credit pull
loan_data[which(loan_data$last_credit_pull_d == ''), 'last_credit_pull_d'] <- format(max_dt, '%b-%Y')
loan_data$last_credit_pull_d <- loan_data$last_credit_pull_d %>% convert_dates()

# days since last credit pull
loan_data$days_since_last_pull <- max_dt - loan_data$last_credit_pull_d
loan_data$days_since_last_pull <- as.numeric(loan_data$days_since_last_pull)
loan_data$last_credit_pull_d <- NULL

return(loan_data)

}