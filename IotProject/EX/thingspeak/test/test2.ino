#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ThingSpeak.h>
#define PIN      14
#define DELAYVAL 10


//wifi
const char* ssid = "";
const char* password = "";
const char* server = "api.thingspeak.com";
WiFiClient client;


//초음파
const int trigPin = 13;
const int echoPin = 12;
int PIR = 14;
long duration;
float distance;


//thingSpeak
unsigned long ChannelID = ;
const char * WriteAPIKey = "";


void setup() {
  Serial.begin(115200);
  delay(10);

  initWifi();
  
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(PIR, INPUT);

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
    if(digitalRead(PIR) == HIGH){
          Serial.println("detect");
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
          digitalWrite(PIR, LOW);
    }else{
        if(digitalRead(PIR)== LOW){
          Serial.println("Undetect");
          distance = 0;
        }

        
    }


  if (client.connect(server,80)){
    if (distance == 0){
       Serial.println("감지되지 않았습니다.");
    }
    else{
      String getStr = "api.thingspeak.com/update?api_key=";
      getStr += WriteAPIKey;
      getStr += "&field2=";
      getStr += String(distance);
  
      getStr += "\r\n\r\n";
  
      Serial.println("% send to Thingspeak");
      Serial.println(getStr);
      
      ThingSpeak.writeField(ChannelID, 2, distance, WriteAPIKey);
    }

  }

  Serial.println("Waiting…");

}
