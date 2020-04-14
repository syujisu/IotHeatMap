#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ThingSpeak.h>


//wifi
const char* ssid = "iPhone";
const char* password = "wltn2548";
const char* server = "api.thingspeak.com";
WiFiClient client;

//초음파
const int trigPin = 13;
const int echoPin = 12;
long duration;
float distance;

//thingSpeak
unsigned long ChannelID = 1037366;
const char * WriteAPIKey = "UDZRKMA7K2WUW5IG";


void setup() {
  Serial.begin(115200);
  delay(10);

  initWifi();
  
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  ThingSpeak.begin(client);
}

void initWifi(){
  // Connect to WiFi network
  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED){
    delay(500);
    Serial.println("wait..");
  }
  
   // 접속성공!
  Serial.println();
  Serial.println("Connected WiFi");
}


void loop(){
  //초음파 코드 
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);
  duration = pulseIn(echoPin, HIGH);
  distance = duration*0.034/2; //Cm
  Serial.print("Distance : ");
  Serial.print(distance);
  Serial.println("CM");

  if (client.connect(server,80)){
    String getStr = "api.thingspeak.com/update?api_key=";
    getStr += WriteAPIKey;
    getStr += "&field1=";
    getStr += String(distance);

    getStr += "\r\n\r\n";

    Serial.println("% send to Thingspeak");
    Serial.println(getStr);

    int x = ThingSpeak.writeField(ChannelID, 1, distance, WriteAPIKey);

    if(x == 200){
    Serial.println("Channel update successful.");
    }
    else{
      Serial.println("Problem updating channel. HTTP error code " + String(x));
    }
  }

  Serial.println("Waiting…");
  delay(17000); 

}
