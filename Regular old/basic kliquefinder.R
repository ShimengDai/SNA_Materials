# Code adapted from Ken Franks code
# ~ Jordan Tait

# Input file : CSV edgelist
# Format:  Sender | Receiver | Edge weight


# If you have trouble installing kliqfinder below, use the Github links below to troubleshoot
# https://github.com/jtbates/kliqfindr
# https://github.com/r-lib/devtools
#install.packages('devtools')
#install.packages("readr")
#install.packages("igraph")
devtools::install_github("jtbates/kliqfindr")


# Once packages have been installed
# this loads them into R
library(kliqfindr) # used to run Subgroup analysis
library(readr) # used to write list files needed for kliqfinder
library(igraph) # used to graph networks



# Set working directory of CSV edgelist
setwd("C:/Users/kenfrank/Dropbox/CEP 991/R tutorial materials/final")

# Name of CSV edgelist file
# REQUIRED Format: sender | receiver | edge_weight
filename<-"toynet"

# Add "CSV" suffix to filename
file<-paste(filename,".csv",sep="")

# Read in the CSV edgelist
ties <- read.csv(file, header=T, as.is=T)
ties

# Writes list file version of edge list
# This is REQUIRED for kliqfinder
filelist<-paste(filename,".list",sep="")
write_delim(ties,filelist,delim=" ",col_names=FALSE)


# add your list file to your working directory
subgroups <- winkliq_run(filelist)
subgroups
#subgroups$output_dir contains the information about the clusters output 
#including the p-value

groupbykf.file<-list.files(path=gsub("\\\\", "/", subgroups[["output_dir"]]),
                           full.name=T) 
groupbykf.file

# Save subgroup analysis results to a dataframe called "KFresults"
KFresults<-subgroups$place[,c("actor", "subgroup")]

# Previews first 5 rows of results
head(KFresults)

## kfresults contains cluster information based on kliqfinder algorithm 
## kfresults is sorted by node id 


# Creates Network called "ToyNetwork" from edgelist
Toynetwork <- graph_from_data_frame(d=ties,directed=T)


#Makes variable for each vertex called "subgroup" using the subgroup results, matchign by ID
V(Toynetwork)$subgroup<-KFresults$subgroup[match(V(Toynetwork)$name,KFresults$actor)]


set.seed(1)
#windows()
#par(mar=c(0,0,0,0)+0.1)
plot(Toynetwork, edge.arrow.size=0.05,
     vertex.label=V(Toynetwork)$node,
     edge.width= 1,
     #edge.curved=0.1,
     vertex.size=10,
     layout=layout_with_fr,
     vertex.label.cex = 1)


set.seed(1)
#windows()
#par(mar=c(0,0,0,0)+0.1)
plot(Toynetwork, edge.arrow.size=0.05,
     vertex.color=V(Toynetwork)$subgroup+1,  # the "+1" turns 0/1's into 1/2's. Two groups = Two colors
     vertex.label=V(Toynetwork)$node,
     edge.width= 1,
     #edge.curved=0.1,
     vertex.size=10,
     layout=layout_with_fr,
     vertex.label.cex = 1)

shapes<-V(class_netbyedgelist)$shape<-ifelse(V(class_netbyedgelist)$gender == "Male", "circle", "square")
colors<-ifelse(V(class_netbyedgelist)$grade == 12, "red", 
               ifelse(V(class_netbyedgelist)$grade == 11, "blue", "green"))
frame.colors <- ifelse(V(class_netbyedgelist)$race == "Black", "black", "gray")

plot(class_netbymatrix, edge.arrow.size=0.05,
     vertex.label=V(class_netbyedgelist)$name,
     edge.width= 1,
     #edge.curved=0.1,
     vertex.size=10,
     layout=layout_with_fr,
     vertex.label.cex =1,
     vertex.shape= shapes,
     vertex.color= colors,
     vertex.frame.color=frame.colors,
     vertex.frame.width=3)
