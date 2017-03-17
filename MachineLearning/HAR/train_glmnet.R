# Burak Himmetoglu (burakhmmtgl@gmail.com)
# 03-05-2017
# Human Activity Recognition dataset from UCI

## Training by Elastic NET (LASSO + Ridge Regression) ##

# Librarires
library(dplyr)
library(caret)
library(glmnet)
library(MLmetrics)

# Prepare and clean data
source("prepare_data.R")

### Train with Caret 

# Split back into train/test
X_tr <- X_full %>% filter(is.train == 1) %>% dplyr::select(-is.train) # Training 
X_tst <- X_full %>% filter(is.train == 0) %>% dplyr::select(-is.train) # Test
y_tr <- as.factor(y_train$label) # labels
y_tst <- as.factor(y_test$label) # labels

# Grid search for hyperparameters
grid <- expand.grid(alpha = 2^seq(-6,0), lambda = c(0,2^seq(-6,2)))
ctrl <- trainControl(method = "cv", 
                     number = 5, 
                     verboseIter = TRUE, 
                     classProbs = TRUE,
                     summaryFunction = mnLogLoss)

# Caret wants names for targets (labels)
levels(y_tr) <- c("WALKING", "WALKING.UP", "WALKING.DOWN", "SITTING", "STANDING", "LAYING")

# Run the CV 
fit.caret <- train(x = X_tr,
                   y = y_tr,
                   method = "glmnet", 
                   family = "multinomial",
                   metric = "logLoss",
                   trControl = ctrl,
                   tuneGrid = grid)
# Reference: Fitting alpha = 0.25, lambda = 0 on full training set

# Degrees of freedom:
df.final <- length(unique(fit.caret$finalModel$df)) # 88

# Best tune: result
best <- fit.caret$bestTune
fit.caret$results[41,]     # Reference: logloss ~ 0.04934768

## Predict on test data
pred_tst <- predict(fit.caret, 
                    newdata = X_tst,
                    type = "prob")

# Accuracy
pred_labels <- apply(pred_tst, 1, which.max)
sum(pred_labels == y_test$label) / length(y_test$label) # Reference: 0.96

# Confusion matrix
confusionMatrix(pred_labels, y_test$label)

# Logloss of the test set
expanded_tst <- diag(6) 
expanded_tst <- t(expanded_tst[, y_test$label]) # One-hot encoding for test labels
mlogloss(pred_tst, expanded_tst)    # Reference: 0.1337042

