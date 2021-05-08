library(tidyverse)
library(ggridges)

axon_stock <- read_csv("data/axon_stock_data.csv")

axon_stock %>%
  ggplot(aes(x = date, y = close)) +
  geom_line() +
  theme_ridges() +
  scale_y_continuous(labels = scales::dollar, breaks = seq(0, 150, by = 25)) +
  scale_x_date(breaks = "2 years", date_labels = "%Y") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "AXON daily closing stock price, 2001-2021")

ggsave("figures/axon_close.png")

axon_stock %>%
  ggplot(aes(x = date, y = volume)) +
  geom_col() +
  theme_ridges() +
  scale_y_continuous(labels = scales::comma, breaks = seq(25000000, 150000000, by = 25000000)) +
  scale_x_date(breaks = "2 years", date_labels = "%Y") +
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "AXON daily total volume, 2001-2021")

ggsave("figures/axon_volume.png")

  
