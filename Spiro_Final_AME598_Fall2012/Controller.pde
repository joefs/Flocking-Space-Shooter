class Controller {
  int scone;
  long ourFrameC;
  long prevFC;
  long curFC;
  Controller() {
    scone = 0;
    ourFrameC = 0;
    prevFC = frameCount;
    curFC = prevFC;
  }

  void run() {
    prevFC = curFC;
    curFC = frameCount;
    if (curFC - prevFC >= 1) {
      ourFrameC++;
    }
    ourFrameC++; // use this so it only changes when not paused
    if (agent != null && ourFrameC > (frameRate * 3)) { // to create a delayed beginning
      int uu = (int)ourFrameC%(int)((frameRate * 4)- (2*scone));
      if (uu == 1 || uu == (int)frameRate/2 || uu == (int)frameRate-1) {
        spawn();
      }
      int uy = (int)ourFrameC%(int)(frameRate * 10);
      if (uy == 0) {
        scone++;
      }
    }
    if ((enemiesKilled == 20 && level < 2)||(enemiesKilled == 50 && level < 3)||(enemiesKilled == 80 && level < 4) ) {//change it to update mode
//    if ((enemiesKilled == 2 && level < 2)||(enemiesKilled == 5 && level < 3)||(enemiesKilled == 10 && level < 4) ) {// the test version
      titleScreen = false;
      gamePlay = false;
      update = true;
      gameOver = false;
    }
  }

  void spawn() {
    PVector trex;
    if (agent != null) {    
      trex = agent.location;
    }
    else {
      trex = new PVector(mouseX, mouseY);
    }
    float seed = random(100) + scone;
    PVector locco = randStartPoint();
    if ( seed > 95 && level > 3) {
      enemy = new ZEnemy( locco.x, locco.y, trex, 's');
      enemy.max_force = 0.3;
      enemy.max_speed = 6.0;
      enemy.avoid_max_distance = 30;
    }
    else if (seed > 70 && level > 2) {
      enemy = new ZEnemy( locco.x, locco.y, trex, 'm');
      enemy.max_force = 0.3;
      enemy.max_speed = 6.0;
    }
    else {
      enemy = new ZEnemy( locco.x, locco.y, trex, 'd');
    }


    gameObjs.add(enemy);
    enemies.add(enemy);
  }
}

