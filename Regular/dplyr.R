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