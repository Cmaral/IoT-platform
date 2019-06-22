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
float diff_ldr=80;
float diff_temp=1.0;

void setup()
{
  // Store Waspmote identifier in EEPROM memory
  frame.setID( WASPMOTE_ID );  
  
  // Setup variables
  ldr_sent = 0;
  temperature_sent = 0;
  presence_sent = 0;
  
  // Init USB
  USB.ON();  
  // Turn on the Events Sensor Board
  SensorEventv20.ON();
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
  // Put the mote to sleep for 10 seconds
  USB.println(F("Entering sleep mode"));  
  PWR.deepSleep(“00:00:00:10”, RTC_OFFSET, RTC_ALM1_MODE2, ALL_OFF);
  USB.ON();
  USB.println(F("Woke up"));

  RTC.ON();
  RTC.getTime();
   
  // Read raw sensor values
  ldr_value = SensorEventv20.readValue(SENS_SOCKET1, SENS_RESISTIVE);  
  temperature_value = SensorEventv20.readValue(SENS_SOCKET5);
  presence_value = SensorEventv20.readValue(SENS_SOCKET7);    
  
  // Temperature conversion using fixed coefficients
  temperature_value = c1 + c2 * temperature_value;
  
  // Light conversion
  ldr_value = (1.5 * ldr_value * 6250) / 4096;  
  ldr_mapped = map(ldr_value, 35, 0, 0, 1600);
    
  // If values are significantly different from the previous ones, send frame
  if (((abs(ldr_mapped - ldr_sent)) >= diff_ldr) or ((abs(temperature_value - temperature_sent)) >= diff_temp) or (presence_value != presence_sent)) {
    // Turn on XBee
    xbee802.ON();
    // Create new frame
    frame.createFrame(ASCII); 

    // Add sensor fields to frame 
    frame.addSensor(SENSOR_LUM, ldr_mapped);
    frame.addSensor(SENSOR_TCA, temperature_value);
    frame.addSensor(SENSOR_PIR, presence_value);
    frame.addSensor(SENSOR_TIME, RTC.hour, RTC.minute, RTC.second );

    // Send XBee packet
    error = xbee802.send( RX_ADDRESS, frame.buffer, frame.length );
   }
  }
       
  // Reset values     
  ldr_sent = ldr_mapped;
  temperature_sent = temperature_value; 
  presence_sent = presence_value; 

}

