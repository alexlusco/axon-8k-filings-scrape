library(here)
library(rvest)
library(stringr)
library(tibble)
library(purrr)
library(dplyr)
library(readr)
library(glue)

urls <- paste("https://sec.report/CIK/0001069183/", 1:22, "#documents", sep = "")

scrape_out <- list()

for(u in urls){
  
  print(glue("scraping {u}..."))
  
  page <- xml2::read_html(u)
  
  doc_type <- html_node(page, "body") %>%
    html_nodes("br+ .table td:nth-child(1)") %>%
    html_text()
  
  doc_title <- html_node(page, "body") %>%
    html_nodes("br+ .table td a") %>%
    html_text()
  
  doc_dates <- html_node(page, "body") %>%
    html_nodes(".table small") %>%
    html_text() %>%
    as.Date()
  
  doc_urls <- html_node(page, "body") %>%
    html_nodes("br+ .table td a") %>%
    html_attr("href") %>%
    url_absolute(url)
  
  curr_data <- tibble(
    form = doc_type,
    title = doc_title,
    date = doc_dates,
    url = doc_urls
  )
  
  scrape_out[[u]] <- curr_data
  
  Sys.sleep(3)
  
}

final_df <- bind_rows(scrape_out)

final_df <- final_df %>%
  filter(form == "8-K")

write_csv(final_df, "data/sec-axon-8k-index.csv")
