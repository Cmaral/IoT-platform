#include <WaspSensorCities.h> 
#include <WaspXBee802.h>
#include <WaspFrame.h>

// Destination MAC address
char RX_ADDRESS[] = "0013A2004125398D";

// Waspmote ID
char WASPMOTE_ID[] = "SensorStation_1";

// Variables
uint8_t error;
  
float ldr_value, ldr_sent;
float humidity_value, humidity_sent;
float temperature_value, temperature_sent;


void setup()
{
  // Init USB
  USB.ON();
  
  // Store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );  
  
  // Setup variables
  ldr_sent = 0;
  humidity_sent = 0;
  temperature_sent = 0;
  
  // Setup Smart Cities Board sensors
  SensorCities.setBoardMode(SENS_ON);
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_LDR);
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_HUMIDITY);
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_TEMPERATURE);
        
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
  // Read values
  ldr_value = SensorCities.readValue(SENS_CITIES_LDR);
  humidity_value = SensorCities.readValue(SENS_CITIES_HUMIDITY);
  temperature_value = SensorCities.readValue(SENS_CITIES_TEMPERATURE); 
  
  // Map LDR value to new scale
  float ldr_mapped = map(ldr_value, 0, 100, 0, 1600);
    
  // To lower consumption, only send a new packet if any of the values differs enough from the previously sent one.
  if (((abs(ldr_mapped - ldr_sent)) >= 1) or ((abs(temperature_value - temperature_sent)) >= 1) or ((abs(humidity_value - humidity_sent)) >= 1)) {
    USB.print("sent");
    // Create new frame
    frame.createFrame(ASCII);    
    // Add sensor fields to frame 
    frame.addSensor(SENSOR_LUM, ldr_mapped);
    frame.addSensor(SENSOR_HUMA, humidity_value);
    frame.addSensor(SENSOR_TCA, temperature_value);
    
    // Send XBee packet
    xbee802.send( RX_ADDRESS, frame.buffer, frame.length ); 
  }
     
  humidity_sent = humidity_value;
  ldr_sent = ldr_mapped;
  temperature_sent = temperature_value;

  // Wait 5 seconds
  delay(5000);
}

