#### MASTER FUNCTIONS ####

# create sequence object --------------------------------------------------------------

## opts: veteran vs nonveteran, military transition unemployment, cohort years, fixed time interval

create_sequence_object("sts_vet_thirty", is_veteran = "veteran", left_unemp = TRUE, complete_career = 30)

create_sequence_object <- function(name, is_veteran = "veteran", left_unemp = TRUE, cohort_begin, cohort_end, complete_career) {

  ## Import all resume data -----------------------
  bg_all_job <- fread("~/git/DSPG2020/career/data/03_bg_all_job.csv")
  #bg_vet_job <- read_csv("~/git/DSPG2020/career/data/04_bg_vet_job.csv")
  
  ## Create a variable for year entering the job market ---------------
  bg_all_job <- bg_all_job %>%
    mutate(year_enter_job_market = year(date_enter_job_market))%>%
    select(-noofjobs, -sector, -tenure) 
  
  ## Create the df for input into seqformat(), create vairbale for year of job start, create a variable for years in job market (used for subsetting), arrange by job zone and take distinct to manually remove overlapping jobs by taking the highest job zone for a year, remove veterans, create variables to align dates for sequence analysis  ----
  bg_all_job_seq <- bg_all_job %>%
    select(id, end_year, onet_job_zone, startdate, enddate, job_duration_day) %>%
    mutate(start_year = year(startdate))
  bg_all_job_seq <- bg_all_job_seq %>%
    group_by(id) %>%
    mutate(years_in_job_market = max(end_year) - min(start_year)) %>%
    select(id, start_year, end_year, onet_job_zone, years_in_job_market)%>%
    group_by(id)%>%
    arrange(desc(onet_job_zone))%>%
    group_by(id)%>%
    distinct(id, start_year, end_year, .keep_all = TRUE)
  sts_all <- bg_all_job_seq %>%
    group_by(id) %>% mutate(veteran = ifelse(any(onet_job_zone == 55), 1, 0)) %>%  
    mutate(start_year_a = start_year - min(start_year) + 1) %>%
    mutate(end_year_a = end_year - min(start_year) + 1)

# Filter for veteran, nonveteran, or all
if (is_veteran == "veteran"){
  sts_all <- sts_all %>%
    filter(veteran == 1)
  message("Filtering out nonveterans")
  
  } #end veteran filter
else if (is_veteran == "nonveteran"){
  sts_all <- sts_all %>%
    filter(veteran == 0)
  message("Filtering out veterans")
  
  } # end nonveteran filter
else {
  message("No filtering applied")
} # end no filtering applied
  
# Filtering complete careers
if (missing(complete_career)){
    message("No filtering for complete careers")
  }
else if (!missing(complete_career)){
  sts_all <- sts_all %>%
      filter(years_in_job_market >= complete_career)
    message(paste0("Filtering for ", complete_career, " years of complete career"))
      
}

# Cohort filtering
if (missing(cohort_begin) | missing(cohort_end)){
    message("No filtering for cohorts")
  }
else{
  sts_all <- sts_all %>%
    filter(start_year >= cohort_end & start_year <= cohort_begin)
    message(paste0("Filtering for those whole entered the civilian workforce between", cohort_begin, "and", cohort_end))
    
  }  

  sts_vet <- as.matrix(sts_all)
  sts_vet <- as.data.frame(sts_vet)
  
  sts_vet <- seqformat(sts_vet, from = "SPELL", to = "STS",
                       id = "id",  begin = "start_year_a", end = "end_year_a", 
                       status = "onet_job_zone", process = FALSE)
  
# Left unemployment?
if (left_unemp == TRUE){
  sts_vet <- seqdef(sts_vet, left="Military transition unemployment", gaps="Civilian unemployment", right="DEL")
  message("Defining left unemployment as a sequence state")
}
else if (missing(left_unemp) | left_unemp == FALSE){
  sts_vet <- seqdef(sts_vet, left="DEL", gaps="Civilian unemployment", right="DEL")
  message("Ignoring left unemployment as a sequence state")

}
  names(sts_vet) <- paste0(1:ncol(sts_vet))  
  
  assign(name, sts_vet, envir = .GlobalEnv) 
}

