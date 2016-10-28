# Burak Himmetoglu
# 10-25-2016
# bhimmetoglu@ucsb.edu
#
#
# Example: Serial Monte Carlo with for loop
#

# Number of simulations
nSim = 1e+5

# Exact result
exact <- function(x = 1, nDim){ ((pnorm(x*sqrt(2)) - 0.5)*sqrt(pi))^nDim }

# Function for Monte Carlo calculation
funMC <- function(nDim){
  vec = runif(nDim, min = 0, max = 1) # Draw a random vector from uniform distribution
  vec_exp = exp(-sum(vec^2))          # The integrand
  z = vec_exp                         # Add contribution
  s2 = vec_exp^2                      # Variance contribution 
  # Return results
  list(z, s2)
}

# Set seed 
set.seed(123)

# Start the clock
t0 <- proc.time()

# Compute serial
z = 0; s2 =0
for (i in 1:nSim){
  temp <- funMC(nDim=10)
  z <- z + temp[[1]]
  s2 <- s2 + temp[[2]]
}
Int = z/nSim; Err = sqrt(s2/nSim - Int^2) / sqrt(nSim)

# End the clock
t1 <- proc.time(); t_elapsed <- t1-t0

# Print
cat("---- Monte Carlo integration ----\n")
cat("Calculated Value, Error: ", Int, Err, "\n")
cat("Timing:", t_elapsed[1], "seconds\n")
cat("Exact results: ", exact(nDim=10))


  
