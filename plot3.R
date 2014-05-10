# ---------------------------------------------------------------------
# Reading household data only from dates 2007-02-01 and 2007-02-02.
# ---------------------------------------------------------------------
cat("Reading household data...\n")

# check if file exists
filename <- "household_power_consumption.txt"
stopifnot(file.exists(filename))

# I have decided to use fread {package data.table} because is fast.
# It returns a data.table object though, so I convert it to data.frame,
# which I'm more familiar with.
library(data.table)

# read only the Date column
hh.dates <- fread(filename, sep=";", select="Date")

# get the range of lines to read
lines.to.read <- with(hh.dates, range(which(Date == "1/2/2007" | Date == "2/2/2007")))
household <- fread(filename, sep=";", na.strings="?",
                   skip=lines.to.read[1], 
                   nrow=lines.to.read[2] - lines.to.read[1] + 1)

# get column names (skipping lines skips the header altogether)
hh.colnames <- colnames(fread(filename, sep=";", nrow=1))
setnames(household, hh.colnames)

# just to make sure
if (!all(household$Date == "1/2/2007" | household$Date == "2/2/2007"))
  household <- household[household$Date == "1/2/2007" | household$Date == "2/2/2007", ]

# convert household data.table to data.frame
# there are more efficient ways to do that, but the filtered
# dataset is not that big (only 2880 observations)
household <- as.data.frame(household)

# convert date and time columns
household$Time <- strptime(paste(household$Date, household$Time), "%d/%m/%Y %H:%M:%S")
household$Date <- as.Date(household$Date, "%d/%m/%Y")

# remove some temporary variables
rm(hh.dates)
rm(hh.colnames)

# Plot 3
cat("Creating plot 3...\n")

# set locale to get weekdays in English
oldLC_TIME <- Sys.getlocale("LC_TIME")
Sys.setlocale("LC_TIME","C")

png("plot3.png", width=480, height=480)
plot(x=household$Time,
     y=household$Sub_metering_1,
     type="l",
     xlab="",
     ylab="Energy sub metering")

lines(x=household$Time,
      y=household$Sub_metering_2, 
      col="red")

lines(x=household$Time,
      y=household$Sub_metering_3, 
      col="blue")

legend("topright", 
       lty=1,
       col = c("black", "red", "blue"), 
       legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))

dev.off()

# restore original locale settings
Sys.setlocale("LC_TIME",oldLC_TIME)

cat("Done!\n")