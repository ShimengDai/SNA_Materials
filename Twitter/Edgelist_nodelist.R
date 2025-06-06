# "Edgelist_nodelist"


# Load R Packages

library(tidyverse)          # dplyr, ggplot2, tidyr, etc.
library(here)               # for here()
library(linkcomm)           # for integer.edgelist()
library(igraph)             # for graph_from_data_frame()

# Load data and insert your bearer_token

#bearer_token <- ""

setwd("data")

load("all_tweets.RData") # union topic 

# Edgelist

edgelist <- all_tweets %>% # If you have a dataset with a different name, be sure to replace all_tweets to your dataset name
  unnest(entities) %>%
  unnest_longer(mentions) %>%
  mutate(to=mentions$id) %>%
  rename(tweet_id=id,
         from=author_id) %>%
  drop_na(to,from) %>%
  select(tweet_id, created_at, from, to, text)

# Integer edgelist

# integer edgelist
network1 <- edgelist %>%
  select(from,to) %>%
  as.matrix() %>%
  integer.edgelist()

int_edges <- network1$edges %>%
  as.data.frame() %>%
  rename(from = V1,
         to = V2) %>%
  group_by(from,to) %>%
  summarize(weight = n()) %>%
  as.data.frame()

# save indegree and outdegree to use as node attributes
indegree <- int_edges %>%
  group_by(to) %>%
  summarize(indegree=n()) %>%
  as.data.frame()

outdegree <- int_edges %>%
  group_by(from) %>%
  summarize(outdegree=n()) %>%
  as.data.frame()

# Nodelist

ids <- c(edgelist$from, edgelist$to) %>% unique()
length(ids)
ids <- paste(ids, collapse = ',') # doesn't work when n>100 (user rate limit is 100)
# but I think we should be able to go up to 500 (rate limit for apps)

# Split the string into individual IDs
user_id_vector <- unlist(strsplit(ids, ","))

# Function to split the vector into chunks of 100
split_into_chunks <- function(vec, chunk_size) {
  split(vec, ceiling(seq_along(vec) / chunk_size))
}

# Split into chunks of 100
chunks <- split_into_chunks(user_id_vector, 100)

# Reassemble each chunk as a comma-separated string
chunked_strings <- sapply(chunks, paste, collapse = ",")

# Print the chunked strings
print(chunked_strings)

id_group1 <- chunked_strings[[1]]
id_group1


# Test scraping with the first 100 ids (id_group1)

id_string <- id_group1 

params_users <- list(`ids` = id_string,
                     `user.fields` = 'created_at,description,entities,id,location,name,public_metrics,username,verified')


# Create the endpoint URL with the comma-separated user IDs
url <- paste0("https://api.twitter.com/2/users?ids=", id_string)

# Send the GET request to Twitter API with the correct Authorization header
response <- httr::GET(url,
                      httr::add_headers(Authorization = paste('Bearer', bearer_token)),query = params_users)

# Extract the response content, simplifying it into a dataframe for easy use
users_data <- httr::content(response, as = 'parsed', type = 'application/json', simplifyDataFrame = TRUE)

# Create a dataframe from the main fields
nodelist <- as.data.frame(users_data$data) %>%
  # Unnest the public_metrics column (which is a list)
  unnest_wider(public_metrics, names_sep = "_") %>%
  # Unnest other relevant nested columns as needed
  unnest_wider(entities, names_sep = "_", names_repair = "minimal") %>%
  select(id, name, username, created_at, description, location, verified, 
         public_metrics_followers_count, public_metrics_following_count, 
         public_metrics_tweet_count, public_metrics_listed_count)


# save as R objects

save(edgelist, file=here("edgelist_test.RData"))
save(nodelist, file=here("nodelist_test.RData"))

# save as csv files

write.csv(edgelist, "edgelist.csv")
write.csv(nodelist, "nodelist.csv")
