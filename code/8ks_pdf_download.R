#devtools::install_github("RohanAlexander/heapsofpapers")

library(heapsofpapers) #awesome new lib by Rohan Alexander!
library(readr)

df <- read_csv("data/8ks_from_axon_json.csv")

pdfs <- df %>%
  select(url, filing_date) %>%
  mutate(pdf_names = paste(filing_date, ".pdf", sep = ""))

get_and_save(
  data = pdfs,
  links = "url",
  save_names = "pdf_names",
  dir = "data/axon-8k-filing-pdfs"
)



