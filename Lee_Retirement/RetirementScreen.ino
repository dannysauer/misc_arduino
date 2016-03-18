RetirementScreen::RetirementScreen( String(*L1f)(), String(*L2f)()){
  get_line_1 = L1f;
  get_line_2 = L2f;
}


void RetirementScreen::set_next(RetirementScreen* s){
  next_scr = s;
}

void RetirementScreen::set_prev(RetirementScreen*s){
  prev_scr = s;
}

RetirementScreen* RetirementScreen::get_next(){
  return next_scr;
}

RetirementScreen* RetirementScreen::get_prev(){
  return prev_scr;
}
