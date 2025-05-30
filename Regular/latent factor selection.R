#install.packages("amen")
# https://www.rdocumentation.org/packages/amen/versions/1.4.5/topics/ame
library(amen) # Analysis of network and relational data using additive and multiplicative effects (AME) models
#install.packages("igraph")
library(igraph)
#setwd("")

# Load edge list: each row is sendr, receiver, and weight
edgelist <- read.csv("toynet.csv", header=T, as.is=T)
head(edgelist, n = 3) # sender receiver weight 

# Convert edge list to adjacency matrix
matnet <-as.matrix(get.adjacency(graph.data.frame(edgelist)))
matnet

# Load node attributes
nodes <- read.csv("toyatt.csv", header=T, as.is=T)
head(nodes,n = 3)
nodeatt <-as.matrix(nodes)
nodeatt

# Initialize attribute matrix for AME model
allatt<-matrix(nrow=6,ncol=2)
allatt

allatt[,1]<-nodeatt[,2] # First attribute
allatt

allatt[,2]<-nodeatt[,3] # Second attribute
allatt

colnames(allatt)<- c("attr1", "attr2")
allatt

# Fit AME model using both attributes
toyfit1 <-ame(matnet, Xr=allatt, print=F, family="nrm")
# Xr: Matrix of row (sender) covariates (n × p), describing characteristics of the sender.
# family: Type of data: "nrm" (normal), "bin" (binary), "ord" (ordinal), "frn" (fixed rank nomination), "cbin" (censored binary), or "rrl" (relative rank likelihood).
summary(toyfit1)

# Extract attribute 1
attr1 <- c(allatt[,1])
attr1

names(attr1)[1] <- "attr1"
attr1
?ame
#estimate a new model with only attribute 1
toyfit2 <-ame(matnet, Xr=attr1, rvar=F, cvar=F, print=F, family="nrm")
# rvar/ Logical: include random effects for row heterogeneity? (TRUE = yes)
# cvar/ Logical: allow for within-dyad correlation (i.e., reciprocity)
summary(toyfit2)

# Compute dyadic covariate: absolute differences (Manhattan distance) in attr1
abattr1 <- as.matrix(dist(attr1, method = "manhattan"))
abattr1

# Extract and compute distance matrix for a third attribute
attr3 <-nodeatt[,4]
attr3
abattr3 <- as.matrix(dist(attr3, method = "manhattan"))
abattr3

# Fit model with dyadic covariate abattr1
toyfit3 <-ame(matnet, Xd=abattr1, print=F, family="nrm")
# Xd: 3D array of dyadic covariates (n × n × p), where each slice is a matrix of values describing pairs. 
summary(toyfit3)

# Format attr3 properly and recompute dyadic matrix
cattr3 <- c(nodeatt[,4])
abattr3 <- as.matrix(dist(cattr3, method = "manhattan"))
abattr3

# Use abattr3 in model as dyadic covariate
toyfit4 <-ame(matnet, Xd=abattr3, print=F, family="nrm")
summary(toyfit4)

# Create cross-product matrix for interactions
diffat1<--tcrossprod(attr1)
diffat1

# Extract second attribute
attr2 <- c(allatt[,2])
attr2

names(attr2)[1] <- "attr2"
attr2

# use cross product in a model, as well as Xc is column (receiver, nominee)
toyfit5.a <-ame(matnet, Xd=diffat1, Xr=attr1, Xc=attr2, print=F, family="nrm")
# Xc: Matrix of column (receiver) covariates (n × p), describing characteristics of the receiver. Often same as Xr
summary(toyfit5.a)

toyfit5.b <-ame(matnet, Xd=diffat1, Xr=attr1, Xc=attr1, print=F,family="nrm")
summary(toyfit5.b)

toyfit6 <-ame(matnet, Xd=abattr1, Xr=attr1, Xc=attr2, print=F, family="nrm")

summary(toyfit6)

# Fit model with latent factors R = 1 and R = 2
# Rank (number) of latent factors for multiplicative effects. R=0 disables latent factors; R=2 is common.
toyfit61.a <-ame(matnet, Xd=abattr1, Xr=attr1, Xc=attr2, R=1, print=F, family="nrm")
summary(toyfit61.a)

toyfit6.b <-ame(matnet, Xd=abattr1, Xr=attr1, Xc=attr2, R=2, print=F, family="nrm")
summary(toyfit6.b)

toyfit7_exercise <-ame(matnet, Xr=attr1, rvar=F, cvar=F, print=F, family="nrm")
summary(toyfit7_exercise)
