# First we will want to load the tidyverse, a commonly used
# package for data analysis in R.

packages <- c("tidyverse","data.table", "lubridate", 'ggplot2')
lapply(packages, library, character.only = TRUE)

# First we will want to set up our directories, explain globals, etc.
# To do that we store these strings in variables
setwd("/Users/mariadelmar/Dropbox/Predoc 22/Coding Exercise pt2")
input_dir = "input"
intermediate_dir = "intermediate"
output_dir = "output"

df = read_csv(str_interp("${input_dir}/ira_tweets_csv_hashed.csv"))


# make panel

# Add blm count variable
df$blm_tweet <- as.numeric(str_detect(df$tweet_text, regex('Black Lives Matter|BLM', ignore_case = T)))

df$Date <- as.Date(df$tweet_time)
panel <- df %>%
  group_by(Date) %>%
  summarise(tweet_count = n(),
            quote_count = mean(quote_count),
            reply_count = mean(reply_count),
            retweet_count = mean(retweet_count),
            like_count = mean(like_count),
            blm_count = sum(blm_tweet))


# make yearly graph 
panel_year <- df %>%
mutate(Year=year(Date))  %>%
group_by(Year) %>%
summarise(tweet_count = n(),
            quote_count = sum(quote_count, na.rm=TRUE),
            reply_count = sum(reply_count, na.rm=TRUE),
            retweet_count = sum(retweet_count, na.rm=TRUE),
            like_count = sum(like_count, na.rm=TRUE),
            blm_count = sum(blm_tweet, na.rm=TRUE))



p<- ggplot(panel_year, aes(x=Year, y=blm_count)) +
  geom_line()
p


# create function to loop over each event:

events <- data.frame(event_date = c("2015-08-19", "2015-07-13", "2016-07-05"))
events$event_date <- as.Date(events$event_date)
 
time_window <- 30
for(i in 1:3){
  # set event date
  event_date <- events$event_date[i]
  # subset by if date is within 30 days of event
  ddf <- panel
  ddf$diff <- ddf$Date - event_date
  ddf$window <- ifelse(((ddf$diff < time_window)&(ddf$diff >= -time_window)), 1,0)
  ddf <- filter(ddf, window == 1)
  # add the needed variables to run our model:
  ddf$X <- ifelse(ddf$diff >= 0,1,0)
  # loop over every variable
  # and print summary
  for(x in 2:7){
    model <- lm(paste(colnames(ddf)[x], " ~ X"), data=ddf)
    print(paste(colnames(ddf)[x]))
    print(summary(model))
  }
}               
                         