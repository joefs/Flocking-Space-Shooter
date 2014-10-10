class WHarmful extends AGameObj{
  char state; // b for barrier, e for explosion  
  WHarmful(){
  }
  
  WHarmful(float x, float y, char staCh) {
    super(x,y);
    wide = 32;
    age = 0;
    state = staCh;
    lifetime = (int)frameRate * 2;
  }
  void process(){
    if(state == 'e'){
        age++;
        if(age > lifetime){
          thanatos = true;
        }
    }
  }
  
  void render(){
    if(state == 'b'){
      stroke(255);
      fill(0);
      ellipse(location.x, location.y, wide, wide);
    }else if(state == 'e'){
      fill(255,61,13);
      ellipse(location.x, location.y, random(wide), random(wide));
    }
  }
  

}
