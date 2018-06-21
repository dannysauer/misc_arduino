/*
 Set up for the LCD
*/
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

void wait_for_button_release(){
  // after reading a button, wait until we see no buttons
  while( read_LCD_buttons() != btnNONE ){
    pause(10);
  }
  // then wait 20ms and see if it's still at none
  pause(20);
  while( read_LCD_buttons() != btnNONE ){
    pause(10);
  }
}

void pad( String* s ){
  while( s->length() < lcd_cols ){
    *s += " ";
  }
}

String pad( String s ){
  while( s.length() < lcd_cols ){
    s += " ";
  }
  return s;
}

void center( String* s ){
  for(int indent = ((float)lcd_cols / 2.0) - ((float)s->length() / 2.0); indent > 0; indent--){
    *s = " " + *s;
  }
}

String center( String s ){
  for(int indent = ((float)lcd_cols / 2.0) - ((float)s.length() / 2.0); indent > 0; indent--){
    s = " " + s;
  }
  return s;
}

// only update LCD if intended display != what's already displayed
String prevline1 = "";
String prevline2 = "";
void update_lcd(String L1, String L2){
  pad(&L1);
  pad(&L2);
  if( L1 != prevline1 ){
    lcd.setCursor(0,0);
    lcd.print(L1);
    prevline1 = L1;
  }
  if( L2 != prevline2 ){
    lcd.setCursor(0,1);
    lcd.print(L2);
    prevline2 = L2;
  }
}

