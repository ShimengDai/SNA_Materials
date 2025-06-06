# "Kliqfinr Twitter"

getwd()

## Load required packages

library("dplyr")
library('devtools')
library("igraphdata")
library("igraph")
library("igraphdata")
library('RColorBrewer')
library(linkcomm)
#devtools::install_github("jtbates/kliqfindr")
library(kliqfindr)
library(readr) 


## Load the network data

load("t1edge.RData")
t1_num_b <- t1_num_b %>% filter(weight != 0)


## Modify node id 


# Combine 'from' and 'to' columns into a single vector
unique_ids <- unique(c(t1_num_b$from, t1_num_b$to))

# Convert the 'from' and 'to' columns to character
t1_num_b$from <- as.character(t1_num_b$from)
t1_num_b$to <- as.character(t1_num_b$to)

head(t1_num_b, n = 5)

# Create a mapping from unique IDs to sequential numbers
id_map <- setNames(seq_along(unique_ids), unique_ids)

id_map

# Create a new data frame with updated 'from' and 'to' columns
t1_num_b_revised <- t1_num_b
t1_num_b_revised$from <- id_map[t1_num_b$from]
t1_num_b_revised$to <- id_map[t1_num_b$to]


t1_num_b_revised$weight <- ifelse(t1_num_b_revised$weight != 0, 1, 0)
head(t1_num_b_revised, n = 5)


## winkliq_run


#t1_num_revised <- as.data.frame(t1_num_revised)
filelist<-paste("t1edge",".list",sep="")
readr::write_delim(t1_num_b_revised,filelist,delim=" ",col_names=F)

# add your list file to your working directory
subgroups <- kliqfindr::winkliq_run("t1edge.list")



# Save subgroup analysis results to a dataframe called "KFresults"
KFresults<-subgroups$place[,c("actor", "subgroup")]

# Previews first 5 rows of results
head(KFresults)


## Visualization

set.seed(57)


node <- data.frame(matrix(ncol = 0, nrow = nrow(KFresults)))
node$actor <- KFresults$actor
node$subgroup <- KFresults$subgroup

t1_num_b_revised$weight[t1_num_b_revised$weight <= 0] <- 0.01

# Create a graph from the edge list
g <- graph_from_data_frame(t1_num_b_revised, directed = FALSE)

# Add the node attributes
V(g)$subgroup <- node$subgroup[match(V(g)$name, node$actor)]

# First, verify that 'subgroup' values are all numeric and non-NA
if(any(is.na(V(g)$subgroup))) {
  warning("There are NA values in the 'subgroup' attribute.")
}

if(any(!is.numeric(V(g)$subgroup))) {
  warning("All 'subgroup' values should be numeric.")
}

# Replace NA values with a default subgroup value, if necessary
#V(g)$subgroup[is.na(V(g)$subgroup)] <- 1 # or some other default value appropriate for your data

# Now, let's plot again
plot(g, 
     vertex.color=rainbow(length(unique(V(g)$subgroup)))[V(g)$subgroup],
     vertex.size=10, 
     edge.arrow.size=.1)


set.seed(57)

# Create network from data frame
network.1 <- graph_from_data_frame(d = t1_num_b_revised, directed = TRUE)

# Determine number of unique subgroups
nclus <- KFresults %>% 
  select(subgroup) %>%
  distinct() %>% 
  nrow()

# Assign color palette to network based on number of subgroups
network.1$palette <- brewer.pal(nclus, "Set3")
print(network.1$palette)

# Assign community membership to vertices based on 'groupbykf'
network.1 <- network.1 %>%
  set_vertex_attr(name = 'community', index = V(network.1),
                  value = sapply(V(network.1)$name, function(x) {
                    subgroup <- KFresults %>%
                      filter(actor == x) %>%
                      .$subgroup
                    if (length(subgroup) == 0) NA else subgroup
                  }))



## Cluster Visualization


#' Now we can apply the weighting scheme to layout and then plot the network. 
l.fr.wt=layout.fruchterman.reingold(network.1,
                                    weights=(E(network.1)$weight+2)*2)
plot(network.1, 
     layout=l.fr.wt,
     edge.arrow.size=.4,
     vertex.label=V(network.1)$name, 
     vertex.color=V(network.1)$community
)

##add legend 
legend("topleft", bty="n",
       legend =levels(as.factor(V(network.1)$community)),
       fill=network.1$palette,border=NA)




