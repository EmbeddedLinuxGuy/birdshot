/* -*- c -*-

 Read Jostick
  * ------------
  *
  * Reads two analog pins that are supposed to be
  * connected to a jostick made of two potentiometers
  * 
  * copyleft 2005 DojoDave for DojoCorp http://www.0j0.org http://arduino.berlios.de
  */
  int buzzerPin = 40;

 int ledPin = 13;
 int joyPin1 = 2;                 // slider variable connecetd to analog pin 0
 int joyPin2 = 3;                 // slider variable connecetd to analog pin 1
 int value1 = 0;                  // variable to read the value from the analog pin 0
 int value2 = 0;                  // variable to read the value from the analog pin 1

void setup() {
  pinMode(ledPin, OUTPUT);              // initializes digital pins 0 to 7 as outputs
  pinMode(buzzerPin, OUTPUT);
  Serial.begin(9600);
}

 int treatValue(int data) {
  return (data * 9 / 1024) + 48;
 }

int low_x = 500;
int low_y = 500;
int hi_x = 500;
int hi_y = 500;

int xmin=192;
int ymax=828;
int ymin=268;
int xmax=798;
int xrange = 606;
int yrange = 560;


typedef double Real;

void loop() {
  // reads the value of the variable resistor 
  int x = analogRead(joyPin1);   
  delay(100);			  
  // this small pause is needed between reading
  // analog pins, otherwise we get the same value twice
  // reads the value of the variable resistor 
  int y = analogRead(joyPin2);   

  // angle = arctan (((y - ymin)/yrange) / ((x - xmin)/xrange))
  Real slope = ((Real)(y - ymin)/(Real)yrange) / ((Real)(x - xmin)/(Real)xrange);
  Serial.print(slope);
  Serial.print("\n");
  return;

  //  digitalWrite(buzzerPin, HIGH);
  //  delay(1000);
  //  digitalWrite(buzzerPin, LOW);

  //  Serial.print(value1); Serial.print(' '); Serial.print(value2);
  //Serial.write(treatValue(value1));
  //Serial.print(' ');
  //Serial.write(treatValue(value2));
  //      Serial.print(value1);
  //  if (value1 > 760 && value1 < 770
  //      && value2 > 498 && value2 < 598) {
  if (value1 < low_x) {
      low_x = value1;
  } else if (value1 > hi_x) {
      hi_x = value1;
  }
  if (value2 < low_y) {
      low_y = value2;
  } else if (value2 > hi_y) {
      hi_y = value2;
  }

  Serial.print("x: "); Serial.print(low_x); Serial.print('-');
  Serial.print(hi_x);
  Serial.print(" y: "); Serial.print(low_y); Serial.print('-');
  Serial.print(hi_y);
  Serial.write(10);
  
      //  }
 }
