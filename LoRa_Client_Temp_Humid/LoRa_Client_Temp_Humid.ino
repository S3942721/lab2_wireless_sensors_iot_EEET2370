#include <dht.h>
dht DHT;
#include <SPI.h>
#include <RH_RF95.h>

#define DHT11_PIN 5

RH_RF95 rf95; // Create radio object
float frequency = 917.60; // This frequency is for Group 2

void setup() 
{
  Serial.begin(9600); // 
  Serial.println("Start LoRa Client");
  if (!rf95.init())
    Serial.println("init failed");
  
  rf95.setFrequency(frequency); 
  
  // Setup Power,dBm
  rf95.setTxPower(3); // Do not increase the transmit power as you do not need to operate over a long range
  
  rf95.setSpreadingFactor(7); // Setup Spreading Factor (6 ~ 12)
  
  // Setup BandWidth, option: 7800,10400,15600,20800,31200,41700,62500,125000,250000,500000
  //Lower BandWidth for longer distance.
  rf95.setSignalBandwidth(125000);
  
  // Setup Coding Rate:5(4/5),6(4/6),7(4/7),8(4/8) 
  rf95.setCodingRate4(5);
}

void loop()
{
  Serial.println("Sending message to LoRa Server");
  // Send a message to LoRa Server

  int chk = DHT.read11(DHT11_PIN);
  Serial.print("Temperature = ");
  Serial.println(DHT.temperature);
  Serial.print("Humidity = ");
  Serial.println(DHT.humidity);
  delay(2000);
  
  uint8_t data[] = {(int8_t)DHT.temperature, (int8_t)DHT.humidity}; 
  rf95.send(data, sizeof(data));
  
  rf95.waitPacketSent();
  // Now wait for a reply
  uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
  uint8_t len = sizeof(buf);

  if (rf95.waitAvailableTimeout(3000))
  { 
    // Should be a reply message for us now   
    if (rf95.recv(buf, &len))
   {
      Serial.print("got a reply: ");
      Serial.println((char*)buf);
      Serial.print("RSSI: ");
      Serial.println(rf95.lastRssi(), DEC);    
    }
    else
    {
      Serial.println("recv failed");
    }
  }
  else
  {
    Serial.println("No reply, is LoRa server running?");
  }
  delay(5000);
}
