/*
 * Lee's retirement countdown clock
 *
 * I'm using a SainSmart LCD shield with an Uno, and a DS1370 RTC to make it accurate
 *
 * Links to the Amazon items I used:
 * http://www.amazon.com/gp/product/B0076FWAH8
 * http://www.amazon.com/gp/product/B00LZCTMJM
 */

/* 
 set up for the RTC
 Libraries used are at
  http://www.pjrc.com/teensy/td_libs_Time.html
  http://www.pjrc.com/teensy/td_libs_DS1307RTC.html
 as referenced by http://playground.arduino.cc/Code/Time
*/
#include <Wire.h>
#include <DS1307RTC.h>
#include <Time.h>
#include <TimeLib.h>

tmElements_t tm;

/*
 Set up for the LCD
*/
#include <LiquidCrystal.h>
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
 // example buttons when read are centered at these valies: 0, 144, 329, 504, 741
 // values measured in Lee's display: 0, 143, 328, 503, 741 (really close to the author's, apparently)
 // I add half the distance to the next button to allow for as much variance as is reasonably likely
 //
 // I picked 1000 as the top cutoff mostly arbitrarily; ~1024 is the select, due to being "infinite"
 // I suppose the "right" way would be to do 741+(1024-741/2) to be consistent
 if (adc_key_in > 1000) return btnNONE; // We make this the 1st option for speed reasons since it will be the most likely result
 if (adc_key_in < (0   + (143 - 0)   / 2 ))  return btnRIGHT;  
 if (adc_key_in < (143 + (328 - 143) / 2 ))  return btnUP; 
 if (adc_key_in < (328 + (503 - 328) / 2 ))  return btnDOWN; 
 if (adc_key_in < (503 + (741 - 503) / 2 ))  return btnLEFT; 
 if (adc_key_in <= 1000)                     return btnSELECT;  
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
  if(RTC.read(tm)){
    secs = "ok!" + String(tm.Second);
  }
  while( line2.length() < 16 - secs.length() ){
    line2 = line2 + " ";
  }
  line2 = line2 + secs;
  lcd.setCursor(0,1);
  lcd.print(line2);
}
