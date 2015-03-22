# Create one R script called run_analysis.R that does the following:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each
# measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive activity names.
# 5. Creates a second, independent tidy data set with the average of each 
# variable for each activity and each subject.

# 1.Download the data.set zip file and unzip to the work directory in the folder 
#   of "UCI HAR Dataset"

library("data.table")
library("reshape2")

if(!file.exists("./project")){dir.create("./project")}
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./project/Dataset.zip",method="curl")

# 2.Unzip the file
unzip(zipfile="./project/Dataset.zip",exdir="./project")

# 3.Get the list of the files in unzipped folder of "UCI HAR Dataset"

path_rf <- file.path("./project" , "UCI HAR Dataset")
files <- list.files(path_rf, recursive=TRUE)
files

# 4.Read data from the files into the variables
# Read the Activity/Subject/Features files

dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ), header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"), header = FALSE)

dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"), header = FALSE)
dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"), header = FALSE)

dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ), header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"), header = FALSE)

# 5.Concatenate the two set of data tables by rows

dataActivity <- rbind(dataActivityTrain, dataActivityTest)
dataSubject  <- rbind(dataSubjectTrain, dataSubjectTest)
dataFeatures <- rbind(dataFeaturesTrain, dataFeaturesTest)

# 6.Set names to all variables

names(dataActivity) <- c("activity")
names(dataSubject)  <- c("subject")
dataFeaturesNames   <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
names(dataFeatures) <- dataFeaturesNames$V2

# 7.Merge Subject/Activity/Features to get the final complete Data

dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)

# 8.Extract only the measurements on the mean and standard deviation for each
# measurement.

subdataFeaturesNames <- dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]
selectedNames <- c(as.character(subdataFeaturesNames), "subject", "activity" )
Data <- subset(Data, select = selectedNames)

# 9.Uses descriptive activity names to name the activities in the data set

activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"), header = FALSE)
names(Data) <- gsub("^t", "time", names(Data))
names(Data) <- gsub("^f", "frequency", names(Data))
names(Data) <- gsub("Acc", "Accelerometer", names(Data))
names(Data) <- gsub("Gyro", "Gyroscope", names(Data))
names(Data) <- gsub("Mag", "Magnitude", names(Data))
names(Data) <- gsub("BodyBody", "Body", names(Data))

# 10.Creates a second,independent tidy data set with the average of each
# variable for each activity and each subject 

library(plyr)
Data2 <- aggregate(. ~subject + activity, Data, mean)
Data2 <- Data2[order(Data2$subject,Data2$activity),]

# check Data2
dim(Data2)
names(Data2)
Data2$activity

Data2$activity <- replace(Data2$activity, 1:180, as.character(activityLabels))
write.table(Data2, file = "tidydata.txt", row.name=FALSE)