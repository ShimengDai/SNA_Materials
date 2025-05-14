
# Install required packages if not already installed
# install.packages("RSiena")
# install.packages("sna")
# install.packages("statnet")
# install.packages("latentnet")
# install.packages("igraph")

library(RSiena)      # For stochastic actor-oriented models
library(sna)         # Tools for social network analysis
library(statnet)     # Suite of network analysis tools
library(latentnet)   # For latent space network models
library(igraph)      # General network analysis


setwd("/Users/shimengdai/Dropbox/Michigan State/Github/SNA_Materials/Regular")

#Read data - assuming data are in current working directory
Toyatt <- read.csv("Toyatt.csv")  # Node attributes
Toynet <- read.csv("Toynet.csv")  # Edge list

# Change the datasets to the right formats
Toynet.data <- graph.data.frame(Toynet)                        # Create igraph object from edge list
Toynet.adj <- get.adjacency(Toynet.data, sparse = FALSE, attr='weight')  # Create adjacency matrix
g1 <- network(as.matrix(Toynet.adj))                           # Convert adjacency matrix to network object (statnet)
Toynet.m <- as.matrix(Toynet.adj)                              # Save adjacency matrix for later calculations

# Attach attributes to network
g1%v%"attr1" <- Toyatt[,2]
g1%v%"attr2" <- Toyatt[,3]
g1%v%"cattr3" <- Toyatt[,4]

# Find latent positions
set.seed(57)
m1<-ergmm(g1 ~ euclidean(d = 2)+absdiff("attr1")+absdiff("attr2")+absdiff("cattr3"),control=ergmm.control(sample.size=5000,burnin=20000,interval=10,Z.delta=5))
plot(m1)

#Two latent positions
m1$mkl$Z

# Save the first latent position
latent_pos1<-rep(m1$mkl$Z[,1],2)
latent_pos1

# Save the second latent position
latent_pos2<-rep(m1$mkl$Z[,2],2)
latent_pos2

# Calculate the exposure term
E<-matrix(0,6,3)
for (i in 1:6)
{    #making exposure term
  if (sum(Toynet.m[i,])!=0)
    E[i,1]<-(Toynet.m[i,]%*%Toyatt[,2])/sum(Toynet.m[i,])
  if (sum(Toynet.m[i,])!=0)
    E[i,2]<-(Toynet.m[i,]%*%Toyatt[,3])/sum(Toynet.m[i,])
}

# Format variables
att_1_2<-c(Toyatt[,2],Toyatt[,3])
expo<-c(E[,2],E[,1])
cattr3 <-rep(Toyatt[,4],2)

# Combine variables
infl<-data.frame(cbind(latent_pos1, latent_pos2, att_1_2, cattr3, expo, rep(c(1:6),2),rep(c(1:2),each=6)))

# model1 (predictor: exposure term) 
summary(lm(att_1_2~expo ,data=infl))

# model2 (predictors: exposure term and latent position 1)
summary(lm(att_1_2~expo+latent_pos1,data=infl))

# model3 (predictors: exposure term, latent position 1 and 2)
summary(lm(att_1_2~expo + latent_pos1 + latent_pos2,data=infl))

# model4 (predictors: exposure term, latent position 1, 2, and categorical variable)
summary(lm(att_1_2~expo + latent_pos1 + latent_pos2 + cattr3 ,data=infl))

