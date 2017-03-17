# Burak Himmetoglu (burakhmmtgl@gmail.com)
# 03-05-2017
# Human Activity Recognition dataset from UCI

## Prepare data for analysis ##
# Make sure that to downlad the data from 
# https://archive.ics.uci.edu/ml/machine-learning-databases/00240/

# Function for calculating multi-class logloss. 
mlogloss <- function(preds, actual){
  #
  # preds is a matrix of N x n_class
  # actual is a matrix of N x n_class (one-hot encoded)
  preds <- apply(preds, c(1,2), function(x) max(min(x, 1-10^(-15)), 10^(-15)))
  score <- -sum(actual*log(preds))/nrow(preds)
  
  # Return
  score
}

# Librarires
library(dplyr)
library(readr)
library(caret)

# Feature names
feat_names <- read_delim("./data/HARdata/features.txt", delim = " ", col_names = c("code", "feature"), col_types = "cc")
feat_names <- mutate(feat_names, code=paste0("f",code))

# Number of features
n_feats = dim(feat_names)[1]

# Load training data
X_train <- read_table("./data/HARdata/train/X_train.txt", col_names = paste0("f",1:n_feats))
y_train <- read_table("./data/HARdata/train/y_train.txt", col_names = c("label"))

# Load testing data
X_test <- read_table("./data/HARdata/test/X_test.txt", col_names = paste0("f",1:n_feats))
y_test <- read_table("./data/HARdata/test/y_test.txt", col_names = c("label"))

# Function for rescaling and centering features
standardize <- function(x){
  (x - mean(x))/sd(x)
}

# Combine train and test (flag by is.train to split back later)
X_train <- mutate(X_train, is.train = 1)
X_test <- mutate(X_test, is.train = 0)
X_full <- rbind(X_train, X_test)

# Standardize (column (n_feats+1) = 652 is `is.train`, which is just a flag)
X_full[,-(n_feats+1)] <- X_full[,-(n_feats+1)] %>% mutate_all(funs(standardize))

# From the exploratory analysis, we know that there are duplicate columns. Remove them below
X_full <- as.data.frame(unique(as.matrix(X_full), MARGIN=2))
n_feats <- dim(X_full)[2] # New number of features +1 (from is.train)

# New feature names
rm.cols <- setdiff(colnames(X_train), colnames(X_full))
feat_names <- feat_names %>% filter(!(code %in% rm.cols))

# In certain cases, we will also need the principal compoenents.
# Keep principal components that explain 99% of the variance
obj.pca <- preProcess(X_full[,-(n_feats)], method = "pca", thresh = 0.99) 
X_pca <- predict(obj.pca, X_full[, -(n_feats)]) # 185 columns left
X_pca <- mutate(X_pca, is.train = X_full$is.train)

# Remove unnecessary variables
rm(X_train, X_test); gc()
