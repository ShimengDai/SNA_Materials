###########################################################
# 2.1 influence.R
###########################################################

# Adapted by Shimeng Dai (2025)
# Based on original script by Ken Frank and Jordan Tait
# Measurement and Quantitative Methods | Michigan State University


#install.packages("dplyr") #only need to do this once:
library(dplyr) # need to install with 
#if not already installed (just need to do first time)


# edgelist
data1 <- data.frame(nominator = c(2, 1, 3, 1, 2, 6, 3, 5, 6, 4, 3, 4), 
                    nominee = c(1, 2, 2, 3, 3, 3, 4, 4, 4, 5, 6, 6), 
                    relate = c(1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)) # interaction weight
data1

# prior attribute measure 
data2 <- data.frame(nominee = c(1, 2, 3, 4, 5, 6), # node ID
                    yvar1 = c(2.4, 2.6, 1.1, -0.5, -3, -1)) 
data2

# post attribute measure 
data3 <- data.frame(nominator = c(1, 2, 3, 4, 5, 6), # node ID
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

# attach the prior measure of nominees to the edgelist, facilitating the calculation of exposure term later
data <- left_join(data1, data2, by = "nominee")  
data$nominee <- as.character(data$nominee) # this makes merging later easier

# calculate indegree in tempdata and merge with data
tempdata <- data.frame(table(data$nominee)) # calculate the number of times a node has been nominated as a nominee
names(tempdata) <- c("nominee", "indegree") # rename the column "nominee"
tempdata$nominee <- as.character(tempdata$nominee) # makes nominee a character data type, instead of a factor, which can cause problems
data <- left_join(data, tempdata, by = "nominee") # attach indgree of nominee to the main dataset

# Calculating exposure and an exposure term that uses indegree, exposure_plus
data$exposure <- data$relate * data$yvar1
data$exposure

# Adding 1 to indegree ensures that nodes with zero indegree still get a non-zero exposure_plus value.
# Assign more weight when exposing to someone with a higher indegree
data$exposure_plus <- data$exposure * (data$indegree + 1)
data$exposure_plus

# Calculating mean exposure
mean_exposure <-
  data %>%
  group_by(nominator) %>%  # calcualte total exposure each nominator receives based on the attributes (yvar1) of the people they nominated.
  summarize(exposure_mean = mean(exposure)) # calculate the average exposure each nominator receives
mean_exposure

# Calculating mean exposure with indegree
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

#create partial plots
#install.packages("car")
library(car)
avPlots(model1)


model2 <- lm(yvar2 ~ yvar1 + exposure_plus_mean, data = final_data)
summary(model2)

avPlots(model2)

rm(list=ls()) # remove all R objects from the environment