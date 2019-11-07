RetirementTime::RetirementTime(int loc){
  eeprom_location = loc;
  EEPROM.get(eeprom_location, r_t);
}

int RetirementTime::get_minute(){
  return minute(r_t);
}
void RetirementTime::set_minute(int m){
  return;
}
int RetirementTime::get_month(){
  return month(r_t);
}
void RetirementTime::set_month(int m){
  return;
}
