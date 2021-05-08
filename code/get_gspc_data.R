library(tidyquant)
library(readr)
library(here)

gspc_stock_data <- tq_get(x = "^GSPC", 
                          from = "2001-01-01",
                          to = "2021-01-01",
                          periodicity = "daily",
                          get = "stock.prices")

write_csv(gspc_stock_data, "data/gspc_stock_data.csv")
