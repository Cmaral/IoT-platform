import serial, json, re
from xbee import XBee

PORT = '/dev/ttyUSB0'
BAUDRATE = 115200

serial_port = serial.Serial(PORT, BAUDRATE)
xbee = XBee(serial_port,escaped=True)

# Function to obtain values from frame and store them in JSON file
def process_frame(frame):
    data = frame['rf_data']
    a,b,nodeId,frameId,luminosity,humidity,temperature,h = data.split(b'#')
    print(humidity[5:].decode(),temperature[4:].decode(),luminosity[4:].decode()) 


# Main function, read frames from serialport PORT
def main():
    while True:
        try:
            frame = xbee.wait_read_frame()
            process_frame(frame)                        
        except KeyboardInterrupt:
            break

    serial_port.close()

if __name__== "__main__":
  main()
  