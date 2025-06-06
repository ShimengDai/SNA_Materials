
# "Latent Factor Selection Model"

## Load required libraries

library(tidyverse)
library(ggplot2)
library(dplyr)
library(igraph)
library(latentnet)

## Load the required dataset

setwd("data")

load("tweets.RData")

## Divide into three time intervals

# Define peak periods
peak_start <- ymd("2024-04-02")
peak_end <- ymd("2024-04-10")

# Divide the data into three intervals based on the peak dates
t1 <- tweets %>% filter(created_at < peak_start)
t2 <- tweets %>% filter(created_at >= peak_start & created_at <= peak_end)
t3 <- tweets %>% filter(created_at > peak_end)


## Find unique users across three time intervals

# Find senders during T1 
unique_from_interval1 <- unique(t1$from)

# Final senders and receivers during T2
unique_from_interval2 <- unique(t2$from)
unique_to_interval2 <- unique(t2$to)
unique_people_interval2 <- union(unique_from_interval2, unique_to_interval2)

# Find senders during T3
unique_from_interval3 <- unique(t3$from)

# Find the intersection of the unique lists from each interval
common_people <- Reduce(intersect, list(unique_from_interval1, unique_people_interval2, unique_from_interval3))

# Output the common people
print(common_people)
print(length(common_people))

## Filter data based on the common people

t1 <- t1 %>% filter(from %in% common_people) 
t2 <- t2 %>% filter(from %in% common_people) %>% filter(to %in% common_people)
t3 <- t3 %>% filter(from %in% common_people) 


t1$num <- as.numeric(t1$num)
t2$num <- as.numeric(t2$num)
t3$num <- as.numeric(t3$num)

T1 <- t1 %>%  
  dplyr::select(from,tweet_id, created_at,text, num) %>% # change 1
  group_by(from) %>% 
  summarise(total1 = sum(num)) 


T2 <- t2 %>%  
  dplyr::select(from,tweet_id, created_at,text, num)%>% # change 1
  group_by(from) %>% 
  summarise(total2 = sum(num))


T3 <- t3 %>%  
  dplyr::select(from,tweet_id, created_at,text, num)%>% # change 1
  group_by(from) %>% 
  summarise(total3 = sum(num))

# Now merge the combined T1 and T2 with T3 by 'from'
trait <- T1 %>% full_join(T2, by = "from") %>% full_join(T3, by = "from")
trait[is.na(trait)] <- 0

trait_1 <- T1$total1
trait_2 <- T2$total2
trait_3 <- T3$total3

## Get T2 edgelist

t2_num_b <- t2 %>%
  dplyr::select(from, to, num_b) %>%
  group_by(from, to) %>%
  summarise(weight = sum(num_b)) %>%
  filter(from != to)

# Generate all possible pairs of user IDs
combinations <- expand.grid(from = common_people, to = common_people, stringsAsFactors = FALSE)
colnames(combinations) <- c("from", "to")

# Filter out self-loops (where from and to are the same)
combinations <- subset(combinations, from != to)

t2_numB_list <- merge(combinations, t2_num_b, by = c("from", "to"), all.x = TRUE)
t2_numB_list$weight[is.na(t2_numB_list$weight)] <- 0


## Get T2 adjacency matrix

# Create a graph from the edge list with weights and specify the vertex set
graph <- graph_from_data_frame(d = t2_numB_list, vertices = data.frame(name = common_people), directed = TRUE)

# Convert the igraph object to an adjacency matrix
t2_matrix <- as_adjacency_matrix(graph, attr = "weight", sparse = FALSE)

non_zero_entries <- sum(t2_matrix != 0)

print(non_zero_entries)


## Get the latent space

g2 <- network(as.matrix(t2_matrix), directed = TRUE)

g2 %v% "total1" <- trait_1

# d is the number of latent positons
m2<-ergmm(g2 ~ euclidean(d = 1) +  absdiff("total1"),control=ergmm.control(sample.size=5000,burnin=20000,interval=10,Z.delta=5))

summary(m2)

plot(m2)

(latent_pos<-c(m2$mkl$Z))

length(latent_pos)


## Exposure term 


E <- matrix(0, 24, 1) 


for (i in 1:20) {
  if (sum(t2_matrix[i,]) != 0) {  # Check for any connections at T2
    E[i,1] <- (t2_matrix[i,] %*% as.matrix(trait[,2])) / sum(t2_matrix[i,])
  }
  
}

(expo <- E[,1])  # Exposure based on your E matrix


## Model with trait 1 (trait_1)


infl<-data.frame(cbind(trait_1,trait_2, trait_3, expo, latent_pos))

summary(lm(trait_3~trait_1,data=infl))

## Add the exposure term (expo)

summary(lm(trait_3~expo + trait_1,data=infl))

## Add the latent space (latent_pos) 

summary(lm(trait_3~expo + trait_1 + latent_pos,data=infl))

