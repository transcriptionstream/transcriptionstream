#!/bin/bash
#transcription stream process control example
#
## limit the total running transcriptions here

# the process we are looking to limit concurrent runs of
processName=transcribe_example.sh

# run this loop until our script gets kicked off, but limit all running scripts to a total of X
# where X is the number after "-le" in the if statement below.

while true
do
  if [ $(ps -ef |grep -v grep|grep $processName |wc -l) -le 1 ]
	then
	# testing bits ----
	# processCount=`ps -ef |grep -v grep|grep ${processName} |wc -l`;
	# echo "$processName count is at $processCount";
	# echo "-----do the work";
	# sleep 20
	# ----
	## - we call each script from here to check for available files to process
	bash /root/scripts/transcribe_example.sh;
    break
  fi
  sleep 5
done
