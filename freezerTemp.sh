#!/bin/bash

# This script checks the temp, logs it, then looks at the last few temps to see
# if the freezer is too warm.
#
# If 10 of the last 12 temps are too warm, an email will be sent.
#
# Run this script under a cron job once per minute
#
# * * * * * /home/pi/freezer_temp_alert/freezerTemp.sh 2>&1 >> /home/pi/freezer_temp_alert/logs/runlog.log
#

warnTemp=5
warnDuration=10
emailDelay=600
curTime=`date +%D-%T`
homeDir=/home/pi/freezer_temp_alert

check_prev_temps(){
  i=0
  temps=( $(tail -12 $homeDir/logs/tempLog.log) )
  for temp in ${temps[@]}
  do
    # remove timestamp from temp
    temp=$(echo $temp | sed 's/^.*,//')
    if (( $(echo "$temp > $warnTemp" | bc -l) ))
    then
      ((i++))
    fi
  done
    if [ "$i" -ge "$warnDuration" ]
    then
      # send an email, but only if one wasn't sent recently
      now=$(date +%s)
      delayedTime=$((now - $emailDelay))
      
      # when was the last email sent?
      prevEmail=`cat $homeDir/.prev_email`

      # check to see when the last email was sent.  If it was more than
      # 5 minutes ago, send another one.
      if [ "$delayedTime" -gt "$prevEmail" ]
      then
        echo "$curTime Sending alert email" >> $homeDir/logs/runlog.log
        #create a file that keeps track of when the previous email was sent
        echo `date +%s` > $homeDir/.prev_email
        `python $homeDir/sendEmail.py $warnTemp`
      fi
    fi
}

# Get the current temp
# log the temp to the temp log
# check the previous temps to see if an email needs to be sent

curTemp=`python $homeDir/checkTemp.py`
echo "$curTime,$curTemp" >> $homeDir/logs/tempLog.log
check_prev_temps
