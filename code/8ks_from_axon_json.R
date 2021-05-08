library(tidyjson)
library(dplyr)
library(tidyr)
library(janitor)
library(glue)
library(readr)
library(here)

#test_url <- "https://investor.axon.com/feed/SECFiling.svc/GetEdgarFilingList?apiKey=BF185719B0464B3CB809D23926182246&LanguageId=1&exchange=CIK&symbol=0001069183&formGroupIdList=9,40&excludeNoDocuments=true&pageSize=-1&pageNumber=0&tagList=&includeTags=true&year=2019&excludeSelection=1"

urls <- paste("https://investor.axon.com/feed/SECFiling.svc/GetEdgarFilingList?apiKey=BF185719B0464B3CB809D23926182246&LanguageId=1&exchange=CIK&symbol=0001069183&formGroupIdList=9,40&excludeNoDocuments=true&pageSize=-1&pageNumber=0&tagList=&includeTags=true&year=", 2002:2021, "&excludeSelection=1", sep = "")

output <- list()

for(u in urls){
  #raw_json <- jsonlite::fromJSON(test_url)
  
  print(glue("Reading in {u}..."))
  
  raw_json <- jsonlite::fromJSON(u)
  
  filings_df <- unnest(raw_json$GetEdgarFilingListResult) %>% clean_names()
  
  filings_df <- filter(filings_df, document_type == "CONVPDF")
  
  filings_df$filing_date <- lubridate::mdy_hms(filings_df$filing_date)
  
  output[[u]] <- filings_df
  
}

final_df <- bind_rows(output)

write_csv(final_df, "data/8ks_from_sec_json.csv")








