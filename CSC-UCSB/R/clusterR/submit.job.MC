#!/bin/bash
#PBS -l nodes=1:ppn=12
#PBS -l walltime=01:00:00
#PBS -N MonteCarlo
#PBS -V

cd $PBS_O_WORKDIR

# Run the serial and parallel version of Monte Carlo integration
Rscript --vanilla montecarloSer.R > serOut.dat
Rscript --vanilla montecarloPar.R > parOut.dat
