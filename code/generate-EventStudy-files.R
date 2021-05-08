library(tidyquant)
library(dplyr)
library(readr)

startDate <- "2001-01-01"
endDate <- "2021-05-08"

# Firm Data
firmSymbols <- c("AXON")
firmNames <- c("AXON")
firmSymbols %>% 
  tidyquant::tq_get(from = startDate, to = endDate) %>% 
  dplyr::mutate(date = format(date, "%d.%m.%Y")) -> firmData
knitr::kable(head(firmData), pad=0)

# Index Data
indexSymbol <- c("^NDXT")
indexName <- c("NDXT")
indexSymbol %>% 
  tidyquant::tq_get(from = startDate, to = endDate) %>% 
  dplyr::mutate(date = format(date, "%d.%m.%Y")) -> indexData
indexData$symbol <- "NDXT"
knitr::kable(head(indexData), pad=0)

# Price files for firms and market
firmData %>% 
  dplyr::select(symbol, date, adjusted) %>% 
  readr::write_delim(path      = "~/Dropbox/Git_Repos/axon-8k-scrape/data/EventStudy-files/02_firmDataPrice.csv", 
                     delim     = ";", 
                     col_names = F)

indexData %>% 
  dplyr::select(symbol, date, adjusted) %>% 
  readr::write_delim(path      = "~/Dropbox/Git_Repos/axon-8k-scrape/data/EventStudy-files/03_marketDataPrice.csv", 
                     delim     = ";", 
                     col_names = F)

# Volume files for firms and market
firmData %>% 
  dplyr::select(symbol, date, volume) %>% 
  readr::write_delim(path      = "~/Dropbox/Git_Repos/axon-8k-scrape/data/EventStudy-files/02_firmDataVolume.csv", 
                     delim     = ";", 
                     col_names = F)

indexData %>% 
  dplyr::select(symbol, date, volume) %>% 
  readr::write_delim(path      = "~/Dropbox/Git_Repos/axon-8k-scrape/data/EventStudy-files/03_marketDataVolume.csv", 
                     delim     = ";", 
                     col_names = F)

# Request file
events <- read_csv("~/Dropbox/Git_Repos/axon-8k-scrape/data/8ks_from_axon_json.csv") %>% 
  filter(filing_description == "Current report filing") %>%
  select(filing_date)

event_params_ticker <- events %>%
  filter(filing_date < "2021-01-01") %>%
  mutate(event_id = row_number()) %>%
  mutate(firm_id = "AXON") %>%
  mutate(market_id = "NDXT") %>%
  mutate(event_date = format(filing_date, "%d.%m.%Y")) %>%
  mutate(grping_var = "CurrentReport") %>%
  mutate(event_strt = -2) %>%
  mutate(event_end = 2) %>%
  mutate(est_end = -30) %>%
  mutate(est_lngth = 120) %>%
  select(-filing_date)

event_params_ticker %>% print(n=171)

event_params_ticker %>% 
  as.data.frame() %>% 
  readr::write_delim("~/Dropbox/Git_Repos/axon-8k-scrape/data/EventStudy-files/01_requestFile.csv", delim = ";", col_names = F)

