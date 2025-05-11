setwd("C:/Users/kenfrank/Dropbox/CEP 991/2021 workshop/R resources")

# Michael T. Heaney
# University of St. Gallen
# Network Analysis
# June 13, 2016

#Lorien Jasny
#Interuniversity Consortium for Political and Social Research 
#Advanced Network Analysis
# July 19, 2016

###########################################################
###########################################################
##1 A Brief R Tutorial
###########################################################
###########################################################


###########################################################
## 1.1 Getting Started
###########################################################
##R comes with several packages already installed
##You will also want to install packages that may be relevant to your work. 
##To install the relevant packages, do so with the following code:
install.packages("network")
install.packages("sna")
install.packages("statnet")
install.packages("dplyr")
install.packages("nycflights13")
install.packages("ggplot2")
install.packages("ergm")
install.packages("nlme")
install.packages("tergm")


##To access packages, use the library command:

library(statnet)

#It is wise to set your working directory so you know where your work will be saved
#You will also need to access code and data for the workshop
#Use the dropdown menu under "Session" in RStudio or use pathfile notation

setwd("C:/Users/kenfrank/Dropbox/CEP 991/2021 workshop/R resources")
#setwd("H:/MyFiles/my web page")

getwd()#check and make sure you are the right folder
#setwd("H:/MyFiles/COURSES/SEMINAR/SEMINAR/latent space influence with ran xu/workshop materials/empirical data")

list.files()#check your files


###########################################################
##1.2 Introduction to basic R syntax
###########################################################
1 + 3 # evaluation
a <- 3 # assignment
a
a=6
a
a # evaluation
a*4
a<-3 # spacing does not matter
a <- 3 # spacing does not matter
a
a <- 4 #you can write over objects, be careful!
a

sqrt(a) # use the square root function
b <- sqrt(a) # use function and save result
b

d # evaluate something that is not there
a
b
a == b # is a equivalent to b?
a != b # is a not equal to b?
ls() # list objects in the global environment
rm(a) # remove a single object
a
a=5
a
ls()
rm(list=ls()) # remove everything from the environment
ls()

#other mathematical functions work as well
log(1000,10)#to calculat the log base of 10
10^3 #to use an exponent, just use the carrot ^

##help is here!!
help.start() # get help with R generally
?sqrt # get specific help for a function
help.start()
help.lm()
?lm
?regression
###########################################################
##1.3 Vectors and matrices in R
###########################################################
#Creating vectors using the "combine" operator
c
?c
a <- c (9, 8, 7, 6, 5, 4, 3, 2, 1) # create a vector by combining values
a
a[2] # select the second element
a[2:5] #select elements 2 thru 5

b <- c("one","three","five") # also works with strings
b
b[2]
a
b
f <-c(a[2:6])
f

a <- c(a,a) # can apply recursively
a

a <- c(a,b) # mixing types---what happens?
a # all converted to the same type, all strings now

d <- c(2,2,2) + c(2,2,2) #it is also possible to add vectors
d

d <- c(6,6,6)/c(2,2,3) #you can also subtract, multiply, or divide vectors using -, *, and /
d

#You can generate variables with the <- operator. It is pronounced "gets"
x <- 1 #assign 1 to x
x
1 -> x #this also works
x

#asking R a true/false questions about using logical statements can be useful
x>1
x>0
x==0 # is x equal to zero?
x!=0 # is x not equal to zero?

#now let's combine variables into a vector. For example:
five <- 5
six <- 6
seven <- 7
eight <- 8
nine <- 9

five
six 
seven
eight
nine

count_five_to_nine <- c(five, six, seven, eight, nine)
count_five_to_nine

count_five_to_nine[1:3] #select a subset
count_five_to_nine[1:5] #select all

#Using sequences and replication to create vectors
a <- seq(from=1,to=5,by=1) # from 1 to 5 the slow way
b <- 1:5 # a shortcut!
a==b # all TRUE
rep(1,times=5) # a lot of ones
rep(1:5,times=2) # repeat an entire sequence
rep(1:5,each=2) # same, but element-wise
rep(1:5,times=5:1) # can vary the count of each element

