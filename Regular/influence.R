# This Introduction to R script was adapted from Ken Franks code

# Jordan Tait
# Measurement and Quantitative Methods | Michigan State University
# 2021

###########################################################
###########################################################
##2 dplyr, the influence model
###########################################################
###########################################################


###########################################################
# 2.1 influence.R
###########################################################

#only need to do this once:
install.packages("dplyr")
library(dplyr) # need to install with 
#if not already installed (just need to do first time)

data1 <- data.frame(nominator = c(2, 1, 3, 1, 2, 6, 3, 5, 6, 4, 3, 4), 
                    nominee = c(1, 2, 2, 3, 3, 3, 4, 4, 4, 5, 6, 6), 
                    relate = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1))
data1
data2 <- data.frame(nominee = c(1, 2, 3, 4, 5, 6), 
                    yvar1 = c(2.4, 2.6, 1.1, -0.5, -3, -1))
data2
data3 <- data.frame(nominator = c(1, 2, 3, 4, 5, 6),
                    yvar2 = c(2, 2, 1, -0.5, -2, -0.5))
data3
#ALTERNATIVE: if you want to read data from a file
#setwd("C:/Users/kenfrank/OneDrive - Michigan State University/H Drive/my web page")
#data1 <- read.csv(file="toynet.csv")
#toynet.csv at https://drive.google.com/file/d/1kDNQLAGkFr5iezEHcoWpNJuXME-ekMC3/view?usp=sharing
#data1 %>% 
#  rename(
#    nominator = sender,
#    nominee = receiver,
#    relate = weight  )
#data1

#data2b <- read.csv(file="toyatt.csv")
#data2b
# toyatt.csv at: https://drive.google.com/file/d/1Fkkue9aswTbqctE-_mJ_wWchwMu6tOKP/view?usp=sharing
#data2b$nominee <- data2b$node
#data2b$yvar1 <- data2b$attr1
#keeps <- c("nominee","yvar1")
#data2=data2b[keeps]
#data2

#data3 <- as.data.frame(data2b)
#data3$nominator <-data3$node
#data3$yvar2 <-data3$attr2
#keeps <- c("nominator","yvar2")
#data3 = data3[keeps]
#data3
# merge data1 and data2
# note: we want the nominee's indegree because this is who the nominator is being exposed to

data <- left_join(data1, data2, by = "nominee")
data$nominee <- as.character(data$nominee) # this makes merging later easier

# calculate indegree in tempdata and merge with data
tempdata <- data.frame(table(data$nominee))
names(tempdata) <- c("nominee", "indegree") # rename the column "nominee"
tempdata$nominee <- as.character(tempdata$nominee) # makes nominee a character data type, instead of a factor, which can cause problems
data <- left_join(data, tempdata, by = "nominee")

# Calculating exposure and an exposure term that uses indegree, exposure_plus
data$exposure <- data$relate * data$yvar1
data$exposure
data$exposure_plus <- data$exposure * (data$indegree + 1)

# Calculating mean exposure
mean_exposure <-
  data %>%
  group_by(nominator) %>%
  summarize(exposure_mean = mean(exposure))
mean_exposure
mean_exposure_plus <-
  data %>%
  group_by(nominator) %>%
  summarize(exposure_plus_mean = mean(exposure_plus))

# need a final data set with mean_exposure, mean_exposure_plus, degree, yvar1, and yvar2 added

mean_exposure_terms <- dplyr::left_join(mean_exposure, mean_exposure_plus, by = "nominator")

names(data2) <- c("nominator", "yvar1") # rename nominee as nominator to merge these
final_data <- dplyr::left_join(mean_exposure_terms, data2, by = "nominator")
final_data <- dplyr::left_join(final_data, data3, by = "nominator") # data3 already has nominator, so no need to change
final_data
# regression (linear models)
model1 <- lm(yvar2 ~ yvar1 + exposure_mean, data = final_data)
summary(model1)

#create partial residual plots
install.packages("partial.plot")
library(partial.plot)
partial.plot(model1, c("exposure_mean","yvar1"))

model2 <- lm(yvar2 ~ yvar1 + exposure_plus_mean, data = final_data)
summary(model2)

rm(list=ls())

###########################################################
# 2.2 data manipulation with dplyr
###########################################################

library(dplyr)
library(ggplot2)
library(nycflights13)

str(flights) # view the structure
head(flights) # just the first couple of rows
View(flights) # spreadsheet view

