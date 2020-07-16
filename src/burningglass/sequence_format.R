library(TraMineR)
library(TraMineRextras)
library(RColorBrewer)

### Aligned sequences for veterans, we need one table of sequences and one of first job years -----
bg_vet_job_seq <- bg_vet_job %>%
  mutate(startyear = year(startdate), endyear = year(enddate)) %>%
  select("id", "startyear", "endyear", "onet_job_zone")
bg_vet_job_first <- bg_vet_job %>% 
  select("id", "startdate") %>% group_by(id) %>% transmute(enter = year(min(startdate))) %>% distinct() %>% ungroup()
sts.vet <- seqformat(bg_vet_job_seq, from = "SPELL", to = "STS",
                     id = "id",  begin = "startyear", end = "endyear", 
                     status = "onet_job_zone",  process = TRUE)


## ---Everything above this works! ------------------


test <- seqdef(bg_vet_job_seq, from = "SPELL", to = "STS",
               id = "id",  begin = "startyear", end = "endyear", 
               status = "onet_job_zone",  process = TRUE, states = events)

test <- bg_vet_job_first
events <- c(1, 2, 3, 4, 5)
test<-as.matrix(test)
test<-as.data.frame(test)


sts.vet <- seqformat(bg_vet_job_seq, from = "SPELL", to = "STS",
                      id = "id",  begin = "startyear", end = "endyear", 
                      status = "onet_job_zone",  process = TRUE)
test <- seqdef(bg_vet_job_seq, from = "SPELL", to = "STS",
               id = "id",  begin = "startyear", end = "endyear", 
               status = "onet_job_zone",  process = TRUE, states = events)
seqiplot(head(test, 10))
seqstatl(test)

### Aligned sequence for all, again we need two tables ------------------------