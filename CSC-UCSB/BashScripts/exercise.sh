#!/bin/bash 
#
# Burak Himmetoglu
# 10-11-2016
# bhimmetoglu@ucsb.edu

### Exercises with shell scripts ###

# If there is no folder named CSCexercises create it in the home folder
cd $HOME 
mkdir -p CSCexercises # Check man page for mkdir: If folder CSCExercises do not exists, create it
cd CSCexercises

# Create a test data from qstat
qstat > qstat.log # Redirect the output of qstat to qstat.log 

# How many entries are there ?
wc -l < qstat.log # Check man page for wc and option l

# Get the lines that match to "gpuq", i.e. how many jobs are running on the GPU queue?
grep 'gpuq' qstat.log 

# Now create output from showq
showq > showq.log

# Show 10 lines after the matching string 'IDLE JOBS'
grep -A 10 'IDLE JOBS' showq.log

# For all jobs in the qpuq, write their JobId's
nGPU=`grep 'gpuq' qstat.log | wc -l` # Pipe the output of grep to wc -l. Notice the ` ` that wraps the commands 

echo  "  Time Use   jobID" > gpuJobs.log
for index in `seq 1 $nGPU` # Check the man page for seq. Notice the use of $ sign to point to nGPU declared above 
do

jobID=`grep 'gpuq' qstat.log | head -$index | tail -1 | cut -c '1-20'` # Check the man page for cut
timeUse=`grep 'gpuq' qstat.log | head -$index | tail -1 | cut -c '60-68'`
cat >> gpuJobs.log << EOF # Append to gpuJobs.log. Perform the options below until EOF
 $timeUse $jobID
EOF

done
