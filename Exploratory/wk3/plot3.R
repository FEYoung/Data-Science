#R Script to create the third plot

#check if data sources are present
if (!file.exists("summarySCC_PM25.rds") | !file.exists("Source_Classification_Code.rds")) {
  url  = "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  dest = "NEIdata.zip"
  meth = "internal"
  quit = TRUE
  mode = "wb"
  download.file(url, dest, meth, quit, mode)
  #Works on tested operating system (Windows 7). Please change values if needed.
  unzip("NEIdata.zip")
  file.remove("NEIdata.zip")
}

#loads libraries
library(dplyr)
library(ggplot2)

#loads the data files and converts them into the tbl_df class
NEI <- readRDS("summarySCC_PM25.rds")
SCC <- readRDS("Source_Classification_Code.rds")

#Initializes the SCCtypes to be used for the selection
SCCtype <- c("Point", "Nonpoint", "Onroad", "Nonroad")

#filters the rows to be used and merges the NEI and SCC variables by SCCtype
NEI <- filter(NEI, fips==24510) %>%
  select(SCC, Emissions, year)
SCC <- select(SCC, SCC, Data.Category)  

NEI <- merge(NEI, SCC, by="SCC")%>%
  filter(Data.Category == SCCtype)%>%
  select(Emissions, year, Data.Category)

#aggregate the total PM2.5 values for each year
Emissionsum <- aggregate(Emissions ~ Data.Category + year, data=NEI, sum, rm.na=TRUE)

#some renaming and reshufling
colnames(Emissionsum) <- c("Type", "Year", "Emission")
Emissionsum <- select(Emissionsum, Year, Emission, Type)

#plot the graphic
qplot(Year, Emission, data=Emissionsum, color=Type,
      main="Total PM2.5 emissions by year in Baltimore (1999-2008)",
      xlab= "Years",
      ylab= "Total PM2.5 emissions (ton)", geom=c("point",  "smooth"))
#this trows a couple of Warnings as a result of the added geom. This however, does not
#influence the plot.

#Writes the plot as a png file
dev.print(png, file = "plot3.png", width = 480, height = 480)
dev.off