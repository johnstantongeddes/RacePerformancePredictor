library(rvest)
library(RSelenium)
library(stringr)
library(ggplot2)
library(lubridate)
library(dplyr)

source("toSeconds.R")

# set up Selenium connection
checkForServer()
startServer()
remDr <- remoteDriver()
remDr$open()


#################################################
## Get list of athletes
#################################################

citylist <- c("Burlington%20VT", "Minneapolis%20MN", "Boston%20MA", "Atlanta%20GA", 
              "Denver%20CO", "Philadelphia%20PA", "New%20York%NY", "Miami%20FL",
              "San%20Francisco%20CA", "Los%20Angeles%20CA", "Chicago%20IL",
              "Nashville%20TN", "Austin%20TX", "Flagstaff%AZ", "Portland%20OR")

# dataframe to collect results
pb_data <- data.frame(id = as.character(NULL), gender = NULL, age = NULL, town = NULL, state = NULL,  
                        distance = as.character(NULL), time = as.character(NULL))

for(cl in citylist) {
  # create url
  thisurl <- paste0("http://www.athlinks.com/Search/Athletes?PageSize=100&SearchMode=All&Sort=racecount&SearchTerm=&Gender=+&FromAge=16&ToAge=99&Location=", cl, "&WithinRange=100&CategoriesFilter.RunningCategory=true&CategoriesFilter.RunningCategory=false&CategoriesFilter.RunningUpTo5k=false&CategoriesFilter.RunningFrom5kTo15k=false&CategoriesFilter.RunningFrom15kToHalfMara=false&CategoriesFilter.RunningMarathon=true&CategoriesFilter.RunningMarathon=false&CategoriesFilter.RunningUltra=false&CategoriesFilter.RunningFromHalfMaraToMara=false&CategoriesFilter.TriathlonCategory=false&CategoriesFilter.Sprint=false&CategoriesFilter.Olympic=false&CategoriesFilter.HalfIronman=false&CategoriesFilter.IronmanAndUp=false&CategoriesFilter.Aquathlon=false&CategoriesFilter.Aquabike=false&CategoriesFilter.Duathlon=false&CategoriesFilter.MoreCategories=false&CategoriesFilter.Swim=false&CategoriesFilter.MountainBike=false&CategoriesFilter.Cycling=false&CategoriesFilter.Snow=false&CategoriesFilter.Adventure=false&CategoriesFilter.Obstacle=false&CategoriesFilter.Other=false")
  
  # open athlete search page
  remDr$navigate(thisurl)
  
  #allow page to load
  Sys.sleep(3)
  
  # get page source
  athlete_search<-remDr$getPageSource()
  # parse links to athletes
  athlete_links <- html(athlete_search[[1]]) %>%
    html_nodes(".strong") %>%
    html_attr("href")
  
  sub_data <- data.frame(id = as.character(NULL), gender = NULL, age = NULL, town = NULL, state = NULL,  
                         distance = as.character(NULL), time = as.character(NULL))
  
  # loop across list, pull athlete results
  for(i in 3:length(athlete_links)) {
    print(athlete_links[i])
    # open page
    atlink <- paste0("http://www.athlinks.com", athlete_links[i])
    remDr$navigate(atlink)
    Sys.sleep(1)
    
    athlete_page <- remDr$getPageSource()
    
    # scrape personal info
    pi <- html(athlete_page[[1]]) %>% html_nodes(".personal-info span") %>%
      html_text()  
    
    # scrape personal bests
    pb <- html(athlete_page[[1]]) %>% html_nodes(".time span , .event-type span") %>%
      html_text() 
    
    if(length(pb) > 0) {
      pbdf <- data.frame(
        id = str_split_fixed(athlete_links[i], pattern = "/", n=3)[3],
        gender = pi[1],
        age = pi[3],
        town = pi[4],
        state = pi[6],
        distance = pb[seq(1,length(pb), by=2)],
        time = pb[seq(2,length(pb), by=2)],
        stringsAsFactors = FALSE)
      
      # bind to dataframe
      sub_data <- rbind(sub_data, pbdf)
    } # end if 
  } # end for athlete
  pb_data <- rbind(pb_data, sub_data)
} # end for citylist


# convert time to seconds
pb_data <- pb_data %>%
  mutate(totalseconds = toSeconds(time))

# remove gender not M/F
pb_data <- pb_data %>%
  filter(gender %in% c("M", "F"))