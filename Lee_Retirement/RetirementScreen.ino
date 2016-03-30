String return_millis(){
  return( "a" + String( millis() ) );
}

RetirementScreen::RetirementScreen( String(*L1f)(), String(*L2f)()){
  _get_line_1 = L1f;
  _get_line_2 = L2f;
  //_get_line_1 = &return_millis;
  //_get_line_2 = &return_millis;
}

String RetirementScreen::get_line_1(){
  if( _get_line_1 != NULL ) {
    return( _get_line_1() );
  }
  return( "line1" );
}
String RetirementScreen::get_line_2(){
  if( _get_line_2 != NULL ) {
    return( _get_line_2() );
  }
  return( "line2" );
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
