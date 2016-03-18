/*
 Set up for the LCD
*/
#ifndef LCDInit_h
#define LCDInit_h

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

#define lcd_cols  16
#define lcd_rows  2
// define some values used by the panel and buttons
int lcd_key     = 0;
int adc_key_in  = 0;
#define btnRIGHT  0
#define btnUP     1
#define btnDOWN   2
#define btnLEFT   3
#define btnSELECT 4
#define btnNONE   5

#define BrightMax 255
#define BrightMin 0

// read the buttons
int read_LCD_buttons();
void wait_for_button_release();
void pad( String* s );
void update_lcd(String L1, String L2);

#endif
