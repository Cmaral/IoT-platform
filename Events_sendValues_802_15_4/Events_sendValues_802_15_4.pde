#include <WaspSensorEvent_v20.h>
#include <WaspXBee802.h>
#include <WaspFrame.h>

// Destination MAC address
char RX_ADDRESS[] = "0013A200412539CE";

// Waspmote ID
char WASPMOTE_ID[] = "SensorStation_2";

// Variables
uint8_t error;
  
float ldr_value, ldr_sent, ldr_mapped;
float temperature_value, temperature_sent;
float presence_value, presence_sent;

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
  presence_sent = 0;
  
  // Setup Events Board sensors
  SensorEventv20.ON();   
    
  // Turn on XBee
  xbee802.ON();
  
  // Configure sensor threshold for each sensor used
  SensorEventv20.setThreshold(SENS_SOCKET1, 3.3);
  SensorEventv20.setThreshold(SENS_SOCKET5, 3.3);
  SensorEventv20.setThreshold(SENS_SOCKET7, 3.3);
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
  // Enable interruptions from the board
  SensorEventv20.attachInt();
  
  // Put the mote to sleep
  USB.println(F("Enter sleep mode..."));  
  PWR.sleep(UART0_OFF | UART1_OFF | BAT_OFF | RTC_OFF);
  USB.println(F("...wake up")); 
  
  // Disable interruptions from the board
  SensorEventv20.detachInt();
  
  // Load the interruption register
  SensorEventv20.loadInt();

  // Compare the interruption received with the sensor identifier
  if ((SensorEventv20.intFlag & SENS_SOCKET1) or (SensorEventv20.intFlag & SENS_SOCKET5) or (SensorEventv20.intFlag & SENS_SOCKET7))
  {   
    USB.println(F("---------------------------"));    
    USB.println(F("Interruption captured"));    
    USB.println(F("---------------------------"));    
    RTC.ON();
    RTC.getTime();
    
    // Turn on XBee
    xbee802.ON();
    
    // Read raw sensor values
    ldr_value = SensorEventv20.readValue(SENS_SOCKET1, SENS_RESISTIVE);  
    temperature_value = SensorEventv20.readValue(SENS_SOCKET5);
    presence_value = SensorEventv20.readValue(SENS_SOCKET7);
    
  
    // Temperature conversion using fixed coefficients
    temperature_value = c1 + c2 * temperature_value;
  
    // Light conversion
    ldr_value = (1.5 * ldr_value * 6250) / 4096;  
    ldr_mapped = map(ldr_value, 35, 0, 0, 1600);
     
    // Create new frame
    frame.createFrame(ASCII); 
    
    // Add sensor fields to frame 
    frame.addSensor(SENSOR_LUM, ldr_mapped);
    frame.addSensor(SENSOR_TCA, temperature_value);
    frame.addSensor(SENSOR_PIR, presence_value);
    frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second );
    
    // Send XBee packet
    error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );

    if (error = 0) USB.print("Packet sent\n");
  }
       
  // Reset values     
  ldr_sent = ldr_mapped;
  temperature_sent = temperature_value; 
  presence_sent = presence_value; 

}

