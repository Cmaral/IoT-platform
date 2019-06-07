#include <WaspSensorEvent_v20.h>
#include <WaspXBee802.h>
#include <WaspFrame.h>

// Destination MAC address
char RX_ADDRESS[] = "0013A200412539CE";

// Waspmote ID
char WASPMOTE_ID[] = "SensorStation_2";

// Variables
uint8_t error;
  
float ldr_value, ldr_sent;
float temperature_value, temperature_sent;

float c1=10;
float c2=19.5;

float diff=0.5;


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

float map(long x, long in_min, long in_max, long out_min, long out_max)
{
  float value = (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
  if (value>out_max) return out_max;
  if (value<out_min) return out_min;
  else return value;
}

void loop()
{
  
   // Read raw sensor values
  ldr_value = SensorEventv20.readValue(SENS_SOCKET1, SENS_RESISTIVE);  
  temperature_value = SensorEventv20.readValue(SENS_SOCKET5);
  
  // Temperature conversion using fixed coefficients
  temperature_value = c1 + c2 * temperature_value;
  
  float ldr_mapped = map(ldr_value, 15, 0, 0, 100);

  // To lower consumption, only send a new packet if any of the values differs enough from the previously sent one.
  if (((abs(ldr_mapped - ldr_sent)) >= diff) or ((abs(temperature_value - temperature_sent)) >= diff)) {    
    
    // Create new frame
    frame.createFrame(ASCII); 
    
    // Add sensor fields to frame 
    frame.addSensor(SENSOR_LUM, ldr_mapped);
    frame.addSensor(SENSOR_TCA, temperature_value);
    
    // Send XBee packet
    error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );
        
    if (error = 0) USB.print("Packet sent\n");
  }
       
  // Reset values     
  ldr_sent = ldr_mapped;
  temperature_sent = temperature_value;  

  // Wait 5 seconds
  delay(5000);
}

