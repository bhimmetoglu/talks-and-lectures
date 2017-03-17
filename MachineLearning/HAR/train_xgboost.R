# Burak Himmetoglu (burakhmmtgl@gmail.com)
# 03-05-2017
# Human Activity Recognition dataset from UCI

## XGBoost Tree Booster ##

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

# XGB style matrices
dtrain <- xgb.DMatrix(as.matrix(X_tr), label = y_tr)
watchlist <- list(train=dtrain)

### Grid search for hyperparameters
# First, train (eta, max_depth) keeping everything else at default value
grid_1 <- expand.grid(eta = c(0.3,0.5,0.7),
                      max_depth = c(1,2,6,8))
cv.results <- data.frame(grid_1) %>% mutate(nrounds = 0) %>% mutate(mll_train = 0) %>% mutate(mll_test = 0)

# Loop over hyperparameters
for (ind in 1:nrow(cv.results)){
  # Parameters
  params <- list(booster = "gbtree",
                 eval_metric = "mlogloss",
                 objective = "multi:softprob",
                 eta = cv.results[ind, 1],
                 max_depth = cv.results[ind, 2])
  
  # Train 
  set.seed(111)
  fit_cv <- xgb.cv(params = params,
                   data = dtrain,
                   num_class = 6,
                   nrounds = 500,
                   watchlist = watchlist,
                   nfold = 5,
                   early_stopping_rounds = 50)
  
  cv.results[ind,3] <- fit_cv$best_iteration
  cv.results[ind,4] <- fit_cv$evaluation_log[fit_cv$best_iteration][[2]] # Train mll
  cv.results[ind,5] <- fit_cv$evaluation_log[fit_cv$best_iteration][[4]] # Test mll
  cat("Trained ", ind, " of ", dim(cv.results)[1], "\n")
}

# Save for later
save(cv.results, file="xgb-grid_1.RData")

# Best iteration
best <-  which.min(cv.results$mll_test) # 5
cv.results[best,]
# Reference:
# eta  max_depth  nrounds mll_train  mll_test
# 0.5         2     216   0.0005468 0.0202194

### Now train with (gamma, min_child_weight). There are signs of high variance (overfitting): large difference btw train/test mll. 
# These hyperparameters can help reduce variance
grid_2 <- expand.grid(gamma = c(0,2^seq(-6,-2)),
                      min_child_weight = c(0,1,2,4))
cv.results <- data.frame(grid_2) %>% mutate(nrounds = 0) %>% mutate(mll_train = 0) %>% mutate(mll_test = 0)

# Loop over hyperparameters
for (ind in 1:nrow(cv.results)){
  # Parameters
  params <- list(booster = "gbtree",
                 eval_metric = "mlogloss",
                 objective = "multi:softprob",
                 eta = 0.50,     # From 1st round
                 max_depth = 2,  # From 1st round
                 gamma = cv.results[ind, 1],
                 min_child_weight = cv.results[ind, 2])
  
  # Train 
  set.seed(111)
  fit_cv <- xgb.cv(params = params,
                   data = dtrain,
                   num_class = 6,
                   nrounds = 500,
                   watchlist = watchlist,
                   nfold = 5,
                   early_stopping_rounds = 50)
  
  cv.results[ind,3] <- fit_cv$best_iteration
  cv.results[ind,4] <- fit_cv$evaluation_log[fit_cv$best_iteration][[2]] # Train mll
  cv.results[ind,5] <- fit_cv$evaluation_log[fit_cv$best_iteration][[4]] # Test mll
  cat("Trained ", ind, " of ", dim(cv.results)[1], "\n")
}

# Save for later
save(cv.results, file="xgb-grid_2.RData")

# Best model
best <- which.min(cv.results$mll_test) # 1
cv.results[best,]

# Reference:
# gamma   min_child_weight nrounds mll_train  mll_test
#   0               0       456     4.98e-05  0.0196988

### Now train with (subsample, colsample_bytree). There are signs of high variance (overfitting): large difference btw train/test mll. 
# These hyperparameters can help reduce variance
grid_3 <- expand.grid(colsample_bytree = c(0.2,0.4,0.7,1.0),
                      subsample = c(0.2,0.4,0.7,1.0))
cv.results <- data.frame(grid_3) %>% mutate(nrounds = 0) %>% mutate(mll_train = 0) %>% mutate(mll_test = 0)

# Loop over hyperparameters
for (ind in 1:nrow(cv.results)){
  # Parameters
  params <- list(booster = "gbtree",
                 eval_metric = "mlogloss",
                 objective = "multi:softprob",
                 eta = 0.50,     # From 1st round
                 max_depth = 2,  # From 1st round
                 gamma = 0.0,    # From 2nd round
                 min_child_weight = 0, # From 2nd round
                 colsample_bytree = cv.results[ind,1],
                 subsample = cv.results[ind, 2])
  
  # Train 
  set.seed(111)
  fit_cv <- xgb.cv(params = params,
                   data = dtrain,
                   num_class = 6,
                   nrounds = 500,
                   watchlist = watchlist,
                   nfold = 5,
                   early_stopping_rounds = 50)
  
  cv.results[ind,3] <- fit_cv$best_iteration
  cv.results[ind,4] <- fit_cv$evaluation_log[fit_cv$best_iteration][[2]] # Train mll
  cv.results[ind,5] <- fit_cv$evaluation_log[fit_cv$best_iteration][[4]] # Test mll
  cat("Trained ", ind, " of ", dim(cv.results)[1], "\n")
}

# Save for later
save(cv.results, file="xgb-grid_3.RData")

# Best model
best <- which.min(cv.results$mll_test) # 13
cv.results[best,]
# Reference:
# colsample_bytree subsample nrounds mll_train  mll_test
#         0.2         1        499   5.08e-05   0.0170752

# Predict on the test set
# XGboost wants levels to start with 0
y_tst <- as.factor(y_test$label)
y_tst <- revalue(y_tst, c('6'='5', '5'='4', '4'='3', '3'='2', '2'='1', '1'='0'))
y_tst <- as.numeric(levels(y_tst))[y_tst]

# XGBoost style matrices
dtest <- xgb.DMatrix(as.matrix(X_tst), label = y_tst)
watchlist <- list(train=dtrain, test=dtest)

# Use best model params
params <- list(booster = "gbtree",
               eval_metric = "mlogloss",
               objective = "multi:softprob",
               eta = 0.50,     
               max_depth = 2, 
               gamma = 0.0,    
               min_child_weight = 0, 
               colsample_bytree = 0.2,
               subsample = 1)

modxgb <- xgb.train(params = params,
                    data = dtrain,
                    num_class = 6,
                    nrounds = 499,
                    watchlist = watchlist) # test-mloglos ~ 0.14. There is an order of magnitude difference with CV score

# Predict
pred_tst <- predict(modxgb, 
                    newdata = dtest)

# Reshape in N x n_class
pred_matrix <- matrix(pred_tst, nrow = nrow(X_tst), byrow = TRUE) # Reshape for class probs

# Accuracy
pred_labels <- apply(pred_matrix, 1, which.max)
sum(pred_labels == y_test$label) / length(y_test$label) # %96
