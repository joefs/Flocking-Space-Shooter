import ddf.minim.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
//
//
//
Minim minim1;
AudioPlayer groove1;
Minim minim2;
AudioPlayer groove2;
//
//
//
ZPlayer agent;
ZMissle missle;
ZEnemy enemy;
WHarmful explosion;
WHarmful bar;
ArrayList<AGameObj> gameObjs;
ArrayList<WHarmful> harmfuls;
ArrayList<ZEnemy> enemies;
Controller cont;
boolean alive;
int level;
long score;
int lives;
int enemiesKilled;
// Beside each is the method that the boolean will "rule over" the d stands for both "Display"
//and "Do" as they will only update their respetive states and variables when "running"
boolean titleScreen; // DtitleScreen
boolean gamePlay; // DgamePlay
boolean update; // no display
boolean gameOver; //  DgameOver
float lastMult;


void setup() {
  minim1 = new Minim(this);
  minim2 = new Minim(this);
  lastMult = 0;
  size( 600, 600 );
  smooth();
  gameObjs = new ArrayList();
  harmfuls = new ArrayList();
  enemies = new ArrayList();
  cont = new Controller();
  titleScreen = true;
  gamePlay = false;
  update = false;
  gameOver = false;
  groove1 = minim1.loadFile("CruelAngel.MP3", 512);
  groove1.loop();
  groove2 = minim2.loadFile("anotherThanatos.MP3", 512);
}

void draw() {
  background( 0 );
  strokeWeight(1);
  //
  if (titleScreen) {
    DtitleScreen();
  }
  else if (gamePlay) {
    DgamePlay();
  }
  else if ( update) {
    changeLevel(level);
  }
  else if (gameOver) {
    DgameOver();
  }
  //
}


void mousePressed() {
  if (agent != null) {
    if (mouseButton == LEFT) {
      agent.arrival_state = true;
      agent.neutral_state = false;
      agent.arrivalDestination = new PVector(mouseX, mouseY);
    }
    else if (mouseButton == RIGHT) {
      PVector trex = new PVector(mouseX, mouseY);
      agent.fire(trex);
    }
  }
}

void keyPressed() {
  if ((key == 'r' || key == 'R')&&(alive == false)&& (gamePlay == true)) {
    agent = new ZPlayer( width/2, height/2);
    gameObjs.add(agent);
    alive = true;
    AGameObj tryoer;
    // The following is so that once you revive you are not swamped. Clears the field of enemies.
    for ( int hy = 0; hy < enemies.size(); hy++) {
      tryoer = enemies.get(hy);
      if (tryoer != null) {
        tryoer.thanatos = true; // to have the main arraylist auto garbage collect
      }
    }
    enemies.clear(); // to nuke the secondary list and avoid a memory leak
  }
  if ((key == 's' || key == 'S')&&(alive == false)) {
    if ( titleScreen || gameOver) {
      startGame();
    }
  }
}

boolean kill(AGameObj objeto) {
  if (objeto.thanatos) {
    return true;
  }
  return false;
}

int arLiSearch(AGameObj key1, ArrayList field) {
  if (field != null) {
    int k = 0;
    boolean notfound = true;
    while ( (k < field.size ())&& notfound) {
      if (field.get(k) == key1) {
        notfound = false;
      }
      k++;
    }
    if (notfound) {
      return -3;
    }
    return k  - 1;
  }
  return -3;
}


PVector randStartPoint() {
  PVector out;
  int yy = (int)random(0, 4) + 1;
  int newX, newY;
  switch (yy) {
  case 0:  
    out = new PVector(0, random(height));
    break;
  case 1:
    out = new PVector(random(width), 0);
    break;
  case 2:  
    out = new PVector(width, random(height));
    break;
  case 3:  
    out = new PVector(random(width), height);
    break;
  default:
    out = new PVector(0, 0);
    break;
  }
  return out;
}

