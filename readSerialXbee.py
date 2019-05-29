# Receives frames from Waspmote Smart Cities board with Temperature, Humidity and Luminosity sensors
# Communication via Xbee PRO S1 802.15.4

import serial, json, re
from xbee import XBee

PORT = '/dev/ttyUSB2'
BAUDRATE = 115200

serial_port = serial.Serial(PORT, BAUDRATE)
xbee = XBee(serial_port,escaped=True)

# Function obtains values (Temperature, Humidity, Luminosity) from frame and stores them in JSON file
def process_frame(frame):
    data = frame['rf_data']
    a,b,nodeId,frameId,luminosity,humidity,temperature,h = data.split(b'#')
    
    temperature = temperature[4:].decode() # Celsius
    humidity = humidity[5:].decode() # 0-100 range
    luminosity = luminosity[4:].decode() # 0-100 range
    
    print(temperature, humidity, luminosity) 


# Main function
# Reads frames from serialport PORT
def main():
    while True:
        try:
            frame = xbee.wait_read_frame()
            try:
                process_frame(frame)  
            except:
                pass                      
        except KeyboardInterrupt:
            break

    serial_port.close()

if __name__== "__main__":
  main()
  