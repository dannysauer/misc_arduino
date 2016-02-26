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

/*
 EEPROM locations
*/
#include <EEPROM.h>
#define ADDR_RETIRE_TIME 0
time_t retire_time;
#define ADDR_BRIGHTNESS  ADDR_RETIRE_TIME + sizeof(time_t)
int brightness = BrightMax;

/*
 Menu stuff
*/
#include <MenuSystem.h>
// #include "./lee_retirement_menu.h"
/*
 * Menu definitions in header file to work around silly Arduino editor
 * which moves all function prototypes to top of file - above #include. :/
 */
MenuSystem ms;
Menu mm("Configuration menu");
MenuItem mi_backlight("Backlight Brightness");

Menu     mm_retirement(       "Retirement Date"  );
MenuItem mi_retirement_year(  "Retirement Year"  );
MenuItem mi_retirement_month( "Retirement Month" );
MenuItem mi_retirement_day(   "Retirement Day"   );

/*
 Arduino adds prototypes for any unprototyped functions at the top of
 the file - above #include statements.  Using a type defined by an
 #include statement makes for a bad day, therefore.  So, prototype all of
 the menu callback functions. :/
*/
void mcb_backlight(MenuItem* pmi);
void mcb_backlight(MenuItem* pmi){
  //
}

void mcb_retirement_year(MenuItem* pmi);
void mcb_retirement_year(MenuItem* pmi){
  //
}

void mcb_retirement_month(MenuItem* pmi);
void mcb_retirement_month(MenuItem* pmi){
  //
}

void mcb_retirement_day(MenuItem* pmi);
void mcb_retirement_day(MenuItem* pmi){
  //
}

void setup() {
  // define PWM brightness pin for output
  pinMode(PinBacklight, OUTPUT);
  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
  lcd.clear();

  // get saved data from EEPROM
  EEPROM.get(ADDR_RETIRE_TIME, retire_time);
  EEPROM.get(ADDR_BRIGHTNESS,  brightness);

  // assemble menu
  mm.add_item(&mi_backlight, &mcb_backlight);
  mm.add_menu(&mm_retirement);
  mm_retirement.add_item(&mi_retirement_year,  &mcb_retirement_year);
  mm_retirement.add_item(&mi_retirement_month, &mcb_retirement_month);
  mm_retirement.add_item(&mi_retirement_day,   &mcb_retirement_day);
}

void loop() {
  lcd_key = read_LCD_buttons();
  switch (lcd_key){
    case btnNONE: {
      break;
    }
    case btnRIGHT: {
      key = "RIGHT";
      brightness += 1;
      if( brightness >= BrightMax ){
        brightness = BrightMax;
      }
      EEPROM.update(ADDR_BRIGHTNESS, brightness);
      break;
    }
    case btnLEFT: {
      key = "LEFT";
      brightness -= 1;
      if( brightness <= BrightMin ){
        brightness = BrightMin;
      }
      EEPROM.update(ADDR_BRIGHTNESS, brightness);
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

  // assemble first LCD line
  line1 = "";
  line1 = "ADC:" + String(adc_key_in);
  while( line1.length() < 16 - key.length() ){
    line1 = line1 + " ";
  }
  line1 = line1 + key;
  lcd.setCursor(0,0);
  lcd.print(line1);

  // assemble second LCD line
  line2 = "bright:" + String(brightness);
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
