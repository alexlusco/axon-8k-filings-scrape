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

########################
# First model
########################

axon_split <- axon_df %>%
  initial_split()

axon_train <- training(axon_split)
axon_test <- testing(axon_split)

axon_rec <- recipe(car_value ~ text + year + word_count, data = axon_train) %>%
  step_tokenize(text) %>%
  step_tokenfilter(text, max_tokens = 1e3) %>%
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
  #add_recipe(axon_rec2) %>%
  add_model(svm_spec)

svm_fit %>%
  fit(data = axon_train) %>%
  pull_workflow_fit() %>%
  tidy() %>%
  arrange(-estimate) %>% # positive CARs
  view()

svm_fit %>%
  fit(data = axon_train) %>%
  pull_workflow_fit() %>%
  tidy() %>%
  arrange(estimate) %>% # negative CARs
  print(n = 100)

########################
# First model eval
########################

axon_folds <- vfold_cv(axon_train)

svm_rs <- fit_resamples(
  axon_wf %>% add_model(svm_spec),
  axon_folds,
  control = control_resamples(save_pred = TRUE)
)

collect_metrics(svm_rs)

svm_rs %>%
  collect_predictions() %>%
  ggplot(aes(car_value, .pred, color = id)) +
  geom_abline(lty = 2, size = 1.5) +
  geom_point() +
  labs(
    x = "True CAR value",
    y = "Predicted CAR value",
    color = NULL,
    title = "Predicted and true CAR values for AXON 8k filings",
    subtitle = "Support Vector Model"
  ) +
  theme_ridges()

ggsave("figures/svm_resampling_comparisons.png")

########################
# Compare to null
########################

null_regression <- null_model() %>%
  set_engine("parsnip") %>%
  set_mode("regression")

null_rs <- fit_resamples(
  axon_wf %>% add_model(null_regression),
  axon_folds,
  metrics = metric_set(rmse)
)

collect_metrics(null_rs)

########################
# Compare to random forest
########################

rf_spec <- rand_forest(trees = 1000) %>%
  set_engine("ranger") %>%
  set_mode("regression")

rf_rs <- fit_resamples(
  axon_wf %>% add_model(rf_spec),
  axon_folds,
  control = control_resamples(save_pred = TRUE)
)

collect_metrics(rf_rs)

rf_rs %>%
  collect_predictions() %>%
  ggplot(aes(car_value, .pred, color = id)) +
  geom_abline(lty = 2, size = 1.5) +
  geom_point() +
  labs(
    x = "True CAR value",
    y = "Predicted CAR value",
    color = NULL,
    title = "Predicted and true CAR values for AXON 8k filings",
    subtitle = "Random Forest"
  ) +
  theme_ridges()

ggsave("figures/randomforest_resampling_comparisons.png")

########################
# Removing stopwords
########################

stopword_rec <- function(stopword_name) {
  recipe(car_value ~ text + year + word_count, data = axon_train) %>%
    step_tokenize(text) %>%
    step_stopwords(text, stopword_source = stopword_name) %>%
    step_tokenfilter(text, max_tokens = 1e3) %>%
    step_tfidf(text) %>%
    step_normalize(all_predictors())
}

stopword_rec("snowball")

svm_wf <- workflow() %>%
  add_model(svm_spec)

set.seed(123)
snowball_rs <- fit_resamples(
  svm_wf %>% add_recipe(stopword_rec("snowball")),
  axon_folds
)

set.seed(234)
smart_rs <- fit_resamples(
  svm_wf %>% add_recipe(stopword_rec("smart")),
  axon_folds
)

set.seed(345)
stopwords_iso_rs <- fit_resamples(
  svm_wf %>% add_recipe(stopword_rec("stopwords-iso")),
  axon_folds
)

collect_metrics(smart_rs)

word_counts <- tibble(name = c("snowball", "smart", "stopwords-iso")) %>%
  mutate(words = map_int(name, ~length(stopwords::stopwords(source = .))))

list(snowball = snowball_rs,
     smart = smart_rs,
     `stopwords-iso` = stopwords_iso_rs) %>%
  map_dfr(show_best, "rmse", .id = "name") %>%
  left_join(word_counts, by = "name") %>%
  mutate(name = paste0(name, " (", words, " words)"),
         name = fct_reorder(name, words)) %>%
  ggplot(aes(name, mean, color = name)) +
  geom_crossbar(aes(ymin = mean - std_err, ymax = mean + std_err), alpha = 0.6) +
  geom_point(size = 3, alpha = 0.8) +
  theme(legend.position = "none") +
  labs(x = NULL, y = "RMSE",
       title = "Model performance for three stop word lexicons",
       subtitle = "For this data set, the Snowball lexicon performed best") +
  theme_ridges()

ggsave("figures/stopword_comparisons.png")

########################
# Varying n-grams in model
########################

ngram_rec <- function(ngram_options) {
  recipe(car_value ~ text + year + word_count, data = axon_train) %>%
    step_tokenize(text, token = "ngrams", options = ngram_options) %>%
    step_tokenfilter(text, max_tokens = 1e3) %>%
    step_tfidf(text) %>%
    step_normalize(all_predictors())
}

ngram_rec(list(n = 1))

ngram_rec(list(n = 3, n_min = 1))

fit_ngram <- function(ngram_options) {
  fit_resamples(
    svm_wf %>% add_recipe(ngram_rec(ngram_options)),
    axon_folds
  )
}

set.seed(123)
unigram_rs <- fit_ngram(list(n = 1))

set.seed(234)
bigram_rs <- fit_ngram(list(n = 2, n_min = 1))

set.seed(345)
trigram_rs <- fit_ngram(list(n = 3, n_min = 1))

collect_metrics(bigram_rs)

list(`1` = unigram_rs,
     `1 and 2` = bigram_rs,
     `1, 2, and 3` = trigram_rs) %>%
  map_dfr(collect_metrics, .id = "name") %>%
  filter(.metric == "rmse") %>%
  ggplot(aes(name, mean, color = name)) +
  geom_crossbar(aes(ymin = mean - std_err, ymax = mean + std_err), alpha = 0.6) +
  geom_point(size = 3, alpha = 0.8) +
  theme(legend.position = "none") +
  labs(
    x = "Degree of n-grams",
    y = "RMSE",
    title = "Model performance for different degrees of n-gram tokenization",
    subtitle = paste("For the same number of tokens,",
                     "unigrams performed best")
  ) +
  theme_ridges()

ggsave("figures/ngram_comparisons.png")

########################
# Lemmatizing data
########################

spacyr::spacy_initialize(entity = FALSE)

lemma_rec <- recipe(car_value ~ text + year + word_count, data = axon_train) %>%
  step_tokenize(text, engine = "spacyr") %>%
  step_lemma(text) %>%
  step_tokenfilter(text, max_tokens = 1e3) %>%
  step_tfidf(text) %>%
  step_normalize(all_predictors())

lemma_rs <- fit_resamples(
  svm_wf %>% add_recipe(lemma_rec),
  axon_folds
)

collect_metrics(lemma_rs)

