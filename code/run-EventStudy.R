library(EventStudy)

setwd("~/Dropbox/Git_Repos/axon-8k-scrape/data/EventStudy-files")

apiUrl <- "http://api.eventstudytools.com"
apiKey <- readLines("/Users/alexluscombe/Dropbox/API-Keys/EventStudy-APIkey-May2021") #sorry, get your own!

# Setup API Connection
estSetup <- EventStudyAPI$new(apiUrl)
estSetup$authentication(apiKey)

# Set event study type
estType <- "arc"

# Read in data file names
dataFiles <- c("request_file" = "01_requestFile.csv",
               "firm_data"    = "02_firmDataPrice.csv",
               "market_data"  = "03_marketDataPrice.csv")

# Inspect data files
request_df <- readr::read_delim("01_requestFile.csv", col_names = F, delim = ";")
names(request_df) <- c("Event ID", "Firm ID", "Market ID", "Event Date", "Grouping Variable", "Start Event Window", "End Event Window", "End of Estimation Window", "Estimation Window Length")
knitr::kable(head(request_df), pad=0)

firm_df <- readr::read_delim("02_firmDataPrice.csv", col_names = F, delim = ";")
names(firm_df) <- c("Firm ID", "Date", "Closing Price")
knitr::kable(head(firm_df))

market_df <- readr::read_delim("03_marketDataPrice.csv", col_names = F, delim = ";")
names(market_df) <- c("Market ID", "Date", "Closing Price")
knitr::kable(head(market_df))

# check data files
checkFiles(dataFiles)

# now let us perform the Event Study
resultPath <- "results"

estResult <- estSetup$performDefaultEventStudy(estType    = estType,
                                               dataFiles  = dataFiles, 
                                               destDir    = resultPath)

# Inspect results
knitr::kable(head(estResult$arResults))

# Save restults as tibble and export as .csv
car_results <- tibble(estResult$carResults)

write_csv(car_results, "~/Dropbox/Git_Repos/axon-8k-scrape/data/axon-cars.csv")



