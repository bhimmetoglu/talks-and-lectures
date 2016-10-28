# Burak Himmetoglu
# 10-25-2016
# bhimmetoglu@ucsb.edu
#
#
# Example: Random coin flips
#
library(foreach)
library(doMC)
## Parallel
registerDoMC()

# Number of simulations
nSim = 1e+5

# Number of spins for each simulation
nSpin = 100

# Parallel
coinFlips <- matrix(0, nrow = nSim, ncol = nSpin)
t0 <- proc.time() # Start clock
coinFlips <- foreach(i=1:nSim, .combine = rbind) %dopar%
  (rbinom(n = nSpin, size = 1, prob = 0.5))
tf <- proc.time() - t0
cat("---- Parallel coin flips ----\n")
cat("nSim, nSpin: ", nSim, nSpin, "\n")
cat("Timing:", tf[1], "\n")
cat("\n")

# Serial
coinFlips <- matrix(0, nrow = nSim, ncol = nSpin)
t0 <- proc.time() # Start clock
coinFlips <- foreach(i=1:nSim, .combine = rbind) %do%
  (rbinom(n = nSpin, size = 1, prob = 0.5))
tf <- proc.time() - t0
cat("---- Serial coin flips ----\n")
cat("nSim, nSpin: ", nSim, nSpin, "\n")
cat("Timing:", tf[1])
