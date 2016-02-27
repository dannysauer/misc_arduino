/*
 * Lee's retirement countdown clock
 * Initialize EEPROM (hard-coded) and clock (reading from serial)
 * 
 * To set the clock, figure out what serial port your device is on.  If
 * you're in the Arduino IDE, the port should be in the tools dropdown.
 * Assuming you're on Linux, there's a good chance it's /dev/ttyACM0.
 * Then you can set the clock by running this:
 *  date -u +'T%s' | tee /dev/ttyACM0 
 * Or just get the current time from your clock and paste it into the console
 * using the format above, which is "T" then "seconds since Jan 1 1970 UTC"
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
#define UTC_OFFSET -6 * 60 * 60; // offset from UTC in seconds, ignoring DST

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

void setup() {
  // define PWM brightness pin for output
  pinMode(PinBacklight, OUTPUT);
  // set up the LCD's number of columns and rows:
  lcd.begin(16, 2);
  lcd.clear();
  analogWrite(PinBacklight, brightness);

  // set the EEPROM values (update to avoid uneccesary writes)
  EEPROM.update(ADDR_BRIGHTNESS, brightness);
  // April 1, 2016?  This should be *local* time, even though the clock uses UTC
  tmElements_t t;
  t.Second = 0;
  t.Minute = 0;
  t.Hour = 0;
  t.Day = 1;
  t.Month = 4;
  t.Year = 116;
  EEPROM.update(ADDR_RETIRE_TIME, makeTime(t));

  // get saved data from EEPROM
  EEPROM.get(ADDR_RETIRE_TIME, retire_time);
  EEPROM.get(ADDR_BRIGHTNESS,  brightness);

  // use RTC once it works
  setSyncProvider(RTC.get);

  Serial.begin(9600);
}

// USA DST conversion only, per http://www.nist.gov/pml/div688/dst.cfm
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

int syntime = -5 * 1000;
// lifted pretty much straight from TimeSerial example
void handle_sync(){
  unsigned long inputtime;
  if( Serial.find('T') ){
    inputtime = Serial.parseInt();
    if( inputtime > 0 ){
      syntime = millis();
      //setTime(inputtime);
      RTC.set(inputtime);
    }
  }
}

void loop() {
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
      break;
    }
  }

  if( Serial.available() ){
    handle_sync();
  }
  
  if( timeStatus() == timeNotSet ){
    update_lcd("Time not set", "");
  }
  else{
    time_t t = now();
    t += UTC_OFFSET; // adjust for TZ
    
    line1 = "";
    if( syntime > 0 && millis() - syntime < 5000 ){
      line1 = "Sync!";
    }
    line1 += String(hourFormat12(t)) + ":"
          + String(minute(t) < 10 ? "0" + String(minute(t)) : minute(t)) + ":"
          + String(second(t) < 10 ? "0" + String(second(t)) : second(t))
          + " " + (isAM(t) ? "AM" : "PM");
    while( line1.length() < 16 ){
      line1 += " ";
    }
  
    // assemble second LCD line
    while( line2.length() < 16){
      line2 = line2 + " ";
    }
  
    update_lcd(line1, line2);
  }
}
