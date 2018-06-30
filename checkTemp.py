# This script checks the temprature of the temp probe, and prints that temp in
# Fahrenheit.  If you want the temp in Celsius, comment out line returning
# temp_f and uncomment the line returning temp_c in read_temp()
#
# There are lots of tutorials for setting up the temp sensor, I used this one:
# http://www.circuitbasics.com/raspberry-pi-ds18b20-temperature-sensor-tutorial/

import os
import glob
import time

os.system('/sbin/modprobe w1-gpio')
os.system('/sbin/modprobe w1-therm')

base_dir = '/sys/bus/w1/devices/'
device_folder = glob.glob(base_dir + '28*')[0]
device_file = device_folder + '/w1_slave'

def read_temp_raw():
    f = open(device_file, 'r')
    lines = f.readlines()
    f.close()
    return lines

def read_temp():
    lines = read_temp_raw()
    while lines[0].strip()[-3:] != 'YES':
        time.sleep(0.2)
        lines = read_tesmp_raw()
    equals_pos = lines[1].find('t=')
    if equals_pos != -1:
        temp_string = lines[1][equals_pos+2:]
        temp_c = float(temp_string) / 1000.0
        temp_f = temp_c * 9.0 / 5.0 + 32.0
        return temp_f
        #return temp_c

print read_temp()
