library(tidyverse)
library(janitor)
library(here)

# Read in axon cumulative abnormal return data from event study
axon_cars <- read_csv("data/axon-cars.csv") %>% clean_names()

# Read in axon event data, fix formatting (weird formatting was required for EventStudy lib)
axon_events <- read_delim("data/EventStudy-files/01_requestFile.csv", col_names = F, delim = ";")
names(axon_events) <- c("Event ID", "Firm ID", "Market ID", "Event Date", "Grouping Variable", "Start Event Window", "End Event Window", "End of Estimation Window", "Estimation Window Length")
axon_events <- axon_events %>% clean_names()
axon_events <- axon_events %>%
  mutate(event_date = as.Date(event_date, format = "%d.%m.%Y")) %>%
  mutate(event_date = as.Date(format(event_date, format = "%Y-%m-%d")))

# Read in axon 8k text data, extracted from PDFs
axon_8ks <- read_csv("data/8ks_text_df.csv") %>% select(text, date, word_count)

# Join the data sets
merged_df <- axon_cars %>%
  left_join(axon_events, by = "event_id") %>%
  left_join(axon_8ks, by = c("event_date" = "date"))

# Save as csv
write_csv(merged_df, "data/axon-nlp-es-master-df.csv")

