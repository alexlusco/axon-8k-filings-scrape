library(tidytext)
library(tidyverse)
library(tidymodels)
library(textrecipes)
library(tidypredict)
library(here)

set.seed(1234)

axon_df <- read_csv("data/axon-nlp-es-master-df.csv")

axon_df <- axon_df %>%
  mutate(year = format(as.Date(event_date, "%Y-%m-%d"), format = "%Y"),
         text = str_remove_all(text, "'"),
         text = tolower(text)) %>%
  mutate(across(c(car_value, year), as.numeric)) %>%
  select(car_value, event_date, year, text)

axon_split <- axon_df %>%
  initial_split()

axon_train <- training(axon_split)
axon_text <- testing(axon_split)

axon_rec <- recipe(car_value ~ text + year, data = axon_train) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1e3) %>%
  step_stopwords(text, stopword_source = "snowball") %>%
  step_tfidf(text) %>%
  step_normalize(all_predictors())

axon_prep <- prep(axon_rec)
axon_bake <- bake(axon_prep, new_data = NULL)

dim(axon_bake)

axon_wf <- workflow() %>%
  add_recipe(axon_rec)

# Support vector machine
svm_spec <- svm_linear() %>%
  set_mode("regression") %>%
  set_engine("LiblineaR")

svm_fit <- workflow() %>%
  add_recipe(axon_rec) %>%
  add_model(svm_spec)

svm_fit %>%
  fit(data = axon_train) %>%
  pull_workflow_fit() %>%
  tidy() %>%
  arrange(-estimate) %>% # positive CARs
  print(n = 150)

svm_fit %>%
  fit(data = axon_train) %>%
  pull_workflow_fit() %>%
  tidy() %>%
  arrange(estimate) %>% # negative CARs
  print(n = 100)

