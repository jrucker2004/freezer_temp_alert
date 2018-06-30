#!/bin/bash

# This script uses an infinite loop to log tempratures and send emails when the
# temp gets too low for too long.
#
# If 20 of the last 25 temps are too warm, an email will be sent.
#
# TODO:  Make this no an infinite loop.  Use cron to determine when it runs,
# and have this script just do it once each time it's called.
#
# TODO:  Add timestamps to logs
#
# TODO:  properly parse temps out of logs after timestamps are added
#
# TODO:  Add runtime logs

getTemp="python checkTemp.py"
checkInterval=30
warnTemp=5
warnDuration=20
prevEmail=0
emailDelay=300

check_prev_temps(){
  i=0
  temps=( $(tail -25 tempLog.log) )
  for temp in ${temps[@]}
  do
    if (( $(echo "$temp > $warnTemp" | bc -l) ))
    then
      ((i++))
    fi
  done
    if [ "$i" -ge "$warnDuration" ]
    then
      now=$(date +%s)
      delayedTime=$((now - $emailDelay))

      # check to see when the last email was sent.  If it was more than
      # 5 minutes ago, send another one.
      if [ "$delayedTime" -gt "$prevEmail" ]
      then
        prevEmail=$(date +%s)
        `python sendEmail.py $warnTemp`
      fi
    fi
}

# loop forever, logging temps, and check the logged temps
while [ 1==1 ]
do
  curTemp=`$getTemp`
  echo $curTemp >> tempLog.log
  check_prev_temps
  sleep $checkInterval
done
