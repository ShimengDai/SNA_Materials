
#install packages first if you haven't
#install.packages("")
library(RSiena)
library(sna)
library(statnet)
library(latentnet)
library(igraph)

#Read data - assuming data are in current working directory
Toyatt <-read.csv("Toyatt.csv")
Toynet <-read.csv("Toynet.csv")

Toynet.data <- graph.data.frame(Toynet)
Toynet.adj <-get.adjacency(Toynet.data, sparse = FALSE, attr='weight')
g1 <- network(as.matrix(Toynet.adj))
Toynet.m <- as.matrix(Toynet.adj)

g1%v%"attr1" <- Toyatt[,2]
g1%v%"attr2" <- Toyatt[,3]
g1%v%"cattr3" <- Toyatt[,4]

set.seed(57)
m1<-ergmm(g1 ~ euclidean(d = 2)+absdiff("attr1")+absdiff("attr2")+absdiff("cattr3"),control=ergmm.control(sample.size=5000,burnin=20000,interval=10,Z.delta=5))
plot(m1)

#Two latent positions
m1$mkl$Z

latent_pos1<-rep(m1$mkl$Z[,1],2)
latent_pos1

latent_pos2<-rep(m1$mkl$Z[,2],2)
latent_pos2

E<-matrix(0,6,3)
for (i in 1:6)
{    #making exposure term
  if (sum(Toynet.m[i,])!=0)
    E[i,1]<-(Toynet.m[i,]%*%Toyatt[,2])/sum(Toynet.m[i,])
  if (sum(Toynet.m[i,])!=0)
    E[i,2]<-(Toynet.m[i,]%*%Toyatt[,3])/sum(Toynet.m[i,])
}

att_1_2<-c(Toyatt[,2],Toyatt[,3])
expo<-c(E[,2],E[,1])
cattr3 <-rep(Toyatt[,4],2)

infl<-data.frame(cbind(latent_pos1, latent_pos2, att_1_2, cattr3, expo, rep(c(1:6),2),rep(c(1:2),each=6)))

# model1
summary(lm(att_1_2~expo ,data=infl))

# model2
summary(lm(att_1_2~expo+latent_pos1,data=infl))

# model3
summary(lm(att_1_2~expo + latent_pos1 + latent_pos2,data=infl))

# model4
summary(lm(att_1_2~expo + latent_pos1 + latent_pos2 + cattr3 ,data=infl))
