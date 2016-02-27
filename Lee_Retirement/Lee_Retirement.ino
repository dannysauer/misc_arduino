/*
 * Lee's retirement countdown clock
 *
 * I'm using a SainSmart LCD shield with an Uno, and a DS1370 RTC to make it accurate
 *
 * Links to the Amazon items I used:
 * http://www.amazon.com/gp/product/B0076FWAH8
 * http://www.amazon.com/gp/product/B00LZCTMJM
 */

//#include <Chronos.h>

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
  //EEPROM.update(ADDR_BRIGHTNESS, brightness);
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
  // get saved data from EEPROM
  EEPROM.get(ADDR_RETIRE_TIME, retire_time);
  EEPROM.get(ADDR_BRIGHTNESS,  brightness);

  // define PWM brightness pin for output
  pinMode(PinBacklight, OUTPUT);
  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
  lcd.clear();
  analogWrite(PinBacklight, brightness);

  // configure clock to use RTC
  if(! RTC.read(tm)){
    // RTC isn't working
    while(true){
      update_lcd("RTC read error :/", String(millis()/1000));
      delay(250);
    }
  }
  setSyncProvider(RTC.get);
  if(timeStatus() != timeSet){
    // RTC isn't set
    while(true){
      update_lcd("Time is not set :/", String(millis()/1000));
      delay(250);
    }
  }

  // assemble menu
  mm.add_item(&mi_backlight, &mcb_backlight);
  mm.add_menu(&mm_retirement);
  mm_retirement.add_item(&mi_retirement_year,  &mcb_retirement_year);
  mm_retirement.add_item(&mi_retirement_month, &mcb_retirement_month);
  mm_retirement.add_item(&mi_retirement_day,   &mcb_retirement_day);
}

// http://www.nist.gov/pml/div688/dst.cfm
bool in_dst(){
  // do no-math checks first for speed
  if( tm.Month > 3 && tm.Month < 11 ){
    return true;
  }
  if( tm.Month < 3 || tm.Month > 11 ){
    return false;
  }
  signed int previousSunday = tm.Day - tm.Wday;
  // DST starts at 2AM on the second Sunday of March
  if( tm.Month == 3 ){
    // Second Sunday would be between the 8th and 15th
    return previousSunday >= 8;
  }
  // DST stops at 2AM on the first Sunday of November
  if( tm.Month == 11 ){
    // first Sunday will be between the between the first and the 7th.
    return previousSunday <= 0;
  }
}

void more_bright(){
  if( brightness >= BrightMax ){
    brightness = BrightMax;
  }
  analogWrite(PinBacklight, brightness);
}

void less_bright(){
  if( brightness >= BrightMax ){
    brightness = BrightMax;
  }
  analogWrite(PinBacklight, brightness);
}

// only update LCD if intended display != what's already displayed
String prevline1 = "";
String prevline2 = "";
void update_lcd(String l1, String l2){
  if( l1 != prevline1 ){
    lcd.setCursor(0,0);
    lcd.print(l1);
    prevline1 = l1;
  }
  if( l2 != prevline2 ){
    lcd.setCursor(0,1);
    lcd.print(l2);
    prevline2 = l2;
  }
}

void menuLoop(){
  return;  
}

void loop() {
  // if the RTC isn't working, the rest of this doesn't matter
  if(RTC.read(tm)){
  }
  else{
    update_lcd("RTC read error :/", String(millis()/1000));
  }

  // check on the keys
  lcd_key = read_LCD_buttons();
  switch (lcd_key){
    case btnNONE: {
      break;
    }
    case btnRIGHT: {
      break;
    }
    case btnLEFT: {
      break;
    }
    case btnUP: {
      break;
    }
    case btnDOWN: {
      break;
    }
    case btnSELECT: {
      menuLoop();
      break;
    }
  }

  // assemble first LCD line
  line1 = "ADC:" + String(adc_key_in);
  while( line1.length() < 16 ){
    line1 = line1 + " ";
  }

  // assemble second LCD line
  line2 = "bright:" + String(brightness);
  while( line2.length() < 16){
    line2 = line2 + " ";
  }

  update_lcd(line1, line2);
}