void crossHair() {
  noFill();
  strokeWeight(5);
  stroke(255, 255, 0, 128);
  ellipse(mouseX, mouseY, 40, 40);
  if (agent != null && agent.canHead != null) {
    strokeWeight(1);
    stroke(255, 255, 255, 128);
    line(agent.canHead.x, agent.canHead.y, mouseX, mouseY);
  }
}


/*
to do list -
 Above.
 Third level of enemy.
 */

void startGame() {
  lives = 3;
  titleScreen = false;
  gamePlay = true;
  update = false;
  gameOver = false;
  level = 1;
  score = 0;
  enemiesKilled = 0;
  gameObjs.clear();
  harmfuls.clear();
  enemies.clear();
  agent = new ZPlayer( width/2, height/2);
  gameObjs.add(agent);
  //
  level1();
  //
  alive = true;
    if(groove2.isPlaying()){
    groove2.pause();
  }
  if (!groove1.isPlaying()) {
    groove1.loop();
  }
}


void DgamePlay() {
  for (int i = 0; i < gameObjs.size(); i++) {
    AGameObj obj = gameObjs.get(i);
    if (obj != null) {
      obj.process();
      obj.render();
      if (kill(obj)) {
        if (obj == agent) {
          alive = false;
          obj = null;
          agent = null;
        }
        gameObjs.remove(i);
        i--;
      }
    }
  }
  scoreBoard();
  cont.run();
  crossHair();
  Omedeto();
}

void DtitleScreen() {
  //
  BackTriang();
  //
  int lantern = frameCount % 7;
  int lantern2 = frameCount % 40;
  pushMatrix();
  translate(width/2 - 20, height/2);
  pushMatrix();
  scale(4, 10);
  textSize(32);
  fill(6, 250, 55);
  if ( lantern == 0 || lantern2 > 33 || frameCount > (frameRate * 4)) {
    text("Sephirot", -70, 10);
  }
  popMatrix();
  fill(255);
  text("To quarter up press 'S'", -100, 140);
  popMatrix();
}

void BackTriang() {
  strokeWeight(5);
  stroke( 255, 160, 0);
  fill(255, 20, 0);
  triangle(width/6, height/6, width * 5/6, height/6, width/6, height * 5 /6);
  strokeWeight(3);
  fill(0);
  triangle(width/2, height/6, width /2, height/2, width/6, height /2);
}

boolean chck4GameOva() {
  if (lives < 0) {
    return true;
  }
  return false;
}

void Omedeto() {
  // http://youtu.be/UGNL6zGmHec
  if (chck4GameOva()) {
    titleScreen = false;
    gamePlay = false;
    update = false;
    gameOver = true;
    groove1.pause();
    groove2.loop();
  }
}

void DgameOver() {
  String OverFiend = "GAME";
  String OverFiend2 = "OVER";
  String OverFiend3 = "Press 'S' to rejoin the fight!";
  pushMatrix();
  translate(width/2 - 20, height/2);
  scale(4, 4);
  textSize(32);
  fill(6, 250, 55);
  text(OverFiend, -70, 10);
  fill(255, 20, 0);
  text(OverFiend2, -10, 20);
  popMatrix();
  fill( 194, 23, 213 );
  text(OverFiend3, 130, 410);
  fill( 255);
  text("Score: " + score, 100, height/3);
}

void scoreBoard() {
  fill(255);
  text("Mans: " + lives, 10, 30);
  text("Score: " + score, 150, 30);
  text("Level: " + level, 400, height - 30);
  text("Bonus Mult : " + lastMult, 0, height - 30);
}



void changeLevel(int l) {
  level = l + 1;
  gameObjs.clear();
  harmfuls.clear();
  enemies.clear();
  agent = new ZPlayer( width/2, height/2);
  gameObjs.add(agent);
  //
  if (level == 2) {
    level2();
  } 
  else if (level == 3) {
    level3();
  }
  else {
    levelEternal();
  }
  //
  alive = true;
  //
  titleScreen = false;
  gamePlay = true;
  update = false;
  gameOver = false;
}

