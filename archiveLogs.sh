#!/bin/bash

# This script will archive the temprature log when it's run.
# The log file will simply be moved into the archive directory.
# Old archived log files will be deleted to keep them from filling up the
# hard drive.
#
# This should be run under a cron job at the desired frequency.  I suggest
# once per day.
#
# 0 1 * * * /home/pi/freezer_temp_alert/archiveLogs.sh 2>&1 >> /home/pi/freezer_temp_alert/logs/runlog.log 

curTime=`date +%D-%T`
curDate=$(date +%m-%d-%y)
archiveName=$curDate\_tempLog.log.tar.gz
logDir=/home/pi/freezer_temp_alert/logs

# move the log file to the archive dir, compress it, then delete the raw file.
echo "$curTime creating archived temp log $archiveName"
cd $logDir/archive
mv $logDir/tempLog.log $logDir/archive/
tar -cvzf $archiveName tempLog.log
rm $logDir/archive/tempLog.log

# remove all files in the archive that are older than 10 of days.
# making this a configed number of days was more complicated than it was worth.
echo "$curTime deleting old archive log files"
find $logDir/archive/*tempLog* -mtime +10 -exec rm {} \;

# Archive the runtime log file if it's older than 1 month.
fileCreated=$(head -1 $logDir/runlog.log | awk '{print $1}')
dateFileCreated=${fileCreated%-*}
formattedFileCreated=$(date -d $dateFileCreated +%s)
archiveAge=$(date -d "-30 days" +%s)
scriptArchiveName=$curDate\_runlog.log.tar.gz


# Note:  This will break if the first line in runlog.log doesn't have
# a properly formatted date, or if the runlog.log doesn't contain any text.
if [ "$formattedFileCreated" -le "$archiveAge" ]
then
  # The log file was first written to more than the archive age ago, archive it
  # and delete the old archive file
  echo "$curTime archiving script log file"
  # remove old archived logs
  rm $logDir/archive/*runlog*
  # move old log file to archive
  cd $logDir/archive
  mv $logDir/runlog.log $logDir/archive
  # compress the log file
  tar -cvzf $scriptArchiveName runlog.log
  # remove the old log file
  rm $logDir/archive/runlog.log
fi
   
