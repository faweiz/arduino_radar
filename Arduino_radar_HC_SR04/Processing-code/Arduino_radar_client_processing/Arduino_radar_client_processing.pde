/*
www.Faweiz.com/radar
Radar Screen Visualisation for Sharp HC-SR04
Maps out an area of what the HC-SR04 sees from a top down view.
Takes and displays 2 readings, one left to right and one right to left.
Displays an average of the 2 readings
*/

import processing.serial.*;
 
int SIDE_LENGTH = 1000;
int ANGLE_BOUNDS = 80;
int ANGLE_STEP = 2;
int HISTORY_SIZE = 10;
int POINTS_HISTORY_SIZE = 500;
int MAX_DISTANCE = 50;
 
int angle;
int distance;

/* choose either color or background image */
color bgcolor = color (255,0,0);
PImage bgimage = loadImage("test.png");
 
int radius;
float x, y;
float leftAngleRad, rightAngleRad;
 
float[] historyX, historyY;
Point[] points;
 
int centerX, centerY;
 
String comPortString;
Serial myPort;
 
void setup() {
  size(SIDE_LENGTH, SIDE_LENGTH/2, P2D);
  noStroke();
  //smooth();
  rectMode(CENTER);
 
  radius = SIDE_LENGTH / 2;
  centerX = width / 2;
  centerY = height;
  angle = 0;
  leftAngleRad = radians(-ANGLE_BOUNDS) - HALF_PI;
  rightAngleRad = radians(ANGLE_BOUNDS) - HALF_PI;
 
  historyX = new float[HISTORY_SIZE];
  historyY = new float[HISTORY_SIZE];
  points = new Point[POINTS_HISTORY_SIZE];
 
  myPort = new Serial(this, "COM11", 9600);
  myPort.bufferUntil('\n'); // Trigger a SerialEvent on new line
}
 
 
void draw() {
 
/* choose either bgcolor or bgimage */
  
  background(bgimage);

  drawRadar();
  drawFoundObjects(angle, distance);
  drawRadarLine(angle);

 /* draw the grid lines on the radar every 30 degrees and write their values 180, 210, 240 etc.. */
  for (int i = 0; i <= 6; i++) {
    strokeWeight(1);
    stroke(0,255,0);
    line(radius, radius, radius + cos(radians(180+(30*i)))*SIDE_LENGTH/2, radius + sin(radians(180+(30*i)))*SIDE_LENGTH/2);
    fill(255, 255, 255);
    noStroke();
    text(Integer.toString(0+(30*i)), radius + cos(radians(180+(30*i)))*SIDE_LENGTH/2, radius + sin(radians(180+(30*i)))*SIDE_LENGTH/2, 25, 50);
  }

/* Write information text and values. */
  noStroke();
  fill(0);
int Degrees=0;

if (angle>0 & angle <80)
{
  Degrees = angle+100;
}
else if (angle<0 & angle >-80)
{
  Degrees = angle+80;
}

  fill(0, 300, 0);
  text("Degrees: "+Integer.toString(Degrees), 100, 460, 100, 50);   text("degree", 200, 460, 100, 50);      // use Integet.toString to convert numeric to string as text() only outputs strings
  text("Subject Distance: "+Integer.toString(distance), 100, 480, 200, 30);  text("mm", 200, 490, 100, 50);       // text(string, x, y, width, height)
  text("Radar screen code at www.Faweiz.com/radar", 900, 480, 250, 50);
  
  text("0", 620, 500, 250, 50);
  text("50 mm", 600, 420, 250, 50);

  text("100 mm", 600, 320, 250, 50);

  text("150 mm", 600, 220, 250, 50);
  
  text("200 mm", 600, 120, 250, 50);
  
  text("250 mm", 600, 040, 250, 50);
   
  noFill();
  rect(70,60,200,200);
  fill(0, 250, 0); 
  text("Screen Key:", 100, 50, 150, 50);
  fill(0,50,0);
  rect(30,53,10,10);
  text("Far", 115, 70, 150, 50);
  fill(0,110,0);
  rect(30,73,10,10);
  text("Near", 115, 90, 150, 50);
  fill(0,170,0);
  rect(30,93,10,10);
  text("Close", 115, 110, 150, 50);
}
 
void drawRadarLine(int angle) {
 
  float radian = radians(angle);
  x = radius * sin(radian);
  y = radius * cos(radian);
 
  float px = centerX + x;
  float py = centerY - y;
 
  historyX[0] = px;
  historyY[0] = py;
  
  int Degrees=0;
  if (angle>0 & angle <80)
  {
    Degrees = angle+100;
  }
  else if (angle<0 & angle >-80)
  {
    Degrees = angle+80;
  }
   
   //get rgb color from http://www.rapidtables.com/web/color/RGB_Color.htm
    fill(0, 153, 0); 
    
    float b = centerY;
    
    arc(centerX,centerY,SIDE_LENGTH, SIDE_LENGTH,radians(angle-100),radians(angle-90));
        
    shiftHistoryArray();
}
 
void drawFoundObjects(int angle, int distance) {
 
  if (distance > 0) {
    float radian = radians(angle);
    x = distance * sin(radian);
    y = distance * cos(radian);
 
    int px = (int)(centerX + x);
    int py = (int)(centerY - y);
 
    points[0] = new Point(px, py);
  }
  else {
    points[0] = new Point(0, 0);
  }
  for (int i=0;i<POINTS_HISTORY_SIZE;i++) {
 
    Point point = points[i];
  
    if (point != null) {
 
      int x = point.x;
      int y = point.y;
 
      if (x==0 && y==0) continue;
 
      int colorAlfa = (int)map(i, 0, POINTS_HISTORY_SIZE, 20, 0);
      int size = (int)map(i, 0, POINTS_HISTORY_SIZE, 30, 5);
 
      fill(0, 255, 0, colorAlfa);
      noStroke();
      ellipse(x, y, size, size);
    }
    
    fill(255, 0, 0);
  }
  
 shiftPointsArray();
  
}
 
void drawRadar() {
  stroke(0,255,0);
  noFill();
  // make 5 circle with 50mm each
  for (int i = 0; i <= (SIDE_LENGTH / 200); i++) {
    arc(centerX, centerY, 200 * i, 200 * i, leftAngleRad, rightAngleRad);
  }
}                              
 
void shiftHistoryArray() {
 
  for (int i = HISTORY_SIZE; i > 1; i--) {
 
    historyX[i-1] = historyX[i-2];
    historyY[i-1] = historyY[i-2];
  }
}
 
void shiftPointsArray() {
 
  for (int i = POINTS_HISTORY_SIZE; i > 1; i--) {
 
    Point oldPoint = points[i-2];
    if (oldPoint != null) {
 
      Point point = new Point(oldPoint.x, oldPoint.y);
      points[i-1] = point;
    }
  }
}
 
void serialEvent(Serial cPort) {
 
  comPortString = cPort.readStringUntil('\n');
  if (comPortString != null) {
 
    comPortString=trim(comPortString);
    String[] values = split(comPortString, ',');
    
    try {
    
      angle = Integer.parseInt(values[0]);
      distance = int(map(Integer.parseInt(values[1]), 1, MAX_DISTANCE, 1, radius));   
    } catch (Exception e) {}
  }
}
 
class Point {
  int x, y;
 
  Point(int xPos, int yPos) {
    x = xPos;
    y = yPos;
  }
 
  int getX() {
    return x;
  }
 
  int getY() {
    return y;
  }
}
