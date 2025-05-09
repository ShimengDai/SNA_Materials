
#' This document introduces how to use KliqueFinder in R and plot the networks. 
#' 
#' # **A. Get ready** 
#' ## 1. Package installation 
#' The R package for KliqueFinder is [kliqfindr](https://github.com/jtbates/kliqfindr).
#' We can store it from GitHub with [devtools](https://cran.r-project.org/web/packages/devtools/index.html). 

install.packages("devtools",repos="http://cran.us.r-project.org")
library(devtools)
devtools::install_github("jtbates/kliqfindr", force=TRUE)
library(kliqfindr)

#' 
#' The packages below are going to be used as well. We use the package [igraph]("https://igraph.org/") to create the visualization of the network. The package [RColorBrewer]("https://cran.r-project.org/web/packages/RColorBrewer/index.html)
#' provides color schemes. The package [dplyr]("https://cran.r-project.org/web/packages/dplyr/index.html") is used for data manipulation, and package [readxl]("https://cran.r-project.org/web/packages/readxl/index.html") imports the excel files (such as the .csv or .xls edgelist and attribute files)
#' 
install.packages(c("igraph","RColorBrewer","dplyr","readxl"))
library(igraph)
library(RColorBrewer)
library(dplyr)
library(readxl)

#' 
#' ## 2. Set working directory 
#' 
getwd()
#setwd("H:/MyFiles/my web page") #as an example
setwd("C:/Users/kenfrank/Dropbox/CEP 991/2021 workshop/R resources")
#setwd("C:/Users/kenfrank/OneDrive - Michigan State University/H Drive/my web page")
getwd()

#' # **B. Run Kliquefinder in R**
#' ## 1. Run your *.list* files in [kliqfindr](https://github.com/jtbates/kliqfindr)
#' 
library(readr)
ties <- read.csv("ati19x_tie.csv", header=T, as.is=T)
nodes <- read.csv("ati19x_node.csv", header=T, as.is=T)
write_delim(ties,"kliqfi.list",delim=" ",col_names=FALSE)
#setwd("~/MSUR/CEP 982/R_tutorial_materials/updated materials")
test <- winkliq_run("kliqfi.list")
## Note here: you do not need to read in the list file as a dataframe


#' ## 2. Check the subgroups
#' The output *groupbykf* contains cluster information based on KliqFinder algorithm. 
## see the column named as "actor" and "subgroup" - which actor/node is assigned to which subgroup
head(test$place)


groupbykf <- test$place[,c("actor", "subgroup")]
head(groupbykf,15) ##see the first 15 actors/nodes and their subgroup membership 


#' We can check the subgroup by the sorted nodes' id (or the other way around) and show the size of subgroups. 
## sorted node id
head(groupbykf[order(groupbykf$actor),], 15)

## sorted subgroup 
head(groupbykf[order(groupbykf$subgroup),], 15) 

## subgroup size. 
groupbykf%>%
  group_by(subgroup)%>%
  count()


#' 
#' **Note**: The [kliqfindr](https://github.com/jtbates/kliqfindr) package has stored a few example *.list* files. Usually, we write *data(package="a package name")* to list available example data sets in a certain package. For [kliqfindr](https://github.com/jtbates/kliqfindr), we need go to the R installed folder first, and locate the sub-folders of "library"-"kliqfindr"-"extdata". The example list files are stored in the "extdata" folder.
#' 
## example_stanne<- winkliq_run("~/R-3.6.2/library/kliqfindr/extdata/stanne.list")
## glimpse(example_stanne)

#' 
#' 
#' ## 3. Find the *.cluster* files to check the P-value of theta1. 
#' 
#find it in the temp directory
groupbykf.file <- list.files(path=gsub("\\\\", "/", test[["output_dir"]]), full.name=TRUE)
groupbykf.file

#grab the cluster file
clusters_file <- groupbykf.file[grep("kliqfi.clusters", groupbykf.file)]
clusters_file
#double check existence and name: if this doesn't work double check name and that rest of code is working
if (length(clusters_file) == 1 && file.exists(clusters_file)) {
  # Read the file content directly from its location
  clusters_content <- readLines(clusters_file)
  
  #finds the header
  header_line_index <- grep("PROCESSES\\|\\s+LRT\\s+\\|\\s+P-VALUE", clusters_content)
  
  if (length(header_line_index) > 0) {
    # Extract the next line after the header
    data_line <- clusters_content[header_line_index + 1]
    
    #splits the line into the three tables and values
    data_parts <- unlist(strsplit(trimws(data_line), "\\s+"))
    
    #extracts the p value
    p_value <- as.numeric(data_parts[3])
    print("P-value is")
    print(p_value)
    print ("This is for the  null hypothesis of no evidence of clusters")
  } else {
    warning("Header line not found.")
  }
} else {
  warning("kliqfi.clusters file not found.")
}