#let's clear the global environment
ls()#to see all R objects
rm(eight) # remember how to remove a single object
ls()
rm(list=ls()) # remove everything from the environment
ls()

#From vectors to matrices
a <- matrix(data=1:25, nrow=5, ncol=5) # create a matrix the "formal" way
a <- matrix(data=0:0, nrow=5, ncol=5) # create a matrix the "formal" way
a
a[1,2] # select a matrix element (two dimensions) [row, column]
a[1,] # just the first row
all(a[1,]==a[1,1:5]) # show the equivalence
a[,2] # can also perform for columns
a[2:3,3:5] # select submatrices
a[-1,] # nice trick: negative numbers omit cells!
a[-2,-2] # get rid of row two, column two

b <- cbind(1:5,7:12) # another way to create matrices
b[6,1]<-NA
b
d <- rbind(1:5,1:5) # can perform with rows, too
d
cbind(b,d) # no go: must have compatible dimensions!
dim(b) # what were those dimensions, anyway?
dim(d)
NROW(b)
NCOL(b)
cbind(b,b) # combining two matrices

t(b) # can transpose b
cbind(t(b),d) # now it works
rbind(t(b),d) # now it works


###########################################################
##1.4 More on element-wise operations
###########################################################
a <- 1:5
a + 1 # addition
a * 2 # multiplication
a / 3 # division
a - 4 # subtraction
a ^ 5 # you get the idea...

a + a # also works on pairs of vectors
a * a
a + 1:6 # problem: need same length

a <- rbind(1:5,2:6) # same principles apply to matrices
b <- rbind(3:7,4:8)
a + b
a / b
a %*% t(b) # matrix multiplication

#logical operators (generally) work like arithmetic ones
a > 0 # each value greater than zero?
a == b # corresponding values equivalent?
a != b # corresponding values not equivalent?
!(a == b) # same as above
(a>2) | (b>4) # the OR operator
(a>2) & (b>4) # the AND operator


###########################################################
##1.5 Data Frames
###########################################################
d <- data.frame(income=1:5,sane=c(T,T,T,T,F),name=LETTERS[1:5])
d
d[1,2] # acts a lot like a matrix!
d[,1]*5
d[-1,]
d$sane # can use dollar sign notation
d$sane[3]<-FALSE # making changes
d
d[2,3] # shows factors for string values
d[2,3]<-"F"

#if you want to do without factors
d$name <- LETTERS[1:5] # eliminate evil factors by overwriting
d[2,3]

#or, create it without factors
d <- data.frame(income=1:5,sane=c(T,T,T,T,F),name=LETTERS[1:5],stringsAsFactors=FALSE)
d[2,3]<-"F"
d[2,3]
d

d <- as.data.frame(cbind(1:5,2:6)) # can create from matrices
d
is.data.frame(d) # how can we tell it's not a matrix?
is.matrix(d) # the truth comes out


###########################################################
##1.6 Finding built-in data sets
###########################################################
#Many packages have built-in data for testing and educational purposes
data() # lists them all
?USArrests # get help on a data set
data(USArrests) # load the data set
USArrests # view the object


###########################################################
##1.7 Elementary visualization
###########################################################
#R's workhorse is the "plot" command
plot(USArrests$Murder,USArrests$UrbanPop) # using dollar sign notation
xaxis=USArrests$Murder
yaxis=USArrests$UrbanPop
plot(xaxis,yaxis) # using dollar sign notation
?plot
plot(USArrests$Murder,USArrests$UrbanPop,log="xy") # log-log scale

#Adding plot title and axis labels
plot(USArrests$Murder,USArrests$Assault,xlab="Murder",ylab="Assault",main="USArrests")

#Can also add text
plot(USArrests$Murder,USArrests$Assault,xlab="Murder",ylab="Assault", main="USArrests",type="n")
text(USArrests$Murder,USArrests$Assault,rownames(USArrests))

