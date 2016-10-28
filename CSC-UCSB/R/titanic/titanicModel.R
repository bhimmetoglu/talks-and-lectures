# Burak Himmetoglu
# 10-25-2016
# bhimmetoglu@ucsb.edu
#
#
# Titanic survival prediction
# Data available from: https://www.kaggle.com/c/titanic
#
# Libraries
library(readr)
library(dplyr)
library(Matrix)
library(glmnet)
library(foreach)
library(doMC)
## Parallel
registerDoMC()

##### Part 1: Read and clean the data #####

# Read data
train <- read_csv("./data/train.csv", col_types = 'iiiccdiicdcc')
test <- read_csv("./data/test.csv", col_types = 'iiccdiicdcc')

# dplyr in action: Probability of Survival by Gender
train %>% group_by(Sex) %>% summarize(survivalRate = sum(Survived == TRUE)/n() )

## Let's merge train and test
# First remove Survied column and keep it in a vector
survival <- select(train, c(Survived,PassengerId))
train <- mutate(train, Survived = NULL) %>% mutate(is.train = 1) # Flag training data with is.train = 1
test <- mutate(test, is.train = 0) # Flag test data with is.train = 0
allData <- rbind(train,test)

# Find NA's
totNA <- function(x) { sum(is.na(x)) } # Finds total number of NA's in a given vector x
naCols <- allData %>% summarize_all(funs(totNA)) # For all the columns, finds how many NAs there are
cat("Number of NA's I have found: \n")
naCols

## Fill the NA's
# Function for filling the NAs with medians
fillMedian <- function(x){ 
  m <- median(x, na.rm = TRUE)
  x[is.na(x)] <- m
  x
}
# Fill NAs in Age and Fare with their median values
allData <- allData %>% mutate(Age = fillMedian(Age)) %>% mutate(Fare = fillMedian(Fare))

# Find the most common embarked value
mostCommonEmbarked <- allData %>% group_by(Embarked) %>% summarize(nEmb = n()) %>% 
  arrange(desc(nEmb)) %>% slice(1)
mostCommonEmbarked <- mostCommonEmbarked$Embarked # Pick the name

# Fill the NAs in Embarked with mostCommonEmbarked
fillEmbarked <- function(x){ x[is.na(x)] <- mostCommonEmbarked; x }
allData <- allData %>% mutate(Embarked = fillEmbarked(Embarked))

# There are so many NAs in Cabin 1024 out of 1309 observations. So, let's create a binary 
# predictor: has.cabin. Then remove the Cabin column from predictors
allData <- allData %>% mutate(has.cabin = ifelse(is.na(Cabin), 0, 1)) %>% mutate(Cabin = NULL)

# Check that all NAs are dealt with
naCols <- allData %>% summarize_all(funs(totNA)) 
if (any(naCols > 0)) cat("There are still NA's to fix!")

# Now, split back into train and test
train <- allData %>% filter(is.train == 1) %>% mutate(is.train = NULL) %>%
  left_join(survival, by = "PassengerId")
test <- allData %>% filter(is.train == 0) %>% mutate(is.train = NULL)

# Clean: Remove unnecessary variables. Then collect garbage
rm(allData,naCols,survival,fillEmbarked,fillMedian,totNA); gc()

##### Part 2: Model training #####

# Let us remove Name, Ticket and PassangerId as predictors and assign factor variables
train <- train %>% select(-c(Name, Ticket, PassengerId)) %>% 
  mutate_at(vars(Pclass,Sex,Embarked), funs(as.factor))

testId <- test %>% select(PassengerId) # Save PassengerId for later
test <- test %>% select(-c(Name, Ticket, PassengerId)) %>%
  mutate_at(vars(Pclass,Sex,Embarked), funs(as.factor))

# Let us contruct model matrices from train and test
trainMatrix <- model.matrix(Survived ~., data = train)[,-1]
testMatrix <- model.matrix(~., data = test)[,-1]

# Take a peek at what they look like
cat("The model Matrix turns factors into binary values:\n")
head(trainMatrix)

# Notice that Pclass=1 and Embarked=C is chosen as reference levels by model.matrix
# e.g. Pclass2 = Pclass = 0 means the observarion has Pclass 1 (same for Embarked)

# Let us train a Regularized Logistic Regression Model by 10-fold cross-validation
ytrain <- as.factor(train$Survived)
cv.logreg <- cv.glmnet(x = trainMatrix, y = ytrain, nfolds = 10, family = "binomial", parallel = TRUE)

# Choose the best lambda (alpha = 1 is set by default)
bestLambda <- cv.logreg$lambda.min

# Now fit with the bestLambda
mod.logreg <- glmnet(x = trainMatrix, y = ytrain, family = "binomial", lambda = bestLambda)
ypred <- predict(mod.logreg, newx = trainMatrix, type = "response") # Probability of survival is predicted
# If you choose type = "class" 0's and 1's will be predicted:
# Prob >= 0.5 --> Survived = 1, Prob < 0.5 --> Survived = 0

# What is the area under the ROC curve? 
library(pROC)
auc <- roc(ytrain, ypred) 
auc # ~ 0.86, not too bad for a simple model!
#plot(auc)

# Finally predict on test set on test set
testSurvived <- predict(mod.logreg, newx = testMatrix, type = "class") 

# Bind with passangerId's
submit <- cbind(testId, testSurvived); 
colnames(submit) <- c("PassengerId", "Survived")

# Finally, write on file. You can submit to Kaggle if you wish!
write_csv(submit, path = "submission.csv")
