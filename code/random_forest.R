library(tidytext)
library(tidymodels)
library(here)

axon_df <- read_csv("data/axon-nlp-es-master-df.csv")

axon_df <- axon_df %>%
  select(car_value, event_date, word_count)

rand_forest(mode = "regression", mtry = 2, trees = 1000) %>%
  set_engine("randomForest") %>%
  fit(
    car_value ~ event_date + word_count, data = axon_df
  )