#Histograms and boxplots are often helpful
hist(USArrests$Murder)
boxplot(USArrests)

rm(list=ls()) # remove everything from the environment
ls()

###########################################################
###########################################################
##2 dplyr, the influence model
###########################################################
###########################################################


###########################################################
# 2.1 influence.R
###########################################################

library(dplyr) # need to install with install.packages("dplyr") if not already installed (just need to do first time)

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
# merge data1 and data2
# note: we want the nominee's indegree because this is who the nominator is being exposed to

data <- left_join(data1, data2, by = "nominee")
#george <- as.character(data$nominee) # this makes merging later easier
#george
data$nominee <- as.character(data$nominee) # this makes merging later easier

# calculate indegree in tempdata and merge with data
tempdata <- data.frame(table(data$nominee))
names(tempdata) <- c("nominee", "indegree") # rename the column "nominee"
tempdata$nominee <- as.character(tempdata$nominee) # makes nominee a character data type, instead of a factor, which can cause problems
tempdata
data <- left_join(data, tempdata, by = "nominee")
data
# Calculating exposure and an exposure term that uses indegree, exposure_plus
data$exposure <- data$relate * data$yvar1
data$exposure_plus <- data$exposure * (data$indegree + 1)
data
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
mean_exposure_plus

# need a final data set with mean_exposure, mean_exposure_plus, degree, yvar1, and yvar2 added

mean_exposure_terms <- dplyr::left_join(mean_exposure, mean_exposure_plus, by = "nominator")
mean_exposure_terms
names(data2) <- c("nominator", "yvar1") # rename nominee as nominator to merge these
final_data <- dplyr::left_join(mean_exposure_terms, data2, by = "nominator")
final_data <- dplyr::left_join(final_data, data3, by = "nominator") # data3 already has nominator, so no need to change
final_data
# regression (linear models)

model1 <- lm(yvar2 ~ yvar1 + exposure_mean, data = final_data)
summary(model1)

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
setwd("H:/MyFiles/my web page")

#Sample_CSV_File <- read.csv(file.choose())#if you want to choose from your hard drive
#Sample_CSV_File #check and make sure it looks like the .csv file

#If you want to import row and column labels
#Sample_CSV_File_New <- read.csv(file.choose())
#, header=TRUE, row.names=1)
#Sample_CSV_File_New

#even though we have been call this a network it's not really a network

#class(Sample_CSV_File_New)#we can find out by askng R the "class"

#In order to convert this data frame to a network, let's first convert it first to a matrix, then to a network
#Sample_CSV_New_Matrix <- as.matrix(Sample_CSV_File_New)#first save it as a matrix
#Sample_CSV_New_Matrix

#summary(Sample_CSV_New_Matrix)

#we can also just import it directly as a matrix
#Sample_CSV_New_Matrix  <- as.matrix(read.csv("Sample_CSV_File_New.csv", header = TRUE,
#                                             row.names = 1, stringsAsFactors = FALSE))

#Now let's finally convert the matrix to a network
#Note that, in this case, we must explicitly tell R that we have a bipartite (i.e., two-mode) network.
#Sample_CSV_Network <- as.network(Sample_CSV_New_Matrix, bipartite=TRUE)

#class(Sample_CSV_Network)#check the class

#summary(Sample_CSV_Network)

#If you want to read bipartite data from edgelists
Sample_Edgelist  <- read.csv("homact.csv", header=TRUE)#read in csv file and convert to a matrix
Sample_Edgelist_Matrix <- as.matrix(Sample_Edgelist)
Sample_Edgelist_Matrix
#The bipartite=6 part of this command tells us to treat the first six labels as belonging to the first mode and, by default, the remaining labels as belonging to the second mode.
Sample_Edgelist_Network <- as.network(Sample_Edgelist_Matrix, bipartite=18, directed=FALSE)#bipartite networks are usually undirected

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

