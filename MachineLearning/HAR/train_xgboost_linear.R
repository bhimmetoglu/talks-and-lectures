# Burak Himmetoglu (burakhmmtgl@gmail.com)
# 03-05-2017
# Human Activity Recognition dataset from UCI

## XGBoost Linear Booster ##

# Librarires
library(plyr)
library(dplyr)
library(caret)
library(xgboost)
library(MLmetrics)

# Prepare and clean data
source("prepare_data.R")

## Train using xgboost's cv function

# Split back into train/test
X_tr <- X_full %>% filter(is.train == 1) %>% dplyr::select(-is.train)
X_tst <- X_full %>% filter(is.train == 0) %>% dplyr::select(-is.train)

# XGboost wants levels to start with 0
y_tr <- as.factor(y_train$label)
y_tr <- revalue(y_tr, c('6'='5', '5'='4', '4'='3', '3'='2', '2'='1', '1'='0'))
y_tr <- as.numeric(levels(y_tr))[y_tr]

# XGBoost style matrices
dtrain <- xgb.DMatrix(as.matrix(X_tr), label = y_tr)
watchlist <- list(train=dtrain)

# Grid search for hyperparameters
grid_linear <- expand.grid(alpha = c(0,0.01,0.1,1), lambda = c(0,0.01,0.1,1),
                           eta = c(0.1, 0.3, 0.5))
cv.results <- data.frame(grid_linear) %>% mutate(nrounds = 0) %>% mutate(mll_train = 0) %>% mutate(mll_test = 0)

# Loop over hyperparameters
for (ind in 1:nrow(cv.results)){
  # Parameters
  params <- list(booster = "gblinear",
                 eval_metric = "mlogloss",
                 objective = "multi:softprob",
                 alpha = cv.results[ind, 1],
                 lambda = cv.results[ind, 2],
                 eta = cv.results[ind,3],
                 seed = 111)
  
  # Train 
  fit_cv <- xgb.cv(params = params,
                   data = dtrain,
                   num_class = 6,
                   nrounds = 500,
                   watchlist = watchlist,
                   nfold = 5,
                   early_stopping_rounds = 50)
  
  cv.results[ind,4] <- fit_cv$best_iteration
  cv.results[ind,5] <- fit_cv$evaluation_log[fit_cv$best_iteration][[2]] # Train mll
  cv.results[ind,6] <- fit_cv$evaluation_log[fit_cv$best_iteration][[4]] # Test mll
  cat("Trained ", ind, " of ", dim(cv.results)[1], "\n")
}

# Save for later
save(cv.results, file="xgb_linear-grid_1.RData")

# Best iteration
best <-  which.min(cv.results$mll_test) # 32
cv.results[best,]
# Reference:
# alpha lambda eta nrounds mll_train  mll_test
#  0.1      1  0.3     497 0.0163204 0.0437572

### Prediction on Test

# Predict on the test set
# XGboost wants levels to start with 0
y_tst <- as.factor(y_test$label)
y_tst <- revalue(y_tst, c('6'='5', '5'='4', '4'='3', '3'='2', '2'='1', '1'='0'))
y_tst <- as.numeric(levels(y_tst))[y_tst]

# XGBoost style matrices
dtest <- xgb.DMatrix(as.matrix(X_tst), label = y_tst)
watchlist <- list(train=dtrain, test=dtest)

# Use best model params
params <- list(booster = "gblinear",
               eval_metric = "mlogloss",
               objective = "multi:softprob",
               alpha = 0.1,
               lambda = 1,
               eta = 0.3,
               seed = 12345)

modxgb <- xgb.train(params = params,
                    data = dtrain,
                    num_class = 6,
                    nrounds = 497,
                    watchlist = watchlist) # test-mloglos ~ 0.13

# Predict
pred_tst <- predict(modxgb, 
                    newdata = dtest)

# Reshape in N x n_class
pred_matrix <- matrix(pred_tst, nrow = nrow(X_tst), byrow = TRUE) # Reshape for class probs

# Accuracy
pred_labels <- apply(pred_matrix, 1, which.max)
sum(pred_labels == y_test$label) / length(y_test$label) # %96
