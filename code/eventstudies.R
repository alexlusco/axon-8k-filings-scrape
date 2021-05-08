#install.packages("eventstudies")

library(eventstudies)
library(quantmod)
library(tidyverse)
library(here)

event_list <- read_csv("data/8ks_from_axon_json.csv") %>%
  select(filing_date) %>%
  mutate(name = "AXON") %>%
  rename(when = filing_date) %>%
  select(name, when) %>%
  mutate(when = as.Date(when, format = "%Y-%m-%d")) %>%
  as.data.frame()

axon_returns <- read_csv("data/axon_stock_data.csv")

axon_returns <- axon_returns[, c(2,6)]

colnames(axon_returns) <- c("Date","AXON")

market_returns <- read_csv("data/gspc_stock_data.csv")

market_returns <- market_returns[, c(2,6)]

colnames(market_returns) <- c("Date","GSPC")

merged_df <- merge(axon_returns, market_returns, by = "Date", all = TRUE)

merged_df$AXON <- c(NA, diff(log(as.numeric(merged_df$AXON)), lag=1))

merged_df$GSPC <- c(NA, diff(log(as.numeric(merged_df$GSPC)), lag=1))

data.zoo <- read.zoo(merged_df)

es.mm <- eventstudy(firm.returns = data.zoo, 
                    event.list = event_list, 
                    event.window = 5, 
                    type = "marketModel", 
                    to.remap = FALSE, 
                    remap = "cumsum", 
                    inference = TRUE, 
                    inference.strategy = "bootstrap", 
                    model.args = list(market.returns=data.zoo$GSPC))

plot(es.mm)

summary(es.mm)
