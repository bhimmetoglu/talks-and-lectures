#!/bin/bash 
#
# Burak Himmetoglu
# 10-11-2016
# bhimmetoglu@ucsb.edu


## Print direct and reciprocal lattice vectors
grep -A 3 "direct lattice vectors" OUTCAR | tail -4 > cell.info 

## Print information about Forces in the unit cell
grep -A 15 "FORCE on cell" OUTCAR > force.info

## Print the calculated energy at each iteration
nIter=`grep TOTEN OUTCAR | wc -l`

for index in `seq 1 $nIter` # Grab value of energy at each iteration
do

  En=`grep TOTEN OUTCAR | head -$index | tail -1 | awk '{print $5}'`  
  echo $index $En >> E_vs_iter.dat # Note the use of >> here instead of >

done
