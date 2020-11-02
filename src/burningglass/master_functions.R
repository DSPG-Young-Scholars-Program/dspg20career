#### MASTER FUNCTIONS ####

# create_seq_vet_fixed inputs(# years, left unemp)
# create_seq_vet_cohort inputs(min year, max year, left unemp)

# create_seq_all_fixed inputs(# years)
# create_seq_all_cohort inputs(min year, max year)

# 

# create sequence object --------------------------------------------------------------

## opts: veteran vs nonveteran, military transition unemployment, cohort years, fixed time interval

#create_sequence_object("sts_vet_thirty", is_veteran = "veteran", left_unemp = TRUE, complete_career = 30)

create_seq_vet_fixed <- function(name, complete_career, left_unemp = FALSE) {
  # Import all resume data
  vet_ids <- bg_covariates %>% filter(veteran == "veteran") %>% pull(id)
  
  bg_job <- bg_job %>% left_join(bg_covariates, by = "id") %>%
    filter(start_year > year_military_exit) %>%
    mutate(BAD = ifelse(start_year > end_year, TRUE, FALSE)) %>% 
    filter(BAD == FALSE)
  message("Subsetting for career sequence after military exit")
    
  bg_job <- bg_job %>% filter(id %in% vet_ids) %>%
    group_by(id) %>%
    mutate(years_in_job_market = max(end_year) - min(start_year)) %>%
    filter(years_in_job_market >= complete_career)
  
  bg_job <- bg_job %>%
    mutate(start_year = as.integer(start_year - year_military_exit + 1)) %>% 
    mutate(end_year = as.integer(end_year - year_military_exit + 1)) %>% filter(start_year >= 0, end_year >= 0) %>% 
    select(id, onet_job_zone, start_year, end_year)
  message(paste0("Transform from calendar year to aligned years"))
  
  sts <- as.matrix(bg_job)
  sts <- as.data.frame(sts)
  
  sts <- seqformat(sts, from = "SPELL", to = "STS",
                       id = "id",  begin = "start_year", end = "end_year", 
                       status = "onet_job_zone", process = FALSE, overwrite = FALSE)
  
  # Left unemployment?
  if (left_unemp == TRUE){
    sts_vet <- seqdef(sts, left="Military transition unemployment", gaps="Civilian unemployment", right="DEL")
    message("Defining left unemployment as a sequence state")
  }
  else if (missing(left_unemp) | left_unemp == FALSE){
    sts_vet <- seqdef(sts, left="DEL", gaps="Civilian unemployment", right="DEL")
    message("Ignoring left unemployment as a sequence state")
  }
  
  sts_vet <- sts_vet[,1:10]
  names(sts_vet) <- paste0(1:ncol(sts_vet))  
  
  assign(name, sts_vet, envir = .GlobalEnv) 
}

create_seq_vet_cohort <- function(name, cohort_begin = 1951, cohort_end = 2018, after_military = TRUE, left_unemp = FALSE) {
  
  # Cohort filtering
  vet_ids <- bg_covariates %>% filter(veteran == "veteran") %>% pull(id)
  bg_job <- bg_job %>% filter(id %in% vet_ids)
  bg_job <- bg_job %>%
    mutate(BAD = ifelse(start_year > end_year, TRUE, FALSE)) %>% 
    filter(BAD == FALSE) %>% filter(start_year >= cohort_begin & start_year <= cohort_end)
  message(paste0("Filtering for those whole entered the civilian workforce between ", cohort_begin, " and ", cohort_end))
  
  if (after_military == TRUE){
    bg_job <- bg_job %>% left_join(bg_covariates, by = "id") %>%
      filter(start_year >= year_military_exit)
    message("Subsetting for career sequence after military exit")
  }
  
  if (after_military == FALSE){
    bg_job <- bg_job %>% left_join(bg_covariates, by = "id")
    message("Including military experience in career sequence")
  }
  
  bg_job <- bg_job %>%
    mutate(start_year = as.integer(start_year - year_military_exit + 1)) %>% 
    mutate(end_year = as.integer(end_year - year_military_exit + 1)) %>% filter(start_year >= 0, end_year >= 0) %>% 
    select(id, onet_job_zone, start_year, end_year)
  message(paste0("Transform from calendar year to aligned years"))
  
  sts <- as.matrix(bg_job)
  sts <- as.data.frame(sts)
  
  sts <- seqformat(sts, from = "SPELL", to = "STS",
                   id = "id",  begin = "start_year", end = "end_year", 
                   status = "onet_job_zone", process = FALSE)
  
  # Left unemployment?
  if (left_unemp == TRUE){
    sts_vet <- seqdef(sts, left="Military transition unemployment", gaps="Civilian unemployment", right="DEL")
    message("Defining left unemployment as a sequence state")
  }
  else if (missing(left_unemp) | left_unemp == FALSE){
    sts_vet <- seqdef(sts, left="DEL", gaps="Civilian unemployment", right="DEL")
    message("Ignoring left unemployment as a sequence state")
  }
  
  names(sts_vet) <- paste0(1:ncol(sts_vet))  
  
  assign(name, sts_vet, envir = .GlobalEnv) 
  
}

