/*
  -- Burak Himmetoglu --
  -- bhimmetoglu@ucsb.edu --
*/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "mpi.h"

#define PI25DT 3.141592653589793238462643

// Function prototypes
double f( double x);

// Main
void main (int argc, char *argv[]){
  int i;
  int nDivisions, // Number of divisions
      nProcs,     // Number of processes
      iProc,      // Index of process
      tag = 0;    // Message tag



  double x,         // x-variable
         mypi,      // Local value of pi
         h,         // Division size
         pi,        // Final value of pi
         sum = 0.0; // Sum under the curve

  double tStart,  // Start time
         tEnd;    // End time

  // Initialize MPI
  MPI_Init(&argc,&argv); // Can pass NULL here
  MPI_Comm_size(MPI_COMM_WORLD,&nProcs);
  MPI_Comm_rank(MPI_COMM_WORLD, &iProc);

  // Record start time
  tStart = MPI_Wtime();

  // Master process is iProc = 0. This process reads input from stdin
  if (iProc == 0)
  {
    nDivisions = strtol(argv[1],NULL,10);
  }

  // Broadcast nDivisions 
  MPI_Bcast(&nDivisions, 1, MPI_INT, 0, MPI_COMM_WORLD);

  // Compute integral across all processes
  h = 1.0 / (double)(nDivisions);
  for (i = iProc + 1; i <= nDivisions; i += nProcs)
  {
    x = h * ( (double)i - 0.5);
    sum += f(x);
  } 

  // Multiply with step size
  mypi = h * sum;

  // Each process prints its contribution
  printf("My contribution to pi: %.16f from process: %d of %d \n", mypi, iProc, nProcs);

  // Reduce via summation each contribution (mypi) from all the processes 
  MPI_Reduce(&mypi, &pi, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

  // Record end time
  tEnd = MPI_Wtime();

  // Master process prints output
  if (iProc == 0)
  {
    printf("----- END OF CALCULATION -----\n");
    printf("Calculated valuf of pi with %d divisions: %.16f \n", nDivisions, pi);
    printf("Error in pi= %.16f\n", fabs(pi-PI25DT));
    printf("Time to calculate pi is: %f s\n", tEnd - tStart);
  }

  // End MPI
  MPI_Finalize();

}

double f( double x){
  return 4.0 / (1.0+x*x);
}