void level1() {
  PVector cent = new PVector(width/2, height/2);
  float sep = TWO_PI/12;
  PVector handOfDial;
  float radia = 200;//radius of the circle
  for ( int radio = 0; radio < 12 ; radio++) {
    handOfDial = new PVector( cent.x + radia * cos(radio * sep), cent.y + radia * sin(radio * sep));
    bar = new WHarmful( handOfDial.x, handOfDial.y, 'b');
    gameObjs.add(bar);
    harmfuls.add(bar);
  }
}

void level2() {
  bar = new WHarmful( width*2/3, height*2/3, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
  bar = new WHarmful( width/3, height/3, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
  bar = new WHarmful( width/3, height*2/3, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
  bar = new WHarmful( width*2/3, height/3, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
  bar = new WHarmful( width/2, height/6, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
  bar = new WHarmful( width*5/6, height/2, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
  bar = new WHarmful( width/2, height*5/6, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
  bar = new WHarmful( width/6, height/2, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
}

void level3() {
  PVector cent = new PVector(width/2, height/2);
  float sep = TWO_PI/12;
  PVector handOfDial;
  float radia = 100;//radius of the circle
  for ( int radio = 0; radio < 20 ; radio++) {
    radia+=10;
    handOfDial = new PVector( cent.x + radia * cos(radio * sep), cent.y + radia * sin(radio * sep));
    bar = new WHarmful( handOfDial.x, handOfDial.y, 'b');
    gameObjs.add(bar);
    harmfuls.add(bar);
  }
}

void levelEternal() {
  bar = new WHarmful( width*2/3, height/2, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
  bar = new WHarmful( width/3, height/2, 'b');
  gameObjs.add(bar);
  harmfuls.add(bar);
  float sep = TWO_PI/12;
  PVector handOfDial;
  float radia = 150;
  PVector cent = new PVector(width/2, 0);
  for ( int radio = 0; radio < 12 ; radio++) {
    handOfDial = new PVector( cent.x + radia * cos(radio * sep), cent.y + radia * sin(radio * sep));
    bar = new WHarmful( handOfDial.x, handOfDial.y, 'b');
    gameObjs.add(bar);
    harmfuls.add(bar);
  }
  cent = new PVector(width/2, height);
  for ( int radio = 0; radio < 12 ; radio++) {
    handOfDial = new PVector( cent.x + radia * cos(radio * sep), cent.y + radia * sin(radio * sep));
    bar = new WHarmful( handOfDial.x, handOfDial.y, 'b');
    gameObjs.add(bar);
    harmfuls.add(bar);
  }
}

void returnToTheFray() {
  if (update) {
  }
}

float scoreCalc(ZEnemy subject) {
  float sum = 0;

  if ( agent != null) {
    //
    sum += (.333 *(float)lives/3);
    //
    sum += ((agent.velocity.mag()/agent.max_speed) + (subject.velocity.mag()/subject.max_speed)) * .333 /2;
    //
    PVector normA = new PVector(agent.velocity.x, agent.velocity.y);
    normA.normalize();
    PVector normS = new PVector(subject.velocity.x, subject.velocity.y);
    normS.normalize();
    float facing = ((-1 * normA.dot(normS)) + 1)/2;
    sum += .333 * facing;
    //
    sum = min(sum, 1);
    //
    sum *= (float)level/2;
  }
  lastMult = sum * 10 ;
  if (subject.intel == 's') {
    return 500 * sum;
  }
  else if (subject.intel == 'm') {
    return 300 * sum;
  }
  else {
    return 100 * sum;
  }
}


void stop() {
  groove1.close();
  groove2.close();
  minim1.stop();
  minim2.stop();  
  super.stop();
}

