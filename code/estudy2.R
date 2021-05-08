#install.packages("estudy2")

library(estudy2)
library(magrittr)

prices_index <- get_prices_from_tickers("^GSPC",
                                       start = as.Date("2001-01-01"),
                                       end = as.Date("2021-05-08"),
                                       quote = "Close",
                                       retclass = "zoo")

rates_index <- get_rates_from_prices(prices_index, 
                                    quote = "Close",
                                    multi_day = FALSE,
                                    compounding = "continuous")

get_prices_from_tickers("AXON",
                        start = as.Date("2001-01-01"),
                        end = as.Date("2021-05-08"),
                        quote = "Close",
                        retclass = "zoo") %>%
  get_rates_from_prices(quote = "Close",
                        multi_day = FALSE,
                        compounding = "continuous") %>%
  apply_market_model(regressor = rates_index,
                     same_regressor_for_all = TRUE,
                     market_model = "sim",
                     estimation_method = "ols",
                     estimation_start = as.Date("2003-01-01"),
                     estimation_end = as.Date("2003-05-08"))
  




parametric_tests(event_start = as.Date("2003-06-01"), 
                   event_end = as.Date("2003-06-23"))
  






t_test(event_start = as.Date("2001-01-01"),
         event_end = as.Date("2021-05-08"))





apply_market_model(
  rates = rates,
  regressor = rates_index,
  same_regressor_for_all = TRUE,
  market_model = "sim",
  estimation_method = "ols",
  estimation_start = as.Date("2001-01-01"),
  estimation_end = as.Date("2021-05-08")
) %>%
  t_test(event_start = as.Date("2001-01-01"),
         event_end = as.Date("2021-05-08"))




t_test(list_of_returns = securities_returns, 
       event_start = as.Date("2001-01-01"), 
       event_end = as.Date("2021-05-08"))


data(securities_returns)

securities_returns

t_test(list_of_returns = securities_returns, 
       event_start = as.Date("2001-01-01"), 
       event_end = as.Date("2021-05-08"))