filter(flights, month == 1, day == 1) # filter rows by conditions

arrange(flights, year, month, day) # arrange by column names

arrange(flights, desc(arr_delay)) # arrange in descending order

select(flights, year, month, day) # select columns by name

select(flights, year:day) # select all columns between year and day (inclusive)

select(flights, tail_num = tailnum) # select and rename

distinct(flights, tailnum) # returns only unique values
distinct(flights, origin, dest) # returns unique sets of values

# creates new variables
mutate(flights,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60)

mutate(flights,
       gain = arr_delay - dep_delay,
       gain_per_hour = gain / (air_time / 60)
)

sample_n(flights, 10) # sample n
sample_frac(flights, 0.01) # sample proportion

# aggregate
by_tailnum <- group_by(flights, tailnum) # group by tailnum
delay <- summarise(by_tailnum, # for each tailnum "group", create these summary statistics
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))
delay <- filter(delay, count > 20, dist < 2000)
delay

# another way to write this (using pipes)

flights %>% 
  group_by(tailnum) %>% 
  summarize(count = n(),
            dist = mean(distance, na.rm = T),
            delay = mean(arr_delay, na.rm = T)) %>% 
  filter(delay, count > 20, dist < 2000)

# plot using ggplot2
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2)

# with a line of best fit (i.e., linear model / regression)
ggplot(delay, aes(dist, delay)) +
  geom_point(aes(size = count), alpha = 1/2) +
  stat_smooth(method = "lm")


###########################################################
###########################################################
##3 network objects: importing and exploring networkk data
###########################################################
###########################################################


###########################################################
##3.1 Built-in Network Datasets and .Rdata files
###########################################################

library(network) # Make sure that network package is loaded
data(package="network") # List available datasets in network package
data(flo) # Load a built-in data set; see ?flo for more
flo # Examine the flo adjacency matrix
class(flo)

#to save R data,
save(flo,file="myNewData_flo.Rdata")

#or, to save your whole workspace,
save.image("allMyWorkAsOfRightNow.Rdata")

#For more information. . .
?data 
?flo


###########################################################
##3.2 Importing Relational Data
###########################################################

#Be sure to be in the directory where you stored the data for the workshop.
getwd() # Check what directory you're in
list.files() # Check what's in the working directory

#Read an adjacency matrix (R stores it as a data frame by default)
relations <- read.csv("relationalData.csv",header=FALSE,stringsAsFactors=FALSE)
relations
#Here's a case where matrix format is preferred
relations <- as.matrix(relations) # convert to matrix format

#Read in some vertex attribute data (okay to leave it as a data frame)
nodeInfo <- read.csv("vertexAttributes.csv",header=TRUE,stringsAsFactors=FALSE)
nodeInfo

#Since our relational data has no row/column names, let's set them now
rownames(relations) <- nodeInfo$name
colnames(relations) <- nodeInfo$name
relations

#For more information. . .
?list.files
?read.csv
?as.matrix
?rownames


###########################################################
##3.3 Creating network objects
###########################################################

nrelations<-network(relations,directed=FALSE) # Create a network object based on relations
nrelations # Get a quick description of the data
nempty <- network.initialize(5) # Create an empty graph with 5 vertices
nempty # Compare with nrelations

#For more information. . .
?network 
?as.network.matrix


###########################################################
##3.4 Description and Visualization
###########################################################

summary(nrelations) # Get an overall summary
network.dyadcount(nrelations) # How many dyads in nflo?
network.edgecount(nrelations) # How many edges are present?
network.size(nrelations) # How large is the network?
as.sociomatrix(nrelations) # Show it as a sociomatrix
nrelations[,] # Another way to do it

par(mfrow = c(1,2))#change your view to compare networks

plot(nrelations,displaylabels=T) # Plot with names
plot(nrelations,displaylabels=T,mode="circle") # A less useful layout...

library(sna) # Load the sna library
gplot(nrelations) # Requires sna
gplot(relations,displaylabels = TRUE) # gplot Will work with a matrix object too

#For more information. . .
?summary.network
?network.dyadcount
?network.edgecount
?as.sociomatrix
?as.matrix.network
?is.directed

###########################################################
##3.5 Network and Vertex Attributes 
###########################################################
#Add some attributes
nrelations %v% "id" <- nodeInfo$id # Add in our vertex attributes
nrelations %v% "age" <- nodeInfo$age
nrelations %v% "sex" <- nodeInfo$sex
nrelations %v% "handed" <- nodeInfo$handed
nrelations %v% "lastDocVisit" <- nodeInfo$lastDocVisit

