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
 set up for the RTC and other time stuff
 Libraries used are at
  http://www.pjrc.com/teensy/td_libs_Time.html
  http://www.pjrc.com/teensy/td_libs_DS1307RTC.html
 as referenced by http://playground.arduino.cc/Code/Time
*/
#include <Wire.h>
#include <DS1307RTC.h>
#include <Time.h>
#include <TimeLib.h>

#define UTC_OFFSET -6 * 60 * 60; // ignoring DTV, Central time is UTC-6 hours

// http://www.nist.gov/pml/div688/dst.cfm
bool is_dst(time_t t){
  int M = month(t);
  int D = day(t);
  int wday = weekday(t);
  // do no-math checks first for speed
  if( M > 3 && M < 11 ){
    return true;
  }
  if( M < 3 || M > 11 ){
    return false;
  }
  signed int previousSunday = D - wday;
  // DST starts at 2AM on the second Sunday of March
  if( M == 3 ){
    // Second Sunday would be between the 8th and 15th
    return previousSunday >= 7;
  }
  // DST stops at 2AM on the first Sunday of November
  if( M == 11 ){
    // first Sunday will be between the between the first and the 7th.
    return previousSunday <= 0;
  }
}

String format_time(time_t t){
  int m = minute(t);
  int s = second(t);
  return String(hourFormat12(t)) + ":"
       + (m < 10 ? "0" : "") + String(m) + ":"
       + (s < 10 ? "0" : "") + String(s)
       + " " + (isAM(t) ? "AM" : "PM");
}
String format_date(time_t t){
  return String(month(t)) + "/"
       + String(day(t)  ) + "/"
       + String(year(t) );
}
//time_t get_current_time(time_t* t){
void get_current_time(time_t* t){
  *t = now();
  *t += UTC_OFFSET; //timezone adjustment
  *t += is_dst(*t) ? 60*60 : 0; // add an hour if DST currently applies
  //return t;
}

#include "LCDInit.h"

/*
 EEPROM locations
*/
#include <EEPROM.h>
#define ADDR_RETIRE_TIME 0
time_t retire_time;
#define ADDR_BRIGHTNESS  ADDR_RETIRE_TIME + sizeof(time_t)
int brightness = BrightMax;
int retire_month = 0;
int retire_day   = 0;
int retire_year  = 0;

/*
 Menu stuff
*/
#include <MenuSystem.h>
class SmartMenuItem : public MenuItem {
public:
  SmartMenuItem(const char* name, void* (*getter)(), void* (*setter)(void*))
  : MenuItem(name)
  {
    _getter = getter;
    _setter = setter;
  }
  void* getter(){
    _getter();
  }
  void setter(void* val){
    _setter(val);
  }
protected:
  void* (*_getter)();
  void* (*_setter)(void*);
};
int exit_menu = 0;

MenuSystem ms;
Menu mm("Configuration menu");
//MenuItem mi_backlight("Backlight Brightness");
SmartMenuItem mi_backlight("Backlight Brightness", NULL, NULL);

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
  int done = 0;
  int prevbutton = btnNONE;
  wait_for_button_release();
  while(!done){
    update_lcd(
      ms.get_current_menu()->get_selected()->get_name(),
      String(brightness)
      );
    switch (prevbutton = read_LCD_buttons()){
      case btnNONE: {
        break;
      }
      case btnRIGHT: {
        more_bright();
        break;
      }
      case btnLEFT: {
        less_bright();
        break;
      }
      case btnUP: // restore without saving
      case btnDOWN: {
        restore_bright();
        ms.back();
        done = 1;
        break;
      }
      case btnSELECT: {
        //save_val(pmi);
        save_bright();
        ms.back();
        done = 1;
        break;
      }
    }
    if( prevbutton != btnNONE ){
      pause(125); // ~1/8 second
      // wait_for_button_release();
    }
  }
}

void mcb_retirement_year(MenuItem* pmi);
void mcb_retirement_year(MenuItem* pmi){
  int done = 0;
  int prevbutton = btnNONE;
  int prevyear = retire_year;
  wait_for_button_release();
  while(!done){
    update_lcd(
      ms.get_current_menu()->get_selected()->get_name(),
      String(brightness)
      );
    switch (prevbutton = read_LCD_buttons()){
      case btnNONE: {
        break;
      }
      case btnRIGHT: {
        more_bright();
        break;
      }
      case btnLEFT: {
        less_bright();
        break;
      }
      case btnUP: // restore without saving
      case btnDOWN: {
        restore_bright();
        ms.back();
        done = 1;
        break;
      }
      case btnSELECT: {
        //save_val(pmi);
        save_bright();
        ms.back();
        done = 1;
        break;
      }
    }
    if( prevbutton != btnNONE ){
      pause(500); // ~1/2 second
      // wait_for_button_release();
    }
  }
}

