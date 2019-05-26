import serial
from xbee import XBee

PORT = '/dev/ttyUSB0'
BAUDRATE = 115200

serial_port = serial.Serial(PORT, BAUDRATE)
xbee = XBee(serial_port,escaped=True)

while True:
    try:
        print (xbee.wait_read_frame())
    except KeyboardInterrupt:
        break

serial_port.close()
