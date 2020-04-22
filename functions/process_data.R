# function to process the raw lendingclub data into a usable set of
# features. fills na values with zeros where this makes sense, converts
# some features to factor or numeric, and converts some ranked categories
# to numeric rankings
process_data <- function(loan_data) 
{
    # specify date data is as of - sample ends in december 2015. assume day 1.
    max_dt <- as.Date('2015-12-01')
        
    # drop cols right off the bat, unable to easily turn into features
    drop_cols <- c('emp_title','member_id','url','desc','title',
                   'zip_code','sub_grade', 'initial_list_status','policy_code')
    loan_data <- loan_data[, -which(names(loan_data) %in% drop_cols)]
    
    # date fixes ----
    
    # fill bank/na dates in some date columns
    loan_data[which(is.na(loan_data$earliest_cr_line)), 'earliest_cr_line'] <- format(max_dt, '%b-%Y')
    loan_data[which(loan_data$earliest_cr_line == ''), 'earliest_cr_line'] <- format(max_dt, '%b-%Y')
    loan_data[which(loan_data$last_pymnt_d == ''), 'last_pymnt_d'] <- format(max_dt, '%b-%Y')
    loan_data[which(loan_data$next_pymnt_d == ''), 'next_pymnt_d'] <- format(max_dt, '%b-%Y')
    loan_data[which(loan_data$last_credit_pull_d == ''), 'last_credit_pull_d'] <- format(max_dt, '%b-%Y')
    
    # convert to date format
    loan_data$earliest_cr_line <- loan_data$earliest_cr_line %>% convert_dates()
    loan_data$last_credit_pull_d <- loan_data$last_credit_pull_d %>% convert_dates()
    loan_data$issue_d <- loan_data$issue_d %>% convert_dates()
    loan_data$next_pymnt_d <- loan_data$next_pymnt_d %>% convert_dates()
    loan_data$last_pymnt_d <- loan_data$last_pymnt_d %>% convert_dates()
    
    # categorial to numeric ----
    
    # convert data type to numeric
    loan_data$pymnt_plan <- loan_data$pymnt_plan %>% cat_to_num()
    loan_data$purpose <- loan_data$purpose %>% cat_to_num()
    loan_data$addr_state <- loan_data$addr_state %>% cat_to_num()
    loan_data$application_type <- loan_data$application_type %>% cat_to_num()
    
    # fill zeros ----
    
    # vector of columns to fill nas with zero for
    fill_zero_cols <- c('annual_inc','delinq_2yrs','tot_coll_amt','tot_cur_bal',
                        'open_acc','pub_rec','total_acc','revol_util','open_acc_6m',
                        'open_il_6m','open_il_12m','open_il_24m','acc_now_delinq',
                        'mths_since_rcnt_il','collections_12_mths_ex_med','total_bal_il',
                        'il_util','open_rv_12m','open_rv_24m','max_bal_bc','all_util',
                        'total_rev_hi_lim','total_cu_tl','inq_last_6mths','inq_last_12m',
                        'mths_since_last_delinq','mths_since_last_record',
                        'inq_fi','mths_since_last_major_derog')
    
    # loop through columns, fill nas with zeros
    for (col in fill_zero_cols) {
        if (col %in% names(loan_data)) {
            loan_data[which(is.na(loan_data[, col])), col] <- 0    
        }
    }
    
    # misc other fixes ----
    
    # fill nas for joint columns with regular answers for joint counterpart
    joint_cols <- c('annual_inc_joint','dti_joint','verification_status_joint')
    for (col in joint_cols) {
        # get name of regular column i.e. non-joint column
        reg_col <- gsub('_joint', '', col)
        
        # fill nas with regular column values
        loan_data[which(is.na(loan_data[, col])), col] <- loan_data[which(is.na(loan_data[, col])), reg_col]
    }
    
    # convert term to numeric
    # trim out text, whitespace, convert to numeric
    loan_data$term <- loan_data$term %>%
        gsub(' months', '', .) %>%
        trimws() %>%
        as.numeric()
    
    # convert employment length
    # trim out text, whitespace, convert to numeric
    loan_data$emp_length <- loan_data$emp_length %>%
        gsub('years', '', .) %>%
        gsub('year', '', .) %>%
        gsub('< 1', '0', .) %>%
        gsub('n/a', '0', .) %>%
        gsub('\\+', '', .) %>%
        trimws() %>%
        as.numeric()
    
    # ranked categorial data fixes ----
    
    # convert grade to factor
    # ranking: A is best, G is worst
    cats <- c("B"=2, "C"=3, "A"=1, "E"=5, "F"=6, "D"=4, "G"=7)
    loan_data$grade <- loan_data$grade %>% cat_to_ranked(cats)
    
    # convert home ownership to factor
    # ranking: Own is best, morgage second best, rent is third best. others follow
    cats <- c('RENT'=3,'OWN'=1,'MORTGAGE'=2,'OTHER'=4,'NONE'=5,'ANY'=6)
    loan_data$home_ownership <- loan_data$home_ownership %>% cat_to_ranked(cats)
    
    # convert verification status to factor
    # ranking: verified is best, source verified is ok, not verified is worst
    cats <- c('Verified'=1,'Source Verified'=2,'Not Verified'=3)
    loan_data$verification_status <- loan_data$verification_status %>% cat_to_ranked(cats)
    
    # do same for joint verification status
    # same ranking as above
    loan_data[which(loan_data$verification_status_joint == ''), 'verification_status_joint'] <- 'Not Verified'
    loan_data$verification_status_joint <- loan_data$verification_status_joint %>% cat_to_ranked(cats)
    
    # loan status to default y/n dummy
    # defaulted includes all "credit events" such as late, in grace period, charged off, etc
    # not defaulted includes fully paid, current, issued
    cats <- c('Fully Paid'=0, 'Charged Off'=1, 'Current'=0, 'Default'=1, 'Late (31-120 days)'=1, 
              'In Grace Period'=1, 'Late (16-30 days)'=1,
              'Does not meet the credit policy. Status:Fully Paid'=0,
              'Does not meet the credit policy. Status:Charged Off'=1, 'Issued'=0)
    loan_data$loan_status <- loan_data$loan_status %>% cat_to_ranked(cats)
    
    # create new variables ----
    
    # create variable called loan age as of max_dt
    # formula: timedelta between max date and issue date
    # rationale: age of loan might impact likelihood of default
    loan_data$loan_age <- max_dt - loan_data$issue_d
    loan_data$loan_age <- as.numeric(loan_data$loan_age)
    loan_data$issue_d <- NULL
    
    # create history length feature - length of credit history
    # formula: days from earliest credit line to today (max_dt)
    # rationale: longer credit history could be less likely to default
    loan_data$history_length <- max_dt - loan_data$earliest_cr_line
    loan_data$history_length <- as.numeric(loan_data$history_length)
    loan_data$earliest_cr_line <- NULL
    
    # create days since last payment
    # formula: last payment date to today (max_dt)
    # rationale: if last pmt was more recent, could be less likely to default
    loan_data$days_since_last_pmt <- max_dt - loan_data$last_pymnt_d
    loan_data$days_since_last_pmt <- as.numeric(loan_data$days_since_last_pmt)
    loan_data$last_pymnt_d <- NULL
    
    # create last payment amount - installment to get shortage/overpayment
    # formula: last payment amount minus installment
    # rationale: overpaying is good, underpaying is bad for default likelihood
    loan_data$overpayment <- loan_data$last_pymnt_amnt - loan_data$installment
    loan_data$last_pymnt_amnt <- NULL
    loan_data$installment <- NULL
    
    # get days to next payment
    # formula: days until next payment date from today (max_dt)
    # rationale: sooner payments could mean more likely default than those with less soon payments
    loan_data$days_to_next_pmt <- loan_data$next_pymnt_d - max_dt
    loan_data$days_to_next_pmt <- as.numeric(loan_data$days_to_next_pmt)
    loan_data$next_pymnt_d <- NULL
    
    # days since last credit pull
    # formula: days from last credit pull to today
    # rationale: older credit pull - possibly more likely to have less debt
    loan_data$days_since_last_pull <- max_dt - loan_data$last_credit_pull_d
    loan_data$days_since_last_pull <- as.numeric(loan_data$days_since_last_pull)
    loan_data$last_credit_pull_d <- NULL
    
    return(loan_data)
}
