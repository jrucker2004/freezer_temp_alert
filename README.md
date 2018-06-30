# freezer_temp_alert
Send an email alert when the freezer warms up too much.
This project was created to use a raspberry pi zero and a DS18B20 temprature
sensor to notify me when my freezer wasn't working.  I'm also using a third
party service to ping the raspberry pi, so I'm notified when the power goes
out.

# Things you'll need to do
create a cron job to check the temp sensor
create a cron job to archive logs
configure the email job in sendEmail.py
