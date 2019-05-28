#include <WaspSensorCities.h> 
#include <WaspXBee802.h>
#include <WaspFrame.h>

// Destination MAC address
char RX_ADDRESS[] = "0013A2004125398D";

// Waspmote ID
char WASPMOTE_ID[] = "SensorStation_1";

// Variables
uint8_t error;
  
float ldr_value;
float humidity_value;
float temperature_value;


void setup()
{
  // Init USB
  USB.ON();
  
  // Store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );  
  
  // Setup Smart Cities Board sensors
  SensorCities.setBoardMode(SENS_ON);
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_LDR);
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_HUMIDITY);
  SensorCities.setSensorMode(SENS_ON, SENS_CITIES_TEMPERATURE);
  
  // Init XBee
  xbee802.ON();
  
}


void loop()
{
  // Create new frame
  frame.createFrame(ASCII);  
  
  // Add sensor fields to frame 
  ldr_value = SensorCities.readValue(SENS_CITIES_LDR);
  frame.addSensor(SENSOR_LUM, ldr_value);
  humidity_value = SensorCities.readValue(SENS_CITIES_HUMIDITY);
  frame.addSensor(SENSOR_HUMA, humidity_value);
  temperature_value = SensorCities.readValue(SENS_CITIES_TEMPERATURE);
  frame.addSensor(SENSOR_TCA, temperature_value);

  // Send XBee packet
  error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );   
  
  if( error == 0 )
  {
    USB.println(F("send ok"));    
    
    // Blink LED
    Utils.blinkGreenLED();
    
  }

  // Wait 5 seconds
  delay(5000);
}



