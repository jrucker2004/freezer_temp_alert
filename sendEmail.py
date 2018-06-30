# This script sends an email when called.  It does a few other things specific
# to the temprature alert system.
# The email body contains a useful message, as well as a history of the last 25
# tempratures that were logged.
#
# There are lots of tutorials for setting up email, I used this one:
# https://www.youtube.com/watch?v=0kpGcMjpDcw
# This script assumes you're using gmail as your SMTP server.  You may need to make
# some changes if you're not
#
# Takes in one arg: warnTemp.  This is the temp that is configured in
# freezerTemp.sh.

import sys
import smtplib
import os

argList = sys.argv

warnTemp = argList[1]

smtpUser = '<smtp_email_address>'
smtpPass = '<smtp_email_password>'
toAdd = '<email_to_address>'
fromAdd = '<email_from_address>'
subject = 'FREEZER IS WARM!'
header = 'To: ' + toAdd + '\n' + 'From: ' + fromAdd + '\n' + 'Subject: ' + subject
body = 'Fereezer has been below ' + str(warnTemp) + ' degrees fahrenheit for too long. \n here are the last 25 recorded temps: \n '

def send_email():
    s = smtplib.SMTP('smtp.gmail.com',587)

    s.ehlo()
    s.starttls()
    s.ehlo()

    s.login(smtpUser, smtpPass)
    s.sendmail(fromAdd, toAdd, header + '\n' + body)

    s.quit()
    return

def get_temps (f, n):
    stdin,stdout = os.popen2("tail -n "+n+" "+f)
    stdin.close()
    lines = stdout.readlines(); stdout.close
    return lines

temps = get_temps('tempLog.log', '25')

body = body + "".join([str(i) for i in temps])

send_email()
