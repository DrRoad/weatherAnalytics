#Using forecast.IO API to get weather data for given location and time

#Setwd your input file directory
devtools::install_github("hrbrmstr/Rforecastio")
library(Rforecastio)
library(RJSONIO)
library(dplyr)
library(httr)

#Set API key in environment variable
#You must have FORECASTIO_API_KEY in your .Renvion file for this to work
#Copy paste the key into console first time you run the following function
forecastio_api_key()

#x<- get_forecast_for(24.683333,72.833333,"2015-06-29T12:00:00+0530",config=list(ssl.verifypeer=F))

locations <- "locations.csv"
timestamps <- "timestamps.csv"

# Get locations, timestamps for query
loc <- read.csv(locations)
tim <- read.csv(timeStamps, stringsAsFactors=FALSE)

# Merge location and time data
locTim <- merge(loc, tim)
#locTim <- locTim[1:5,]

# Template for record of weather data (32 variables)
weatherMasterTemplate <- data.frame(
  time=as.POSIXct(integer(), origin="1970-01-01"), 
  summary=character(),
  icon=character(),
  sunriseTime=as.POSIXct(integer(), origin="1970-01-01"),
  sunsetTime=as.POSIXct(integer(), origin="1970-01-01"),
  moonPhase=numeric(),
  nearestStormDistance=numeric(),
  nearestStormBearing=numeric(),
  precipIntensity=numeric(),
  precipIntensityMax=numeric(),
  precipIntensityMaxTime=numeric(),
  precipProbability=numeric(),
  precipType=character(),
  precipAccumulation=numeric(),
  temperature=numeric(),
  temperatureMin=numeric(),
  temperatureMinTime=as.POSIXct(integer(), origin="1970-01-01"),
  temperatureMax=numeric(),
  temperatureMaxTime=as.POSIXct(integer(), origin="1970-01-01"),
  apparentTemperature=numeric(),
  apprarentTemperatureMin=numeric(),
  apparentTemperatureMinTime=as.POSIXct(integer(), origin="1970-01-01"),
  apparentTemperatureMax=numeric(),
  apparentTemperatureMaxTime=as.POSIXct(integer(), origin="1970-01-01"),
  dewPoint=numeric(),
  windSpeed=numeric(),
  windBearing=numeric(),
  cloudCover=numeric(),
  humidity=numeric(),
  pressure=numeric(),
  visibility=numeric(),
  ozone=numeric()
)

out<-weatherMasterTemplate
#Loop to get weather parameters for each loc
for(i in 1:nrow(locTim)){
  #API call, get only daily data (Exclude currently, hourly and flags)
  rec <- get_forecast_for(locTim[i,2], 
                          locTim[i,3], 
                          locTim[i,4],
                          units = "si", exclude = "currently,hourly,flags",
                          config=list(ssl.verifypeer=F))
  #Sys.sleep(2)
  print(sprintf("You have used %s API calls.", rec$`x-forecast-api-calls`))
  out<-merge(out,rec$daily,all=T)
}

out <- cbind(locTim, out)
write.csv(out, file="out.csv", append=TRUE)


