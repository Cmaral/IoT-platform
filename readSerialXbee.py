# Read frames received on XBee module connected to PORT and print them

import serial
from xbee import XBee

PORT = '/dev/ttyUSB0'
BAUDRATE = 115200

serial_port = serial.Serial(PORT, BAUDRATE)
xbee = XBee(serial_port,escaped=True)

while True:
    try:
        frame = xbee.wait_read_frame()
        #xbee.wait_read_frame() returns dictionary 
        print (frame)
    except KeyboardInterrupt:
        break

serial_port.close()
