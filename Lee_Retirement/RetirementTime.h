/*
 * retirement time wrapper
 * Basically wrap time calls so EEPROM gets auto-updated
 */
#ifndef RetirementTime_h
#define RetirementTime_h

// should be included, but duplication is ok
#include <Time.h>
#include <TimeLib.h>
#include <EEPROM.h>

class RetirementTime{
private:
  int eeprom_location;
  time_t r_t;
public:
  RetirementTime(int);
  int get_minute();
  void set_minute(int);
  int get_month();
  void set_month(int);
};

#endif
