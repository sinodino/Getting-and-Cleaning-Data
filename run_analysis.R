## Load libraries

library(plyr)
library(knitr)

## Get data

if(!file.exists("./data")){dir.create("./data")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile="./data/Dataset.zip",method="curl")

## Unzip the .zip

unzip(zipfile="./data/Dataset.zip",exdir="./data")
path <- file.path("./data" , "UCI HAR Dataset")
files<-list.files(path, recursive=TRUE)

## Get the labels and features

labels<-read.table(file.path(path,"activity_labels.txt"),col.names = c("labelnum","label"))
features<-read.table(file.path(path,"features.txt"),col.names = c("featurenum","feature"))
features$feature<-gsub("^t","time",features$feature)
features$feature<-gsub("^f","frequency",features$feature)
features$feature<-gsub("Acc","Accelerometer",features$feature)
features$feature<-gsub("Gyro","Gyroscope",features$feature)
features$feature<-gsub("Mag","Magnitude",features$feature)
features$feature<-gsub("BodyBody","Body",features$feature)

## Merge the training data into a training data set

training_subject<-read.table(file.path(path,"train","subject_train.txt"),col.names = "subject")
training_data<-read.table(file.path(path,"train","X_train.txt"),col.names=features$feature,check.names = FALSE)
training_labels<-read.table(file.path(path,"train","y_train.txt"),col.names="labelnum")
dftraining=cbind(training_labels,training_subject,training_data)

## Merge the test data into a test data test

test_subject<-read.table(file.path(path,"test","subject_test.txt"),col.names="subject")
test_data<-read.table(file.path(path,"test","X_test.txt"),col.names = features$feature,check.names = FALSE)
test_labels<-read.table(file.path(path,"test","y_test.txt"),col.names = "labelnum")
dftest=cbind(test_labels,test_subject,test_data)

## Merges the training and the test sets to create one data set.

df<-rbind(dftraining,dftest)

## Extracts only the measurements on the mean and standard deviation for each measurement. 

indices <- grep("mean\\(|std\\(", features$feature)
df<-df[,indices]

## Uses descriptive activity names to name the activities in the data set
## Appropriately labels the data set with descriptive variable names.

df<-merge(labels,df,by.x="labelnum",by.y="labelnum")
df<-df[,-1]

## Creates a second, independent tidy data set with the average of 
## each variable for each activity and each subject

df2<-aggregate(. ~label+subject,df,mean)
df2<-df2[order(df2$label,df2$subject),]
write.table(df2,file="tidy.txt",row.names = FALSE)
write.table(names(df2), file="codebook.md", quote=FALSE, row.names=FALSE, col.names=FALSE, sep="\t")
