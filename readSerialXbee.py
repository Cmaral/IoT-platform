#TO-DO: Process NodeID, Sensor board type, time and hour, location?
# -----------------------------------------------------------

# Receives frames from Waspmote boards with Temperature, Humidity and/or Luminosity sensors
# Communication via Xbee PRO S1 802.15.4

import serial, json, re
from xbee import XBee

PORT = '/dev/ttyUSB' + input("Port (Use 0-4 for ttyUSBX): ")
print ("Using port", PORT)
BAUDRATE = 115200

serial_port = serial.Serial(PORT, BAUDRATE)
xbee = XBee(serial_port,escaped=True)

# Function obtains values (Temperature, Humidity, Luminosity) from frame and stores them in JSON file
def process_frame(frame):
    #Decode bytes
    data = frame['rf_data']
    data = data.decode("ISO-8859-1")

    #Find each value and assign to variables, if the frame contains them
    if (data.find("TCA") != -1):
        TEMP = re.findall(r"\TCA:(.*?)\#",data)[0]
        print("TEMP=",TEMP)
    if (data.find("HUMA") != -1):    
        HUMA = re.findall(r"\HUMA:(.*?)\#",data)[0]
        print("HUMA=",HUMA)
    if (data.find("LUM") != -1):
        LUMI = re.findall(r"\LUM:(.*?)\#",data)[0]
        print("LUMI=",LUMI)
    print("---")

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
  