create_seq_all_fixed <- function(name, complete_career) {
  
  # Import all resume data
  
  bg_job <- bg_job %>%
    group_by(id) %>%
    mutate(years_in_job_market = max(end_year) - min(start_year)) %>%
    filter(years_in_job_market >= complete_career)
  
  sts <- as.matrix(bg_job)
  sts <- as.data.frame(sts)
  
  sts <- seqformat(sts, from = "SPELL", to = "STS",
                   id = "id",  begin = "start_year", end = "end_year", 
                   status = "onet_job_zone", process = FALSE)
  
  sts_vet <- seqdef(sts, left="DEL", gaps="Civilian unemployment", right="DEL")
}

create_seq_all_cohort <- function(name, cohort_begin, cohort_end) {
  
  # Cohort filtering
  bg_job <- bg_job %>%
    filter(start_year >= cohort_end & start_year <= cohort_begin)
  message(paste0("Filtering for those whole entered the civilian workforce between", cohort_begin, "and", cohort_end))
  
  sts <- as.matrix(bg_job)
  sts <- as.data.frame(sts)
  
  sts <- seqformat(sts, from = "SPELL", to = "STS",
                   id = "id",  begin = "start_year", end = "end_year", 
                   status = "onet_job_zone", process = FALSE)
  
  sts <- seqdef(sts_vet, left="DEL", gaps="Civilian unemployment", right="DEL")
  
}

#create_sequence_object <- function(name, is_veteran = "veteran", left_unemp = TRUE, cohort_begin, cohort_end, complete_career) {

  ## Import all resume data -----------------------
#  bg_all_job <- fread("~/git/DSPG2020/career/data/03_bg_all_job.csv")
  #bg_vet_job <- read_csv("~/git/DSPG2020/career/data/04_bg_vet_job.csv")
  
  ## Create a variable for year entering the job market ---------------
#  bg_all_job <- bg_all_job %>%
#    mutate(year_enter_job_market = year(date_enter_job_market))%>%
#    select(-noofjobs, -sector, -tenure) 
#  
#  ## Create the df for input into seqformat(), create vairbale for year of job start, create a variable for years in job market (used for subsetting), arrange by job zone and take distinct to manually remove overlapping jobs by taking the highest job zone for a year, remove veterans, create variables to align dates for sequence analysis  ----
#  bg_all_job_seq <- bg_all_job %>%
#    select(id, end_year, onet_job_zone, startdate, enddate, job_duration_day) %>%
#    mutate(start_year = year(startdate))
#  bg_all_job_seq <- bg_all_job_seq %>%
#    group_by(id) %>%
#    mutate(years_in_job_market = max(end_year) - min(start_year)) %>%
#    select(id, start_year, end_year, onet_job_zone, years_in_job_market)%>%
#    group_by(id)%>%
#    arrange(desc(onet_job_zone))%>%
#    group_by(id)%>%
#    distinct(id, start_year, end_year, .keep_all = TRUE)
#  sts_all <- bg_all_job_seq %>%
#    group_by(id) %>% mutate(veteran = ifelse(any(onet_job_zone == 55), 1, 0)) %>%  
#    mutate(start_year_a = start_year - min(start_year) + 1) %>%
#    mutate(end_year_a = end_year - min(start_year) + 1)

# Filter for veteran, nonveteran, or all
#if (is_veteran == "veteran"){
#  sts_all <- sts_all %>%
#    filter(veteran == 1)
#  message("Filtering out nonveterans")
  
#  } #end veteran filter
#else if (is_veteran == "nonveteran"){
#  sts_all <- sts_all %>%
#    filter(veteran == 0)
#  message("Filtering out veterans")
  
#  } # end nonveteran filter
#else {
#  message("No filtering applied")
#} # end no filtering applied
  
# Filtering complete careers
#if (missing(complete_career)){
#    message("No filtering for complete careers")
#  }
#else if (!missing(complete_career)){
#  sts_all <- sts_all %>%
#      filter(years_in_job_market >= complete_career)
#    message(paste0("Filtering for ", complete_career, " years of complete career"))
      
#}

# Cohort filtering
#if (missing(cohort_begin) | missing(cohort_end)){
#    message("No filtering for cohorts")
#  }
#else{
#  sts_all <- sts_all %>%
#    filter(start_year >= cohort_end & start_year <= cohort_begin)
#    message(paste0("Filtering for those whole entered the civilian workforce between", cohort_begin, "and", cohort_end))
    
#  }  

#  sts_vet <- as.matrix(sts_all)
#  sts_vet <- as.data.frame(sts_vet)
#  
#  sts_vet <- seqformat(sts_vet, from = "SPELL", to = "STS",
#                       id = "id",  begin = "start_year_a", end = "end_year_a", 
#                       status = "onet_job_zone", process = FALSE)
  
# Left unemployment?
#if (left_unemp == TRUE){
#  sts_vet <- seqdef(sts_vet, left="Military transition unemployment", gaps="Civilian unemployment", right="DEL")
#  message("Defining left unemployment as a sequence state")
#}
#else if (missing(left_unemp) | left_unemp == FALSE){
#  sts_vet <- seqdef(sts_vet, left="DEL", gaps="Civilian unemployment", right="DEL")
#  message("Ignoring left unemployment as a sequence state")

#}
#  names(sts_vet) <- paste0(1:ncol(sts_vet))  
  
#  assign(name, sts_vet, envir = .GlobalEnv) 
#}