#Listing attributes
list.vertex.attributes(nrelations) # List all vertex attributes
list.network.attributes(nrelations) # List all network attributes

#Retrieving attributes
nrelations %v% "age" # Retrieve vertex ages
nrelations %v% "id" # Retrieve vertex ids

#For more information. . .
?attribute.methods


###########################################################
##3.6 Edgelists
###########################################################
#The sna package also supports a special kind of matrix called an edgelist." These are three-column matrices, each row of which represents an edge (via its sender, recipient, and value, respectively). These sna edgelists" have special attributes that indicate their size, vertex names (if any), and bipartite status (if applicable).
eflo<-as.edgelist.sna(flo) # Coerce flo to an sna edgelist
eflo
attr(eflo,"n") # How many vertices are there?
attr(eflo,"vnames") # Are there vertex names?
as.sociomatrix.sna(eflo) # Can transform back w/ as.sociomatrix.sna 

#For more information. . .
?as.edgelist.sna
?as.sociomatrix.sna
?attr
?sna

###########################################################
##3.7 Bipartite (Two-Mode) Data
###########################################################

##first, let's review a bit more about reading in network files

#Note that we have given the name "Sample_CSV_File", but we could have named it anything we liked
#If we don't want the colum or row names
Sample_CSV_File <- read.csv("Sample_CSV_File.csv", header=FALSE)#we need to type header=FALSE or R will assume that the first row of data are the header
Sample_CSV_File <- read.csv(file.choose())#if you want to choose from your hard drive
Sample_CSV_File #check and make sure it looks like the .csv file

#If you want to import row and column labels
Sample_CSV_File_New <- read.csv("Sample_CSV_File_New.csv", header=TRUE, row.names=1)
Sample_CSV_File_New

#even though we have been call this a network it's not really a network

class(Sample_CSV_File_New)#we can find out by askng R the "class"

#In order to convert this data frame to a network, let's first convert it first to a matrix, then to a network
Sample_CSV_New_Matrix <- as.matrix(Sample_CSV_File_New)#first save it as a matrix
Sample_CSV_New_Matrix

summary(Sample_CSV_New_Matrix)

#we can also just import it directly as a matrix
Sample_CSV_New_Matrix  <- as.matrix(read.csv("Sample_CSV_File_New.csv", header = TRUE,
                                             row.names = 1, stringsAsFactors = FALSE))

#Now let's finally convert the matrix to a network
#Note that, in this case, we must explicitly tell R that we have a bipartite (i.e., two-mode) network.
Sample_CSV_Network <- as.network(Sample_CSV_New_Matrix, bipartite=TRUE)

class(Sample_CSV_Network)#check the class

summary(Sample_CSV_Network)

#If you want to read bipartite data from edgelists
Sample_Edgelist  <- read.csv("Sample_Edgelist.csv", header=FALSE)#read in csv file and convert to a matrix
Sample_Edgelist_Matrix <- as.matrix(Sample_Edgelist)

#The bipartite=6 part of this command tells us to treat the first six labels as belonging to the first mode and, by default, the remaining labels as belonging to the second mode.
Sample_Edgelist_Network <- as.network(Sample_Edgelist_Matrix, bipartite=6, directed=FALSE)#bipartite networks are usually undirected

summary(Sample_Edgelist_Network)


#To convert two-mode to one-mode
#Matrix multipliation is performed using %*%
#note that we are using the matrix file for this step

#to make one mode projections by row
one_mode_projection_rows <- Sample_CSV_New_Matrix %*% t(Sample_CSV_New_Matrix)
one_mode_projection_rows[,]
one_mode_projection_rows <- as.network(one_mode_projection_rows)
one_mode_projection_rows

#to make one mode projections by column
one_mode_projection_columns <- t(Sample_CSV_New_Matrix) %*% Sample_CSV_New_Matrix
one_mode_projection_columns[,]
one_mode_projection_columns <- as.network(one_mode_projection_columns)
one_mode_projection_columns

par(mfrow = c(1,2))#change your view to compare networks

plot(Sample_Edgelist_Network,displaylabels=T)
plot(one_mode_projection_rows,displaylabels=T)
plot(one_mode_projection_columns,displaylabels=T)