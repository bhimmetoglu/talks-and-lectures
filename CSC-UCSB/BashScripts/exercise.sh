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
echo "Number of Jobs:"
wc -l < qstat.log # Check man page for wc and option l

# Interrupt, wait for user 
read -p "Press any key to continue... "


# Get the lines that match to batch", i.e. how many jobs are running on the batch queue?
grep 'batch' qstat.log | head -10  # Show only first 10 lines

# Interrupt, wait for user 
read -p "Press any key to continue... "

# Now create output from showq
showq > showq.log

# Show 10 lines after the matching string 'IDLE JOBS'
grep -A 10 'IDLE JOBS' showq.log

# Interrupt, wait for user
read -p "Press any key to continue... "

# For all jobs in the batch queue, write their JobId's
nbatch=`grep 'batch' qstat.log | wc -l` # Pipe the output of grep to wc -l. Notice the ` ` that wraps the commands 

echo  "  Time Use   jobID" > batchJobs.log
for index in `seq 1 $nbatch` # Check the man page for seq. Notice the use of $ sign to point to nbatch declared above 
do

jobID=`grep 'batch' qstat.log | head -$index | tail -1 | cut -c '1-20'` # Check the man page for cut
timeUse=`grep 'batch' qstat.log | head -$index | tail -1 | cut -c '60-68'`
cat >> batchJobs.log << EOF # Append to batchJobs.log. Perform the options below until EOF
 $timeUse   $jobID
EOF

done
