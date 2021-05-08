library(EventStudy)

setwd("~/Dropbox/Git_Repos/axon-8k-scrape/data/EventStudy-files")

apiUrl <- "http://api.eventstudytools.com"
apiKey <- "573e58c665fcc08cc6e5a660beaad0cb"
options(EventStudy.KEY = apiKey)
estAPIKey(apiKey)
estSetup <- EventStudyAPI$new()

estType <- "arc"

#Set the type of event study to be conducted

dataFiles <- c("request_file" = "01_requestFile.csv",
               "firm_data"    = "02_firmDataPrice.csv",
               "market_data"  = "03_marketDataPrice.csv")

#Look at data files
request_df <- readr::read_delim("01_requestFile.csv", col_names = F, delim = ";")
names(request_df) <- c("Event ID", "Firm ID", "Market ID", "Event Date", "Grouping Variable", "Start Event Window", "End Event Window", "End of Estimation Window", "Estimation Window Length")
knitr::kable(head(request_df), pad=0)

firm_df <- readr::read_delim("02_firmDataPrice.csv", col_names = F, delim = ";")
names(firm_df) <- c("Firm ID", "Date", "Closing Price")
knitr::kable(head(firm_df))

market_df <- readr::read_delim("03_marketDataPrice.csv", col_names = F, delim = ";")
names(market_df) <- c("Market ID", "Date", "Closing Price")
knitr::kable(head(market_df))

# check data files, you can do it also in our R6 class
EventStudy::checkFiles(dataFiles)

#Set result path
resultPath <- "results"

#Perform Event Study
estResult <- estSetup$performDefaultEventStudy(estType    = estType,
                                               dataFiles  = dataFiles, 
                                               destDir    = resultPath)


