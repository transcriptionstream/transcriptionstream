#!/bin/bash
# Process control example with different limits for multiple processes
#  by changing the maximum concurrent runs value, you can increase/decrease
#  the maximum running processes per. Default 1.
#
#  Changes accomodate post processing transcriptions with LLM

# Process names and their maximum concurrent runs
process1="transcribe_example.sh"
maxConcurrentRuns1=$MAX_CONCURRENT_TRANSFORMS  # Maximum concurrent runs for process1

process2="auto-summary.py"
maxConcurrentRuns2=$MAX_CONCURRENT_SUMMARYS  # Maximum concurrent runs for process2

# Delay between starting each script (in seconds)
delayBetweenStarts=10

# Function to start a process if it hasn't reached its limit
start_process_if_allowed() {
  local processName=$1
  local maxConcurrentRuns=$2
  local runningInstances

  # Count the number of running instances of the process
  runningInstances=$(ps -ef | grep -v grep | grep $processName | wc -l)

  # Start additional instances if the maximum limit has not been reached
  if [ $runningInstances -lt $maxConcurrentRuns ]; then
    echo "Starting new instance of $processName. Current count: $runningInstances"
    
    # Check if the process is a Python script
    if [[ $processName == *.py ]]; then
      python3 /root/scripts/$processName &
    else
      bash /root/scripts/$processName &
    fi

    sleep $delayBetweenStarts
  fi
}

while true
do
  # Check and start process1 if allowed
  start_process_if_allowed $process1 $maxConcurrentRuns1

  # Check and start process2 if allowed
  start_process_if_allowed $process2 $maxConcurrentRuns2

  # Sleep for a short duration before checking again
  sleep 5
done
