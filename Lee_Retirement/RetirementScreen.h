/*
 * actual countdown displays
 */
#ifndef RetirementScreen_h
#define RetirementScreen_h

class RetirementScreen {
private:
  RetirementScreen* next_scr = NULL;
  RetirementScreen* prev_scr = NULL;
public:
  RetirementScreen( String(*)(), String(*)());
  void set_next(RetirementScreen* s);
  void set_prev(RetirementScreen*s);
  RetirementScreen* get_next();
  RetirementScreen* get_prev();
  String (*get_line_1)();
  String (*get_line_2)();
};

#endif
