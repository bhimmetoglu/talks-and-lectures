# Burak Himmetoglu (burakhmmtgl@gmail.com)
# 03-05-2017
# Human Activity Recognition dataset from UCI

## K Nearest Neighbors ##

# Librarires
library(dplyr)
library(caret)
library(MLmetrics)

# Prepare and clean data
source("prepare_data.R")

# Split back into train/test
X_tr <- X_full %>% filter(is.train == 1) %>% dplyr::select(-is.train)
X_ts <- X_full %>% filter(is.train == 0) %>% dplyr::select(-is.train)
y_tr <- as.factor(y_train$label)
y_tst <- as.factor(y_test$label)

## Train with Caret
# Grid search for hyperparameters
grid <- expand.grid(k = c(1, 2, 4, 8, 16, 32))
ctrl <- trainControl(method = "cv", 
                     number = 5, 
                     verboseIter = TRUE, 
                     classProbs = TRUE,
                     summaryFunction = mnLogLoss)

# Caret wants names for targets (labels)
levels(y_tr) <- c("WALKING", "WALKING.UP", "WALKING.DOWN", "SITTING", "STANDING", "LAYING")
levels(y_tst) <- c("WALKING", "WALKING.UP", "WALKING.DOWN", "SITTING", "STANDING", "LAYING")

# Run the CV 
fit.caret <- train(x = X_tr,
                   y = y_tr,
                   method = "knn", 
                   metric = "logLoss",
                   trControl = ctrl,
                   tuneGrid = grid)

# Reference: Fitting k = 8 on full training set: mlogloss = 0.1669965

# Predict on the test set
pred_tst <- predict(fit.caret$finalModel, 
                    newdata = X_ts,
                    type = "prob")
# Accuracy
pred_labels <- apply(pred_tst, 1, which.max)
sum(pred_labels == y_test$label) / length(y_test$label) # Reference: 0.88

# Confusion matrix
confusionMatrix(pred_labels, y_test$label)
