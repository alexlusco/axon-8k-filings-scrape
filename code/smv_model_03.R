#Code heavily influenced by Ch.6 https://smltar.com/mlregression.html#firstmlregression

library(tidytext)
library(tidyverse)
library(tidymodels)
library(textrecipes)
library(tidypredict)
library(ggridges)
library(here)

set.seed(1234)

axon_df <- read_csv("data/axon-nlp-es-master-df.csv")

########################
# A bit of preprocessing
########################

axon_df <- axon_df %>%
  mutate(year = format(as.Date(event_date, "%Y-%m-%d"), format = "%Y"),
         text = str_remove_all(text, "'")) %>% #fucks up the randomForest modeling if leave im
  mutate(across(c(car_value, year), as.numeric)) %>%
  select(car_value, event_date, year, text, word_count)

axon_df %>%
  mutate(text_copy = tolower(text)) %>%
  mutate(transparency = str_detect(text_copy, "transparent | transparency"),
         transparency = as.numeric(transparency)) %>%
  mutate(death = str_detect(text_copy, "death | dead | died | kill | murder")) %>%
  mutate(racism = str_detect(text_copy, "racism | inequity | inequality | racial | race | diversity")) %>%
  mutate(defund = str_detect(text_copy, "defund")) %>%
  count(defund)
  

