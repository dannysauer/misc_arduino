/*
 * actual countdown displays
 */
RetirementDisplay::RetirementDisplay(void (*m)(String,String)){
  updater = m;
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
  //update_display();
  updater( current->get_line_1(), current->get_line_2() );
}

void RetirementDisplay::add_screen(RetirementScreen* s){
  if( head == NULL ){
    // first entry in list
    s->set_next(s);
    s->set_prev(s);
    head = s;
    current = s;
  }
  else{
    // Insert after head->previous, which should be the end
    RetirementScreen* endscreen = head->get_prev();
    head->set_prev(s);
    endscreen->set_next(s);
    s->set_next(head);
    s->set_prev(endscreen);
  }
}

