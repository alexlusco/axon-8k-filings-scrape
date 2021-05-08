library(tidyquant)
library(readr)
library(here)

axon_stock_data <- tq_get(x = "AXON", 
                          from = "2000-01-01",
                          to = "2021-01-01",
                          periodicity = "daily",
                          get = "stock.prices")

write_csv(axon_stock_data, "data/axon_stock_data.csv")
