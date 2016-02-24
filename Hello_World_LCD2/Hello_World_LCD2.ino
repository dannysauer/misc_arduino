/*
 Testing buttons as well
*/
#include <LiquidCrystal.h>

// initialize the library with the numbers of the interface pins
/* LCD Shield mappings:
 D8, // RS
 D9, // Enable
 D4, // bit 4
 D5, // bit 5
 D6, // bit 6
 D7  // bit 7
 D10 // backlight brightness
 A0  // buttons
 So, LiquidCrystal lcd(8, 9, 4, 5, 6, 7);
*/
LiquidCrystal lcd(
 8, // RS
 9, // Enable
 4, // bit 4
 5, // bit 5
 6, // bit 6
 7  // bit 7
);

#define PinBacklight 10
#define PinButton    0

// define some values used by the panel and buttons
int lcd_key     = 0;
int adc_key_in  = 0;
#define btnRIGHT  0
#define btnUP     1
#define btnDOWN   2
#define btnLEFT   3
#define btnSELECT 4
#define btnNONE   5

// distance sensor values
#define PING_DATA  2
#define PING_READ  3

// misc vars
String line1 = "";
String line2 = "";
String secs;
String key;

#define BrightMax 255
#define BrightMin 0
int brightness = BrightMax;
int brightness_increment = 1;
int brightness_direction = -1;

int dir;
byte char_up[8] = {
  B00100,
  B01110,
  B11111,
  B00100,
  B00100,
  B00100,
  B00100,
  B00100,
};
byte char_down[8] = {
  B00100,
  B00100,
  B00100,
  B00100,
  B00100,
  B11111,
  B01110,
  B00100,
};

#define CHAR_UP   6
#define CHAR_DOWN 7

// read the buttons
int read_LCD_buttons()
{
 adc_key_in = analogRead(PinButton);      // read the value from the sensor 
 //return adc_key_in;
 // example buttons when read are centered at these valies: 0, 144, 329, 504, 741
 // Danny's has: 0, 100, 256, 412, 641
 // we add approx 50 to those values and check to see if we are close
 if (adc_key_in > 1000) return btnNONE; // We make this the 1st option for speed reasons since it will be the most likely result
 // For V1.1 us this threshold
 if (adc_key_in < (0   + (100 - 0)   / 2 ))  return btnRIGHT;  
 if (adc_key_in < (100 + (256 - 100) / 2 ))  return btnUP; 
 if (adc_key_in < (256 + (412 - 256) / 2 ))  return btnDOWN; 
 if (adc_key_in < (412 + (641 - 412) / 2 ))  return btnLEFT; 
 if (adc_key_in <= 1000)                     return btnSELECT;  

 return btnNONE;  // when all others fail, return this...
}

void setup() {
  // define PWM brightness pin for output
  pinMode(PinBacklight, OUTPUT);

  // set up the LCD
  lcd.createChar(CHAR_UP, char_up);
  lcd.createChar(CHAR_DOWN, char_down);
  lcd.begin(16, 2);
  lcd.clear();
}

void loop() {
  brightness += brightness_increment * brightness_direction;
  if( brightness <= BrightMin ){
    brightness = BrightMin;
    brightness_direction *= -1;
  }
  if( brightness >= BrightMax ){
    brightness = BrightMax;
    brightness_direction *= -1;
  }
  analogWrite(PinBacklight, brightness);

  lcd_key = read_LCD_buttons();
//  analogWrite(PinBacklight, adc_key_in / 4);
  switch (lcd_key){
    case btnNONE: {
      key = "NONE";
      break;
    }
    case btnRIGHT: {
      key = "RIGHT";
      break;
    }
    case btnLEFT: {
      key = "LEFT";
      break;
    }
    case btnUP: {
      key = "UP";
      //lcd.display();
      //brightness = BrightMin;
      brightness_increment += 1;
      break;
    }
    case btnDOWN: {
      key = "DOWN";
      //brightness = BrightMin;
      brightness_increment -= 1;
      if( brightness_increment <= 1 ){
        brightness_increment = 1;
      }
      //lcd.noDisplay();
      break;
    }
    case btnSELECT: {
      key = "SELECT";
      break;
    }
  }

  // take a measurement
  pinMode(     PING_DATA, OUTPUT);
  digitalWrite(PING_DATA, HIGH);
  delay(10);
  digitalWrite(PING_DATA, LOW);
  pinMode(PING_READ, INPUT);
  // ping time is in microseconnds
  int ping_time = pulseIn(PING_READ, HIGH, 30*1000); // device times out at 30 milliseconds?
  float temp_in_c = 21; // ~70F
  // ping_time is in microseconds, so it *should* be divided by 10^6
  float distance_m = (float(ping_time/100) * 331.3 + (0.606 * temp_in_c)) / 2.0;
  int distance_cm = distance_m / 100;
  int distance_in = distance_m / 39.3701;

  // assemble LCD line
  line1 = "";
  line1 = "ADC:" + String(adc_key_in);
  while( line1.length() < 16 - key.length() ){
    line1 = line1 + " ";
  }
  line1 = line1 + key;
  lcd.setCursor(0,0);
  lcd.print(line1);

  // assemble second LCD line
  if( brightness_direction > 0 ){
    dir = CHAR_UP;
  }
  else{
    dir = CHAR_DOWN;
  }
  line2 = String(brightness_increment);
//  line2 = String(brightness_increment) + " " + distance_cm + "cm";
  line2 = String(brightness_increment) + " " + distance_in + "in";
  secs = String(millis()/1000);
  while( line2.length() < (16-1) - secs.length() ){
    line2 = line2 + " ";
  }
  line2 = line2 + secs;
  lcd.setCursor(0,1);
  lcd.write(dir);
  lcd.setCursor(1,1);
  lcd.print(line2);
}
