#include <WaspSensorEvent_v20.h>
#include <WaspXBee802.h>
#include <WaspFrame.h>

// Destination MAC address
char RX_ADDRESS[] = "0013A200412539CE";

// Waspmote ID
char WASPMOTE_ID[] = "SensorStation_1";

// Variables
uint8_t error;
  
float ldr_value, ldr_sent;
float temperature_value, temperature_sent;


void setup()
{
  // Init USB
  USB.ON();
  
  // Store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );  
  
  // Setup variables
  ldr_sent = 0;
  temperature_sent = 0;
  
  // Setup Events Board sensors
  SensorEventv20.ON();   
    
  // Turn on XBee
  xbee802.ON();
}


void loop()
{
   // Read values
  ldr_value = SensorEventv20.readValue(SENS_SOCKET2, SENS_RESISTIVE);
  temperature_value = SensorEventv20.readValue(SENS_SOCKET5, SENS_TEMPERATURE);
  USB.print(ldr_value);  
  USB.print("---");
  USB.print(ldr_sent);  
  USB.print("---");
    
  // To lower consumption, only send a new packet if any of the values differs enough from the previously sent one.
  if (abs((temperature_sent - temperature_value) >= 1) or abs((ldr_sent - ldr_value) >= 1)) {
    USB.print("send");
    // Create new frame
    frame.createFrame(ASCII);    
    // Add sensor fields to frame 
    frame.addSensor(SENSOR_LUM, ldr_value);
    frame.addSensor(SENSOR_TCA, temperature_value);
    
    // Send XBee packet
    xbee802.send( RX_ADDRESS, frame.buffer, frame.length ); 
  }
 
  ldr_sent = ldr_value;
  temperature_sent = temperature_value;

  // Wait 5 seconds
  delay(5000);
}