void mcb_retirement_month(MenuItem* pmi);
void mcb_retirement_month(MenuItem* pmi){
  //
}

void mcb_retirement_day(MenuItem* pmi);
void mcb_retirement_day(MenuItem* pmi){
  //
}

void mcb_incrementer(MenuItem* pmi);
void mcb_incrementer(MenuItem* pmi){
  int done = 0;
  int prevbutton = btnNONE;
  while(!done){
    update_lcd(
      ms.get_current_menu()->get_selected()->get_name(),
      ""
      );
    switch (prevbutton = read_LCD_buttons()){
      case btnNONE: {
        break;
      }
      case btnRIGHT: {
        break;
      }
      case btnLEFT: {
        break;
      }
      case btnUP: // up 'n down just leave without saving
      case btnDOWN: {
        //restore_val(pmi);
        done = 1;
        break;
      }
      case btnSELECT: {
        //save_val(pmi);
        done = 1;
        break;
      }
    }
    if( prevbutton != btnNONE ){
      pause(125); // ~1/8 second
      // wait_for_button_release();
    }
  }
}

void save_bright(){
  EEPROM.update(ADDR_BRIGHTNESS, brightness);
}

void restore_bright(){
  EEPROM.get(ADDR_BRIGHTNESS, brightness);
  analogWrite(PinBacklight, brightness);
}

void more_bright(){
  brightness += 1;
  if( brightness >= BrightMax ){
    brightness = BrightMax;
  }
  analogWrite(PinBacklight, brightness);
}

void less_bright(){
  brightness -= 1;
  if( brightness <= BrightMin ){
    brightness = BrightMin;
  }
  analogWrite(PinBacklight, brightness);
}

void menuLoop(){
  exit_menu = 0;
  Menu const* cm;
  // we came here due to a button press; wait for it to come back up.
  wait_for_button_release();
  int prevbutton = btnNONE;
  while(!exit_menu){
    cm = ms.get_current_menu();
    update_lcd(
      "m:" + String(cm->get_name()),
      cm->get_selected()->get_name()
      );
    switch (prevbutton = read_LCD_buttons()){
      case btnNONE: {
        break;
      }
      case btnRIGHT: {
        ms.next();
        break;
      }
      case btnLEFT: {
        ms.prev();
        break;
      }
      case btnUP: {
        if( ! ms.back() ){
          // in root menu; exit
          exit_menu = 1;
        }
        break;
      }
      case btnDOWN: {
        if( ! ms.back() ){
          // in root menu; exit
          exit_menu = 1;
        }
        break;
      }
      case btnSELECT: {
        ms.select();
        break;
      }
    }
    if( prevbutton != btnNONE ){
      wait_for_button_release();
    }
  }
}

// delay() ties the processor up. This should mostly avoid that.
void pause(unsigned long d){
  unsigned long start_milli = millis();
  while( millis() - start_milli < d ){
    // nothin'  
  }
}

void update_display(){
  time_t t;
  String line1;
  String line2;
  get_current_time(&t);
  // assemble first LCD line
  line1 = format_date(t);

  // assemble second LCD line
  line2 = format_time(t);
  while( line2.length() < lcd_cols){
    line2 = line2 + " ";
  }

  update_lcd(line1, line2);
}

#include "RetirementDisplay.h"
RetirementDisplay* rd = new RetirementDisplay(&update_lcd);

RetirementScreen* rs = new RetirementScreen(
  []()->String{return "a";},
  []()->String{return "b";}
  );

//d->add(rs);
//d.update();


void setup() {
  // get saved data from EEPROM
  EEPROM.get(ADDR_RETIRE_TIME, retire_time);
  EEPROM.get(ADDR_BRIGHTNESS,  brightness);

  // define PWM brightness pin for output
  pinMode(PinBacklight, OUTPUT);
  // set up the LCD's number of columns and rows:
  lcd.begin(lcd_cols, lcd_rows);
  lcd.clear();
  analogWrite(PinBacklight, brightness);

  // configure clock to use RTC
  tmElements_t tm;
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
  ms.set_root_menu(&mm);

  /* casting pointers to integers makes me sad, but templates are ugly */
  //mi_backlight.set_value((int)&brightness);
  //mi_backlight.getter();
  //mi_backlight.setter(NULL);
}

void loop() {
  // check on the keys
  switch (read_LCD_buttons()){
    case btnNONE: {
      break;
    }
    case btnRIGHT: {
      // cycle through screens
      break;
    }
    case btnLEFT: {
      // cycle through screens
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
  update_display();
}
