install.packages("amen")
library(amen)
install.packages("igraph")
library(igraph)
setwd("C:/Users/kenfrank/Dropbox/CEP 991/R tutorial materials/final")
setwd("C:/Users/kenfrank/Dropbox/CEP 991/R tutorial materials/final")

edgelist <- read.csv("toynet.csv", header=T, as.is=T)
head(edgelist, n = 3)
matnet <-as.matrix(get.adjacency(graph.data.frame(edgelist)))
matnet
nodes <- read.csv("toyatt.csv", header=T, as.is=T)
head(nodes,n = 3)
nodeatt <-as.matrix(nodes)
nodeatt

allatt<-matrix(nrow=6,ncol=2)
allatt

allatt[,1]<-nodeatt[,2]
allatt

allatt[,2]<-nodeatt[,3]
allatt

colnames(allatt)<- c("attr1", "attr2")
allatt

toyfit1 <-ame(matnet, Xr=allatt, print=F, family="nrm")
summary(toyfit1)

attr1 <- c(allatt[,1])
attr1

names(attr1)[1] <- "attr1"
attr1
?ame
#estimate a new model with only attribute 1
toyfit2 <-ame(matnet, Xr=attr1, rvar=F, cvar=F, print=F, family="nrm")
summary(toyfit2)

abattr1 <- as.matrix(dist(attr1, method = "manhattan"))
abattr1

attr3 <-nodeatt[,4]
attr3
abattr3 <- as.matrix(dist(attr3, method = "manhattan"))
abattr3

#estimate model, Xd is dyadic covariate
toyfit3 <-ame(matnet, Xd=abattr1, print=F, family="nrm")
summary(toyfit3)

cattr3 <- c(nodeatt[,4])
cattr3

abattr3 <- as.matrix(dist(cattr3, method = "manhattan"))
abattr3

#use abattr3 in model as dyadic covariate
toyfit4 <-ame(matnet, Xd=abattr3, print=F, family="nrm")
summary(toyfit4)

diffat1<--tcrossprod(attr1)
diffat1

attr2 <- c(allatt[,2])
attr2

names(attr2)[1] <- "attr2"
attr2

#use cross product in a model, as well as Xc is column (receiver, nominee)
toyfit5.a <-ame(matnet, Xd=diffat1, Xr=attr1, Xc=attr2, print=F, family="nrm")
summary(toyfit5.a)

toyfit5.b <-ame(matnet, Xd=diffat1, Xr=attr1, Xc=attr1, print=F,family="nrm")
summary(toyfit5.b)

toyfit6 <-ame(matnet, Xd=abattr1, Xr=attr1, Xc=attr2, print=F, family="nrm")

summary(toyfit6)

toyfit61.a <-ame(matnet, Xd=abattr1, Xr=attr1, Xc=attr2, R=1, print=F, family="nrm")
summary(toyfit61.a)

toyfit6.b <-ame(matnet, Xd=abattr1, Xr=attr1, Xc=attr2, R=2, print=F, family="nrm")
summary(toyfit6.b)

toyfit7_exercise <-ame(matnet, Xr=attr1, rvar=F, cvar=F, print=F, family="nrm")
summary(toyfit7_exercise)
