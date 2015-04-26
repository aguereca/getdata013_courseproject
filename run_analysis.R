# Objectives of this script: (From project assignment)
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

#
# Dependencies
if (!require("data.table")) {
  install.packages("data.table")
}
if (!require("reshape2")) {
  install.packages("reshape2")
}
require("data.table")
require("reshape2")
#
#

#
# Loading individual raw files, data is expected to exist on a file folder named uci-har
activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt")[,2]
features <- read.table("./UCI HAR Dataset/features.txt")[,2]

x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/y_test.txt")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/y_train.txt")

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
#
#

#
# Process test data...
# Objective 3: Uses descriptive activity names to name the activities in the data set
names(x_test) <- features

# Objective 2: Extract only the measurements on the mean and standard deviation for each measurement.
x_test <- x_test[,grepl("mean|std", features)]

# Objective 4: Appropriately labels the data set with descriptive variable names.
y_test[,2] <- activity_labels[y_test[,1]]
names(y_test) <- c("Activity_ID", "Activity_Label")
names(subject_test) <- "subject"

# Create Test dataset
test_dataset <- cbind(as.data.table(subject_test), y_test, x_test)

#
# Process train data...
# Objective 3: Uses descriptive activity names to name the activities in the data set
names(x_train) <- features

# Objective 2: Extract only the measurements on the mean and standard deviation for each measurement.
x_train <- x_train[,grepl("mean|std", features)]

# Objective 4: Appropriately labels the data set with descriptive variable names.
y_train[,2] <- activity_labels[y_train[,1]]
names(y_train) <- c("Activity_ID", "Activity_Label")
names(subject_train) <- "subject"

# Create Train dataset
train_dataset <- cbind(as.data.table(subject_train), y_train, x_train)


#
# Objective 1: Merges the training and the test sets to create one data set.
merged_dataset <- rbind(test_dataset, train_dataset, fill=TRUE)
# Objective 4: Appropriately labels the data set with descriptive variable names.
id_labels <- c("subject", "Activity_ID", "Activity_Label")
var_labels <- setdiff(colnames(merged_dataset), id_labels)
melted_dataset <- melt(data, id=id_labels, measure.vars=var_labels)

#
# Objective 5: From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
tidy_dataset <- dcast(melted_dataset, subject + Activity_Label ~ variable, mean)

# Writes expected file on disk
write.table(tidy_dataset, file = "./uci_har_tidy.txt")
