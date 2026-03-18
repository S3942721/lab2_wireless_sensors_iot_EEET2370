#define BAUDRATE 115200

#include <Console.h>
#include <SPI.h>
#include <RH_RF95.h>

const int groupNumber = 2;

// Singleton instance of the radio driver
RH_RF95 rf95;

int led = A2;
float frequency = 917.6;

void setup()
{
  pinMode(led, OUTPUT);
  Bridge.begin(BAUDRATE);
  Console.begin();
  while (!Console) ; // Wait for console port to be available
  Console.println("Start Sketch");
  if (!rf95.init())
    Console.println("init failed");

  rf95.setFrequency(frequency);
  // Setup Power,dBm
  rf95.setTxPower(3);

  // Setup Spreading Factor (6 ~ 12)
  rf95.setSpreadingFactor(7);

  // Setup BandWidth, option: 7800,10400,15600,20800,31200,41700,62500,125000,250000,500000
  rf95.setSignalBandwidth(125000);

  // Setup Coding Rate:5(4/5),6(4/6),7(4/7),8(4/8)
  rf95.setCodingRate4(5);

  Console.print("Listening on frequency: ");
  Console.println(frequency);
}

void loop()
{
  if (rf95.available())
  {
    // Should be a message for us now
    uint8_t buf[RH_RF95_MAX_MESSAGE_LEN];
    uint8_t len = sizeof(buf);
    if (rf95.recv(buf, &len))
    {
      digitalWrite(led, HIGH);

      //Decode the buffer
      if (len == 2){
        int8_t temperature = buf[0];
        int8_t humidity = buf[1];

        Console.print("Recv Temperature: " + String(temperature) + " Humidity " + String(humidity));
        Console.print(" RSSI: ");
        Console.println(rf95.lastRssi(), DEC);
      }

      uint8_t reply[] = "OK";

      rf95.send(reply, strlen(reply));
      rf95.waitPacketSent();
      Console.println("Sent a reply");
      digitalWrite(led, LOW);
    }
    else
    {
      Console.println("recv failed");
    }
  }
}
