/*
www.Faweiz.com/radar
Radar Screen Visualisation for HC-SR04
Sends sensor readings for every degree moved by the servo
values sent to serial port to be picked up by Processing
*/

#include <NewPing.h>
#include <Servo.h> 
 
#define TRIGGER_PIN  2   // Arduino pin 2 tied to trigger pin on the ultrasonic sensor.
#define ECHO_PIN     3   // Arduino pin 3 tied to echo pin on the ultrasonic sensor.
#define MAX_DISTANCE 150 // Maximum distance we want to ping for (in centimeters). Maximum sensor distance is rated at 400-500cm.
#define SERVO_PWM_PIN 9 //set servo to Arduino's pin 9
 
// means -angle .. angle
#define ANGLE_BOUNDS 80
#define ANGLE_STEP 1
 
int angle = 0;
 
// direction of servo movement 
// -1 = back, 1 = forward 
int dir = 1;
 
Servo myservo;
NewPing sonar(TRIGGER_PIN, ECHO_PIN, MAX_DISTANCE); 
 
void setup() {
  Serial.begin(9600); // initialize the serial port:
  myservo.attach(SERVO_PWM_PIN); //set servo to Arduino's pin 9
}
 
void loop() {
 
  delay(50);
  // we must renormalize to positive values, because angle is from -ANGLE_BOUNDS .. ANGLE_BOUNDS
  // and servo value must be positive
  myservo.write(angle + ANGLE_BOUNDS);
  
  // read distance from sensor and send to serial
  getDistanceAndSend2Serial(angle);
  
  // calculate angle 
  if (angle >= ANGLE_BOUNDS || angle <= -ANGLE_BOUNDS) {
    dir = -dir;
  }
  angle += (dir * ANGLE_STEP);  
}
 
int getDistanceAndSend2Serial(int angle) {
  int cm = sonar.ping_cm();
  Serial.print(angle, DEC);
  Serial.print(",");
  Serial.println(cm, DEC);
  
}
