library(tidytext)
library(ggridges)
library(here)

axon_df <- read_csv("data/axon-nlp-es-master-df.csv")

axon_df %>%
  ggplot(aes(x = event_date, y = car_value)) +
  geom_hline(yintercept = 0, colour = "red") +
  geom_line() +
  theme_ridges() +
  scale_x_date(breaks = "2 years", date_labels = "%Y") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "AXON cumulative abnormal returns, 2001-2021") 

ggsave("figures/axon_cars.png", width = 8, height = 5)  
