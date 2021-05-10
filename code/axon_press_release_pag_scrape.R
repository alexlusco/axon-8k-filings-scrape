library(rvest)
library(glue)
library(readr)
library(dplyr)

index <- read_csv("data/axon_press_release_index.csv")

urls <- index$url

output <- list()

for(u in urls){
  
  print(glue("Scraping p tags from {u}..."))
  
  page <- read_html(u)
  
  text <- page %>%
    html_node("#_ctrl0_ctl66_divModuleContainer .module_container--outer") %>%
    html_nodes("p") %>%
    html_text(trim = TRUE) %>%
    toString()
  
  curr_data <- tibble(
    text = paste(text),
    url = u
  )
  
  output[[u]] <- curr_data
  
  #Sys.sleep(3)
  
}

final_df <- bind_rows(output)

final_df <- final_df %>%
  left_join(index, by = "url")

write_csv(final_df, "data/axon_press_release_final_df.csv")
