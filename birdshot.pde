/* -*- c -*-

 * Reads two analog pins that are supposed to be
 * connected to a jostick made of two potentiometers
 * 
 * Read Jostick copyleft 2005 DojoDave for DojoCorp
 * http://www.0j0.org | http://arduino.berlios.de
 */

#include <math.h>

#define unconnected_pin 7

  int buzzerPin = 40;

 int ledPin = 13;
int r_x_pin = 0;
int r_y_pin = 1;

 int joyPin1 = 2;                 // slider variable connecetd to analog pin 0
 int joyPin2 = 3;                 // slider variable connecetd to analog pin 1
 int value1 = 0;                  // variable to read the value from the analog pin 0
 int value2 = 0;                  // variable to read the value from the analog pin 1

#define width 4
#define height 4
int birds[width][height] = {
    {10, 11, 12, 13},
    {25, 24, 23, 22},
    {6, 7, 8, 9},
    {2, 3, 4, 5}
};

int x_1;
int y_1;
int r_x_1;
int r_y_1;

int up = 2;
#define max_shape_size 6
typedef struct {
    int x;
    int y;
    bool up;
} Shape;

Shape shape[max_shape_size];
int shape_count = -1; // how many are left
int shape_size = -1; // size of this shape

int shots = -1;

void make_shape() {
    int j;
    Serial.print("Generating shape...\n");
    shape_count = random(2, max_shape_size);
    shape_size = shape_count;
    shots = shape_count + 3;
    for (j = 0; j < shape_count; ) {
	shape[j].x = random(0, 4);
	shape[j].y = random(0, 4);
	//	Serial.print(shape[j].x); Serial.print(" ");
	//Serial.print(shape[j].y); Serial.print("\n");
	bool redo = false;
	int i;
	for (i = 0; i < j; ++i) {
	    if (shape[i].x == shape[j].x && shape[i].y == shape[j].y) {
		redo = true;
		break;
	    }
	}
	if (! redo) {
	    shape[j].up = true;
	    Serial.print(shape[j].x); Serial.print(" ");
	    Serial.print(shape[j].y); Serial.print("\n");
	    ++j;
	}
    }
}

void setup() {
  pinMode(ledPin, OUTPUT);              // initializes digital pins 0 to 7 as outputs
  pinMode(buzzerPin, OUTPUT);
  Serial.begin(9600);

  r_x_1 = analogRead(r_x_pin);
  r_y_1 = analogRead(r_y_pin);

  x_1 = analogRead(joyPin1);   
  y_1 = analogRead(joyPin2);

  int x;
  int y;
  for (x=0; x < 4; ++x) {
      for (y=0; y < 4; ++y) {
	  pinMode(birds[x][y], OUTPUT);     
	  digitalWrite(birds[x][y], HIGH);
	  delay(100);
	  digitalWrite(birds[x][y], LOW);
	  delay(100);
      }
  }

  randomSeed(analogRead(unconnected_pin));
  make_shape();
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
int target = -1;
int up_state = HIGH;
unsigned long downtime;

#define MAX_WAIT 2000 // ms

int found_target = -1;
void loop() {
  int r_x = analogRead(r_x_pin);
  int r_y = analogRead(r_y_pin);

  bool any_up = false;
  int j;
  for (j = 0; j < shape_size; ++j) {
      digitalWrite(birds[shape[j].x][shape[j].y], shape[j].up ? HIGH : LOW);
      //digitalWrite(birds[shape[j].x][shape[j].y], HIGH);
      if (shape[j].up) {
	  any_up = true;
	  //	  Serial.print(shape[j].x);
	  //	  Serial.print(",");
	  //	  Serial.print(shape[j].y);
	  //	  Serial.print(" ");
      }
  }
  //  Serial.print("\n");

  if (shots <= 0) {
      int x;
      int y;
      for (x=0; x < 4; ++x) {
	  for (y=0; y < 4; ++y) {
	      pinMode(birds[x][y], OUTPUT);     
	      digitalWrite(birds[x][y], HIGH);
	      delay(100);
	      digitalWrite(birds[x][y], LOW);
	      delay(10);
	  }
      }

  }
  if ((!any_up) || (shots <= 0)) {
      make_shape();
  }

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
      //      Serial.print(target);

      bool on_target = false;
      for (j=0; j < shape_size; ++j) {
	  if (shape[j].up && shape[j].y == target) {
	      digitalWrite(buzzerPin, HIGH);
	      found_target = j;
	      on_target = true;
	      //	      Serial.print(" FOUND");
	  }
      }
      if (! on_target) {
	  digitalWrite(buzzerPin, LOW);
	  found_target = -1;
      }
      //      Serial.print("\n");
  } else {
      digitalWrite(buzzerPin, LOW);
      if (target >= 0) {
	  if (shots > 0) { --shots; }
	  Serial.print(shots);
	  Serial.print(" shots.\n");
      }
      if (found_target >= 0 && shape[found_target].up) {
	  shape[found_target].up = false;
#if 0
      	  shape_count--;
	  if (shape_count < 0) {
	      downtime = millis();
	      up_state = LOW;
	  }
#endif
      }
      found_target = -1;
      target = -1;
  }
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

int treatValue(int data) {
    return (data * 9 / 1024) + 48;
}

