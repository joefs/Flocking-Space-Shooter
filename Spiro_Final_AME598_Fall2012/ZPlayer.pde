class ZPlayer extends ZAgent {
  float canLength;
  float canOrient;
  PVector canHead;

  ZPlayer() {
  }

  ZPlayer(float x, float y) {
    super(x, y);
    wide = 16;
    canOrient = 0;
    canLength = 16;
    canHead = new PVector(0, 0);
    wide = 28;
    max_turn_rate = TWO_PI / 5.0;
  }

  void process() {
    prevLocation.x = location.x;
    prevLocation.y = location.y;

    if (arrival_state) {
      PVector arrival_force = arrival( arrivalDestination, 10 );
      acceleration.add( arrival_force );
    } 
    else if (wander_state) {
      PVector wander_force = wander( 50, 500);
      acceleration.add( wander_force );
    }
    else if (neutral_state) {
    }
    else if (run_state) {
      PVector run_force = pursuit( target);
      acceleration.add( PVector.mult(run_force, -1) );
    }

    acceleration.div( mass );
    acceleration.limit( max_force );

    velocity.add( acceleration );
    velocity.limit( max_speed );

    if (velocity.mag() > 0.01) {
      orientation = velocity.heading2D();
    }

    location.add( velocity );
    wrap();

    acceleration.x = 0;
    acceleration.y = 0;

    //Updating the cannons thing
    PVector canLoc = new PVector( location.x -(8 * cos(orientation)), location.y - (8 * sin(orientation)));
    PVector mouseLoc = new PVector(mouseX, mouseY);
    PVector cue = PVector.sub(canLoc, mouseLoc);
    canOrient = (PVector.mult( cue, -1.0)).heading2D();
    stroke(255);
    //line(canLoc.x, -20, canLoc.x, 3000);
    //line(-20, canLoc.y, 3000, canLoc.y );
    PVector canLengthCue = new PVector(cue.x, cue.y);
    canLengthCue.normalize();
    canLengthCue.mult(canLength);
    canHead = PVector.sub(canLoc, canLengthCue);
    //
    for (int i = 0; i < harmfuls.size(); i++) {
      realdColAndMaybeDie(harmfuls.get(i));
    }
    for (int i = 0; i < enemies.size(); i++) {
      realdColAndMaybeDie(enemies.get(i));
    }
  }


  void render() {
    pushMatrix();
    translate( location.x, location.y );
    rotate( orientation );
    strokeWeight( 1 );
    fill( 194, 23, 213 );
    stroke(0);
    rectMode(CORNERS);
    rect(-16, 8, 0, -8);
    triangle(0, -8, 16, -4, 0, 0);
    triangle(0, 0, 16, 4, 0, 8);   
    pushMatrix();
    translate( -8, 0);
    rotate( canOrient - orientation); //gets rid of the artifact
    fill(6,250,55);
    rect(0, 2, canLength, -2);
    popMatrix();   
    popMatrix();
  }


  void fire(PVector targ) {
    missle = new ZMissle(canHead.x, canHead.y, targ);
    missle.velocity.normalize();
    missle.velocity.mult(missle.max_speed);
    gameObjs.add(missle);
    missle.velocity = PVector.add(missle.velocity, velocity);
    missle.max_speed *=2;
    missle.max_force *=2;
  }

  void realdColAndMaybeDie(AGameObj crashVic) {
    if (colided(crashVic)) {
      thanatos = true;
      WHarmful expl2 = new WHarmful( location.x, location.y, 'e');
      gameObjs.add(expl2);
      //
      lives--;
      //
    }
  }
}

