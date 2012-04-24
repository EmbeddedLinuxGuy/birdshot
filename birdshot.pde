/* -*- c -*-

 * Reads two analog pins that are supposed to be
 * connected to a jostick made of two potentiometers
 * 
 * Read Jostick copyleft 2005 DojoDave for DojoCorp
 * http://www.0j0.org | http://arduino.berlios.de
 */

#include <math.h>

  int buzzerPin = 40;

 int ledPin = 13;
int r_x_pin = 0;
int r_y_pin = 1;

 int joyPin1 = 2;                 // slider variable connecetd to analog pin 0
 int joyPin2 = 3;                 // slider variable connecetd to analog pin 1
 int value1 = 0;                  // variable to read the value from the analog pin 0
 int value2 = 0;                  // variable to read the value from the analog pin 1

int x_1;
int y_1;
int r_x_1;
int r_y_1;

void setup() {
  pinMode(ledPin, OUTPUT);              // initializes digital pins 0 to 7 as outputs
  pinMode(buzzerPin, OUTPUT);
  Serial.begin(9600);

  r_x_1 = analogRead(r_x_pin);
  r_y_1 = analogRead(r_y_pin);

  x_1 = analogRead(joyPin1);   
  y_1 = analogRead(joyPin2);
}

 int treatValue(int data) {
  return (data * 9 / 1024) + 48;
 }

int low_x = 1000;
int low_y = 1000;
int hi_x = 0;
int hi_y = 0;

//   -x
// +y  -y
//   +x

// x = 501 - 521
int x_0 = 501-1;
int x_max=798;

// y = 480 - 508
int y_0 = 480-1;
int y_max = 828;

//int xmin=192;
//int ymin=268;
//int xrange = 606;
//int yrange = 560;


int y_left = 494;
int y_right = 450;
int l_y_range;

int r_y_right = 531;
int r_y_left = 581;
int r_y_range = r_y_left - r_y_right;

typedef double Real;

// TARGET
// 0 1 2 3
int target;
int up = 2;

void loop() {
  // reads the value of the variable resistor 
  int x = analogRead(joyPin1);   
  delay(100);			  
  // this small pause is needed between reading
  // analog pins, otherwise we get the same value twice
  // reads the value of the variable resistor 
  int y = analogRead(joyPin2);   

  delay(100);
  int r_x = analogRead(r_x_pin);
  delay(00);
  int r_y = analogRead(r_y_pin);

  if (r_x > 700) {
      if (r_y > r_y_left) {
	  //	  Serial.print("LEFT\t");
	  //	  Serial.print(r_y);
	  target = 3;
      } else if (r_y < r_y_right) {
	  //	  Serial.print("RIGHT\t");
	  //	  Serial.print(r_y);
	  target = 0;
      } else {
	  //	  Serial.print("GOOD\t");
	  Real angle = (r_y - r_y_right) / (Real)(r_y_left - r_y_right);
	  //	  Serial.print(angle);
	  if (angle > 0.5) {
	      target = 2;
	  } else {
	      target = 1;
	  }
      }
      Serial.print(target);
      Serial.print("\n");
      if (target == up) {
	  digitalWrite(buzzerPin, HIGH);
      } else {
	  digitalWrite(buzzerPin, LOW);
      }
  } else {
      digitalWrite(buzzerPin, LOW);
  }
  return;

  Serial.print(x);
  Serial.print("\t");
  Serial.print(y);

  Real x_delta = (Real)(x - x_0) / (Real)(x_max - x_0);
  Real y_delta = (Real)(y - y_0) / (Real)(y_max - y_0);
  Real angle = atan(y_delta/x_delta);
  Real degrees = angle * 180.0 / 3.14159265;

  //  if (degrees > 0) { return; }
  degrees += 90;

  if (x < low_x) {
      low_x = x;
  } else if (x > hi_x) {
      hi_x = x;
  }
  if (y < low_y) {
      low_y = y;
  }
  if (y > hi_y) {
      hi_y = y;
  }
  //  (y > hi_y)? hi_y = y:;

  Serial.print("x: "); Serial.print(low_x); Serial.print('-');
  Serial.print(hi_x);
  Serial.print(" y: "); Serial.print(low_y); Serial.print('-');
  Serial.print(hi_y);
  Serial.write(10);

  return;

  // tan = o / a = x / y
  // angle = arctan (((y - ymin)/yrange) / ((x - xmin)/xrange))

  //  theta = arctan y / x

  //  Real slope = 1.0 / (((Real)(y - ymin)/(Real)yrange) / ((Real)(x - xmin)/(Real)xrange));
  //  Serial.print("\n");

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
  
      //  }
 }
