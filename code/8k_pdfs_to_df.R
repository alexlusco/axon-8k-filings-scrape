library(pdftools)
library(tidyverse)

files <- list.files("data/axon-8k-filing-pdfs", pattern = "pdf$", full.names = TRUE)

file_names <- list.files("data/axon-8k-filing-pdfs", pattern = "pdf$", full.names = FALSE)

pdfs_text <- lapply(files, pdf_text)

df <- tibble(document = file_names, text = pdfs_text)

df <- df %>% mutate(date = document) %>%
  mutate(date = str_remove(date, ".pdf"),
         date = as.Date(date, format = "%Y-%m-%d"))

df_clean <- df %>% unnest(text) %>% mutate(text = str_squish(text))

df_clean <- df_clean %>% mutate(word_count = str_count(text)) %>% filter(word_count > 0) %>% filter(word_count != 17)
  
df_clean <- df_clean %>% group_by(date) %>% mutate(page_count = 1) %>% mutate(page_count = sum(page_count)) %>% ungroup()

write_csv(df_clean, "data/8ks_text_df.csv")


