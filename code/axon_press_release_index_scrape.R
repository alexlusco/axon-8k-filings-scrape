library(rvest)
library(glue)
library(readr)
library(dplyr)

#url <- "https://investor.axon.com/press-releases/2019/default.aspx"

urls <- paste("https://investor.axon.com/press-releases/", 2009:2021, "/default.aspx", sep = "")

output <- list()

for(u in urls){
  
  print(glue("Scraping {u}..."))
  
  page <- read_html(u)
  
  date <- page %>%
    html_node("body") %>%
    html_nodes(".module_date-text") %>%
    html_text(trim = TRUE) %>%
    as.Date(format = "%d %b %Y")
  
  headline <- page %>%
    html_node("body") %>%
    html_nodes(".module_headline") %>%
    html_text(trim = TRUE)
  
  url <- page %>%
    html_node("body") %>%
    html_nodes(".module_headline , #_ctrl0_ctl66_repeaterContent_ctl41_hrefHeadline") %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    url_absolute(u)
  
  curr_data <- tibble(
    date = date,
    headline = headline,
    url = url
  )
  
  output[[u]] <- curr_data
  
  Sys.sleep(3)
}

final_df <- bind_rows(output)

write_csv(final_df, "data/axon_press_release_index.csv")
