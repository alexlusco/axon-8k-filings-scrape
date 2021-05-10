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
# Split
########################

axon_split <- axon_df %>%
  initial_split()

axon_train <- training(axon_split)
axon_test <- testing(axon_split)

########################
# Preprocessing
########################

axon_df <- axon_df %>%
  mutate(year = format(as.Date(event_date, "%Y-%m-%d"), format = "%Y"),
         text = str_remove_all(text, "'")) %>%
  mutate(across(c(car_value, year), as.numeric)) %>%
  select(car_value, event_date, year, text, word_count)

final_rec <- recipe(car_value ~ text + year + word_count, data = axon_train) %>%
  step_tokenize(text, token = "ngrams", options = list(n = 2, n_min = 1)) %>%
  step_tokenfilter(text, max_tokens = tune()) %>%
  step_tfidf(text) %>%
  step_normalize(all_predictors())

########################
# Model specification
########################

svm_spec <- svm_linear() %>%
  set_mode("regression") %>%
  set_engine("LiblineaR")

tune_wf <- workflow() %>%
  add_recipe(final_rec) %>%
  add_model(svm_spec)

########################
# Model resampling
########################

axon_folds <- vfold_cv(axon_train)

########################
# Model tuning
########################

final_grid <- grid_regular(
  max_tokens(range = c(1e3, 6e3)),
  levels = 6
)

final_rs <- tune_grid(
  tune_wf,
  axon_folds,
  grid = final_grid,
  metrics = metric_set(rmse, mae, mape),
  control = control_resamples(save_pred = TRUE)
)

########################
# Model evaluation
########################

final_rs %>%
  collect_metrics() %>%
  ggplot(aes(max_tokens, mean, color = .metric)) +
  geom_line(size = 1.5, alpha = 0.5) +
  geom_point(size = 2, alpha = 0.9) +
  facet_wrap(~.metric, scales = "free_y", ncol = 1) +
  theme(legend.position = "none") +
  labs(
    x = "Number of tokens",
    title = "Linear SVM performance across number of tokens",
    subtitle = "Performance improves as we include more tokens"
  ) +
  theme_ridges()

ggsave("figures/token_performance_comparison.png")

chosen_mae <- final_rs %>%
  select_by_pct_loss(metric = "mae", max_tokens)

final_wf <- finalize_workflow(tune_wf, chosen_mae)

final_fitted <- last_fit(final_wf, axon_split)

collect_metrics(final_fitted)

axon_fit <- pull_workflow_fit(final_fitted$.workflow[[1]])

axon_fit %>%
  tidy() %>%
  filter(term != "Bias") %>%
  mutate(
    sign = case_when(estimate > 0 ~ "negative CAR",
                     TRUE ~ "positive CAR"),
    estimate = abs(estimate),
    term = str_remove_all(term, "tfidf_text_")
  ) %>%
  group_by(sign) %>%
  top_n(20, estimate) %>%
  ungroup() %>%
  ggplot(aes(x = estimate,
             y = fct_reorder(term, estimate),
             fill = sign)) +
  geom_col(show.legend = FALSE) +
  scale_x_continuous(expand = c(0, 0)) +
  facet_wrap(~sign, scales = "free") +
  labs(
    y = NULL,
    title = paste("Variable importance for predicting year of",
                  "AXON 8k filings"),
    subtitle = paste("These features are the most importance",
                     "in predicting the car_value 2 days after an 8k filing")
  ) +
  theme_ridges()

ggsave("figures/8k_feature_comparison.png")

final_fitted %>%
  collect_predictions() %>%
  ggplot(aes(car_value, .pred)) +
  geom_abline(lty = 2, size = 1.5) +
  geom_point() +
  labs(
    x = "True CAR value",
    y = "Predicted CAR value",
    color = NULL,
    title = "Final SMV model predicted vs true CAR values for AXON 8k filings",
    subtitle = "For the testing set, predictions are awful!"
  ) +
  theme_ridges()

axon_bind <- collect_predictions(final_fitted) %>%
  bind_cols(axon_test %>% select(-car_value)) %>%
  filter(abs(car_value - .pred) > 25)

axon_bind %>%
  arrange(-car_value) %>%
  select(year, .pred, text)
