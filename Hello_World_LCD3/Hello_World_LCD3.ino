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

String line1 = "";
String line2 = "";
String secs;
String key;

#define BrightMax 255
#define BrightMin 0
int brightness_increment = -2;
int brightness = BrightMax;

// read the buttons
int read_LCD_buttons()
{
 adc_key_in = analogRead(PinButton);      // read the value from the sensor 
 //return adc_key_in;
 // example buttons when read are centered at these valies: 0, 144, 329, 504, 741
 // Danny: 0, 100, 256, 412, 641
 // we add approx 50 to those values and check to see if we are close
 if (adc_key_in > 1000) return btnNONE; // We make this the 1st option for speed reasons since it will be the most likely result
 // For V1.1 us this threshold
 if (adc_key_in < (0   + (100 - 0)   / 2 ))  return btnRIGHT;  
 if (adc_key_in < (100 + (256 - 100) / 2 ))  return btnUP; 
 if (adc_key_in < (256 + (412 - 256) / 2 ))  return btnDOWN; 
 if (adc_key_in < (412 + (641 - 412) / 2 ))  return btnLEFT; 
 if (adc_key_in <= 1000)                     return btnSELECT;  

 // For V1.0 comment the other threshold and use the one below:
/*
 if (adc_key_in < 50)   return btnRIGHT;  
 if (adc_key_in < 195)  return btnUP; 
 if (adc_key_in < 380)  return btnDOWN; 
 if (adc_key_in < 555)  return btnLEFT; 
 if (adc_key_in < 790)  return btnSELECT;   
*/

 return btnNONE;  // when all others fail, return this...
}

void setup() {
  // define PWM brightness pin for output
  pinMode(PinBacklight, OUTPUT);
  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
  lcd.clear();
}

void loop() {
  lcd_key = read_LCD_buttons();
  switch (lcd_key){
    case btnNONE: {
      key = "NONE";
      break;
    }
    case btnRIGHT: {
      key = "RIGHT";
      brightness += 1;
      if( brightness >= BrightMax ){
        brightness = BrightMax;
      }
      break;
    }
    case btnLEFT: {
      key = "LEFT";
      brightness -= 1;
      if( brightness <= BrightMin ){
        brightness = BrightMin;
      }
      break;
    }
    case btnUP: {
      key = "UP";
      lcd.display();
      brightness = BrightMax;
      break;
    }
    case btnDOWN: {
      key = "DOWN";
      brightness = BrightMin;
      lcd.noDisplay();
      break;
    }
    case btnSELECT: {
      key = "SELECT";
      break;
    }
  }
  analogWrite(PinBacklight, brightness);

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
  line2 = "inc:" + String(brightness_increment);
  secs = String(millis()/1000);
  while( line2.length() < 16 - secs.length() ){
    line2 = line2 + " ";
  }
  line2 = line2 + secs;
  lcd.setCursor(0,1);
  lcd.print(line2);
}
