# Burak Himmetoglu
# 10-25-2016
# bhimmetoglu@ucsb.edu
#
# Example: Serial Monte Carlo with foreach
#
library(foreach)

# Number of simulations
nSim = 1e+5

# Exact result
exact <- function(x = 1, nDim){ ((pnorm(x*sqrt(2)) - 0.5)*sqrt(pi))^nDim }

# Function for Monte Carlo calculation
funMC <- function(nDim){
  # Draw a random vector from uniform distribution
  vec = runif(nDim, min = 0, max = 1) 
  # Return the integrand
  exp(-sum(vec^2))
}

# Set seed 
set.seed(123)

# Start the clock
t0 <- proc.time()

# Do the integral
Int <- foreach(i=1:nSim, .combine = "+") %do%{
  funMC(nDim=10)/nSim
}

# End the clock
t1 <- proc.time(); t_elapsed <- t1-t0

# Print
cat("---- Monte Carlo integration (serial) ----\n")
cat("Computed, Exact: ", Int, exact(nDim = 10), "\n")
cat("Timing:", t_elapsed[1], "seconds\n")