#' 
#' 
#' # **C. Make igraph objects**
#' Now we use the package [igraph]("https://igraph.org/") to convert the network raw data. The converted igraph objects will be used to merge with the cohesive subgroup membership from KliqueFinder.
#' 
#' ## 1. Read in the data from the previous example
#ties <- read.csv("ati19x_tie.csv", header=T, as.is=T)
#nodes <- read.csv("ati19x_node.csv", header=T, as.is=T)

# examine the data
glimpse(ties) # ties/ edgelist 
glimpse(nodes) #node attribute file

#check whether the a node nominated himself/herself and drop the tie if true.
subset(ties, (sender==receiver))  #who nominated themselves
#if any, we need to update the edgelist: 
#ties.1<-subset(ties, (sender!=receiver))

# check whether there are duplicated rows in the tie and node data files
nrow(ties); nrow(unique(ties[,c("sender","receiver")]))
nrow(nodes); length(unique(nodes$node))



#' 
#' 
#' ## 2. Turn the data into igraph objects 
#' We use the function *graph_from_data_frame( )* to convert the raw network data to an igraph object. 
network <- graph_from_data_frame(d=ties, vertices=nodes, directed=T)

print(network)
V(network) #Vertices/nodes and nodes' attributes
E(network) #Edges/ties, which are directed


#' 
#' You may want to compute the in-degree, out-degree, and total degree of each node. 
in.degree<-degree(network, mode="in")
#out.degree<-degree(network, mode="out")
#total.degree<-degree(network, mode="all")

in.degree
mean(in.degree)
sd(in.degree)
max(in.degree)
min(in.degree)


#' 
#' ## 3. Merge the cohesive subgroups with the igraph objects
#' In this step, we need to be careful with matching the nodes' IDs in the *groupbykf* data with the ones in the  *network* igraph objects. In many cases, the order of IDs in  *V(network)*,  *E(network)*, and *groupbykf* are not the same. 
#' 
#' The chunk below demonstrates a basic approach of attaching the cohesive subgroup membership to the node attribute object (i.e., *V(network)*). However, this approach will be correct only when *V(network)* and *groupbykf* are ordered in the same way. You may check the order of IDs. 
#' 
V(network)$community <- groupbykf$subgroup
V(network)$community

#' The chunk below shows that the subgroup membership of nodes in *V(network)* does not match with the ones in *groupbykf*. 

head(V(network)$name,10) #gives nodes (ID)
head(V(network)$community,10) #gives subgroup membership of the nodes
head(groupbykf[order(groupbykf$actor),],10) #subgroup from kliquefinder 


#' 
#' When the IDs in *V(network)* and *groupbykf* are in different orders, we can have two approaches to merge the subgroup membership correctly. One way is to use an [igraph]("https://igraph.org/") function: [*set_vertex_attr()*](https://igraph.org/r/doc/set_vertex_attr.html).
#' 
network.1<-network%>% # I suggest to use a different name whenever you update a data.
  set_vertex_attr(., name='community',
                  index=V(network),
                  value = sapply(V(network)$name, function(x){
                    groupbykf %>%
                      filter(actor == x) %>%
                      .$subgroup}))


#' We can check whether the above approach is correct. 
V(network.1)$name
V(network.1)$community
head(groupbykf[order(groupbykf$actor),],10)

#' 
#' Another way is to employ the data manipulation package *dplyr* to add the subgroup membership to the *node* data and then update the igraph object *network*. 
nodes1<-nodes%>%
  left_join(groupbykf,c("node"="actor"))
glimpse(nodes1)

#check the ID and subgroup membership
head(nodes1,15)
head(groupbykf,15)

#update the igraph object
network.2<- graph_from_data_frame(d=ties, vertices=nodes1, directed=T)

#' The memberships showing in *network.2* and *network.1* should be identical.
## ---- echo = TRUE-----------------------------------------------------------------------
V(network.2)$subgroup
V(network.1)$community

#' 
#' **Note:** In essence, the above steps are adding additional attributes to the *network* object. You can either update the *V(network)* with the additional attributes, or add the additional attributes to the original *nodes* data. Either way requires to match IDs correctly. 
#' 
#' # **D. Visualization**
#' ## 1. Subgroup membership with color
#' We first set a color palette based on the number of subgroups that each subgroup has a unique color. 
# nclus is the number of clusters identified by kliquefinder
nclus <- groupbykf %>% 
  select(subgroup) %>%
  distinct() %>% nrow

network.1$palette <- brewer.pal(nclus, "Set3")
network.1$palette

#' Now we plot the network. You can specify the color, size, shape, and position of the nodes and ties, and the layout of the network. In the plot below, nodes' colors represent the subgroup memberships. 
#' 

set.seed(1)

plot(network.1, 
     edge.arrow.size=.2, 
     vertex.color=V(network.1)$community,
     vertex.label=V(network.1)$name,
     vertex.size=7,
     layout=layout_with_fr)

##add legend 
legend("topleft", bty="n",
       legend =levels(as.factor(V(network.1)$community)),
       fill=network.1$palette,border=NA)


