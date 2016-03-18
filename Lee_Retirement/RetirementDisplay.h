/*
 * container for linked list of countdown displays
 */
#ifndef RetirementDisplay_h
#define RetirementDisplay_h

#include "RetirementScreen.h"
class RetirementDisplay {
protected:
  RetirementScreen* head;
  RetirementScreen* current;
  void (*updater)(String, String);
public:
  RetirementDisplay( void(*)(String,String) );
  void add_screen(RetirementScreen*);
  void update();
  void next();
  void prev();
};

#endif
