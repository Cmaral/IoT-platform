# Receives frames from Waspmote boards with Temperature, Humidity and/or Luminosity sensors and
# inserts them into a database
# Communication via Xbee PRO S1 802.15.4

import serial, json, re, mysql.connector, time
from xbee import XBee

#PORT = '/dev/ttyUSB' + input("Port (Use 0-4 for ttyUSBX): ")
PORT = '/dev/ttyUSB0'
print ("Using port", PORT)
BAUDRATE = 115200
NODEID = "SensorStation2"
serial_port = serial.Serial(PORT, BAUDRATE)
xbee = XBee(serial_port,escaped=True)

# --------- #

def insert_values(TEMP, LUMI, PIR):
    mydb = mysql.connector.connect(
        host="database_url",
        user="username",
        passwd="password",
        database="sensordb"
    )
    cursor = mydb.cursor()
    now = time.strftime(r"%Y.%m.%d %H:%M:%S", time.localtime())
    print(now)
    sql_query = "INSERT INTO data (nodeid, time, temperature, light, presence) VALUES (%s, %s, %s, %s, %s)"
    val = (NODEID, now, TEMP, LUMI, PIR)
    cursor.execute(sql_query, val)

    mydb.commit()

    print(cursor.rowcount, "record inserted.")


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
    if (data.find("PIR") != -1):
        PIR = re.findall(r"\PIR:(.*?)\#",data)[0]
        print("PIR=",PIR)
    else:
        PIR = '0.0'
    print("---")

    insert_values(TEMP,LUMI,PIR)


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
  