#' 
#' ## 2. Within-subgroup & between-subgroup 
#' For better visualization, we may consider a plot showing the nodes who have ties and are within the same subgroup are closer to each other than the ones who are not in the same subgroup while have ties. The following chunk shows how to add such a weighting scheme.
#' 

weight.community=function(row,membership,weigth.within,weight.between){
  if(as.numeric(membership[which(names(membership)==row[1])])==as.numeric(membership[which(names(membership)==row[2])])){
    weight=weigth.within
  }else{
    weight=weight.between
  }
  return(weight)
}


#' 
#' Then, we may apply the above *weight.community* function to *E(network.1)*. 

membership.wt <- V(network.1)$community
names(membership.wt) <- as.character(V(network.1)$name)

E(network.1)$weight=apply(get.edgelist(network.1),1,
                          weight.community,membership.wt,80,1)
# for each row, apply the above function of weight.community

#' 
E(network.1)$weight 
#if a pair of nodes are in the same group, their ties get a weight of 80


#' Again, we can check whether the membership are assigned correctly. 
head(get.edgelist(network.1),10) # Equivalently: head(E(network),10)
membership.wt # nodes and their subgroup memberships
head(E(network.1)$weight,10) 


#' 
#' Now we can apply the weighting scheme to layout and then plot the network. 


l.fr.wt1=layout.fruchterman.reingold(network.1,
                                     weights=E(network.1)$weight)

plot(network.1, 
     layout=l.fr.wt1,
     edge.arrow.size=.4,
     vertex.label=V(network.1)$name, 
     vertex.color=V(network.1)$community
)

##add legend 
legend("topleft", bty="n",
       legend =levels(as.factor(V(network.1)$community)),
       fill=network.1$palette,border=NA)


#' 
#' ## 3. Add other attributes: shape and size. 
#' 
#' In the above plot, the color of nodes indicates nodes' subgroup membership. Also, the lines among nodes with arrows show the ties and directions. We may want to show additional attributions of nodes and ties in the plot. 
#' 
#' For example, we may use the nodes' degree (i.e., the total number of ties of a node has received or nominated) for the nodes' size. I name the degree attribute as 
#' *attr2*. I also generate an example tie-level attribute variable named  *tie.attr*, which showed as the ties' line thickness.   
#' 

# Add variables "attr2" and "tie.attr" into the network igraph object.  

network.3<-network.1%>% 
  # I suggest to use a different name whenever you update a data.
  set_vertex_attr(., 'attr2', value=degree(.))%>% 
  set_edge_attr(., 'tie.attr', value = rbinom(ecount(.), size=6,prob=0.5)+1) 
#Consider tie.attr as an ordinal variable (e.g., a likert scale)
network.3 
V(network.3)$attr2
which(degree(network.1)==max(degree(network.1)))

E(network.3)$tie.attr

#' 
#' Now we specify the shape and size of nodes by the values of attr1 and attr2 respectively, and the size of ties by the value of tie.attr.  

#Attach attr1 as the shape of V(network.3)
levels(as.factor(V(network.3)$attr1)) #attr1=1 or 2

#If attr1=1, make the node as circle; otherwise (i.e., attr1=2), show the node as square
V(network.3)$shape <-ifelse(V(network.3)$attr1==1,"circle", "square")

# Equivalently: V(network.3)[V(network.3)$attr1==1]$shape <- "circle"
# V(network.3)[V(network.3)$attr1==2]$shape <- "square"
V(network.3)$shape 


#we can directly specify the sizes of nodes and edges in the plot function. 


plot(network.3, 
     layout=l.fr.wt1,
     edge.arrow.size=.4,
     edge.width=E(network.3)$tie.attr*0.5,
     vertex.color=V(network.3)$community,
     vertex.size=V(network.3)$attr2*2, #scaled degree
     vertex.shape=V(network.3)$shape,
     vertex.label=V(network.3)$name, 
     vertex.label.color="black",
     vertex.label.font=2,
     vertex.label.cex=0.5)

##add legend 
legend("topleft", bty="n",
       legend =levels(as.factor(V(network.1)$community)),
       fill=network.1$palette,border=NA,
       cex=0.7,
       title="Cohesive subgroup membership",
       text.font=4)

legend("bottomleft", bty="n",
       legend =levels(as.factor(V(network.1)$attr1)),
       col=17,
       pch=c(1,0), #
       cex=0.7,
       title="Attr1",
       text.font=4)

#' **Note:** igraph's shapes offers a limited choice. If you want to use other shapes, such as a triangle or a star, you need to add the shape functions accordingly first, and then attach the customized shapes to the igraph object using function [*add_shape()*](https://igraph.org/r/doc/shapes.html). 
#' 
## ---- echo = TRUE-----------------------------------------------------------------------
names(igraph:::.igraph.shapes)

#' ## 4.Interactive plot
#' Finally, you may want to use the function [*tkplot()*](https://igraph.org/r/doc/tkplot.html) to draw an interactive graph.
## ---- echo=T, results='hide'------------------------------------------------------------
tkplot(network.1,vertex.color=V(network.1)$community)

