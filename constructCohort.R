# Script to create a cohort that is a intersection of other cohorts. 
library(DBI)
library(CDMConnector)
library(Eunomia)
library(IncidencePrevalence)
library(PatientProfiles)
library(dplyr)

con <- DBI::dbConnect(duckdb::duckdb(), dbdir = eunomia_dir())
cdm <- cdm_from_con(con, cdm_schema = "main", write_schema = "main")

# age cohort
cdm <- generateDenominatorCohortSet(
  cdm = cdm,
  name ="cohort1",
  ageGroup = list(c(18, 65)))

# sex cohort
cdm <- generateDenominatorCohortSet(
  cdm = cdm,
  name ="cohort2",
  sex = c("Male"))

print(cdm$cohort1)
cdm$cohort1 %>% dplyr::tally()
print(cdm$cohort2)
cdm$cohort2 %>% dplyr::tally()

result <- cdm$cohort1 %>%
  addCohortIntersect(
    cdm = cdm,
    targetCohortTable = "cohort2"
  ) %>%
  dplyr::filter(`flag_denominator cohort 1_0_to_inf` == 1) %>%
  dplyr::collect()

print(result)
