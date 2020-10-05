source("make_model.R")
library(dplyr)
library(tidytext)
library(stringr)
library(plumber)
#' return chatbot response
#' @param msg the message used for analysis
#' @get /response
function(msg=" ") {
  
  # turn passed message into tidy dataframe
  msg_df <- tibble(line = 1:1, text = msg)
  
  # unnest words in dataframe
  msg_df <- msg_df %>% unnest_tokens(word, text)
  
  # compile response
  answer <- pred(msg_df)
}

