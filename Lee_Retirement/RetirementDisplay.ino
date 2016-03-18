/*
 * actual countdown displays
 */
RetirementDisplay::RetirementDisplay(void (*method)(String,String)){
  updater = method;
}

void RetirementDisplay::next(){
  current = current->get_next();
  update();
}
void RetirementDisplay::prev(){
  current = current->get_prev();
  update();
}

void RetirementDisplay::update(){
  updater( current->get_line_1(), current->get_line_2() );
}

void RetirementDisplay::add_screen(RetirementScreen* s){
  if( s->get_next() == NULL ){
    // first entry in list
    s->set_next(s);
    s->set_prev(s);
  }
  else{
    // Insert after head->previous, which should be the end
    RetirementScreen* endscreen = head->get_prev();
    endscreen->set_next(s);
    s->set_prev(endscreen);
    s->set_next(head);
  }
}

