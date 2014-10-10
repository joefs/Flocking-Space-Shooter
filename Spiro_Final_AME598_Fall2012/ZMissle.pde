class ZMissle extends ZAgent {
  
  ZMissle() {
  }

  ZMissle(float x, float y, PVector vec) {
    super(x, y);
    arrivalDestination = vec;
    arrival_state = true;
    neutral_state = false;
    wide = 10;
    age = 0;
    lifetime = (int)frameRate * 4;
  }

  void process() {
    if (arrival_state) {
      PVector arrival_force = arrival( arrivalDestination, 15 );
      acceleration.add( arrival_force );
//      ellipse(location.x, location.y,3,3);
//      ellipse(arrivalDestination.x, arrivalDestination.y,3,3);
    }
    else if (neutral_state) {
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
    //
    //
    //
    for (int i = 0; i < harmfuls.size(); i++) {
      realdColAndMaybeDie(harmfuls.get(i));
    }
    for (int i = 0; i < enemies.size(); i++) {
      realdColAndMaybeDie(enemies.get(i));
    }
    age++;
    if (age > lifetime || arrived) {
      thanatos = true;
      WHarmful expl2 = new WHarmful( location.x, location.y, 'e');
      gameObjs.add(expl2);
    }
  }

  void render() {
    pushMatrix();
    translate( location.x, location.y );
    rotate( orientation );
    stroke( 255);
    strokeWeight( 1 );
    fill( 0 );
    rectMode(CORNERS);
    triangle(-5, -4, -1, -4, -5, -6);
    triangle(-5, 4, -1, 4, -5, 6);
    rect(-5, -4, 3, 4);
    ellipse(3, 0, 10, 10);
    popMatrix();
  }

  void realdColAndMaybeDie(AGameObj crashVic) {
    if (colided(crashVic)) {
      thanatos = true;
      WHarmful expl2 = new WHarmful( location.x, location.y, 'e');
      gameObjs.add(expl2);
      if (crashVic instanceof ZEnemy) {
        crashVic.thanatos = true;
        enemiesKilled++;
        //
        score+= scoreCalc( (ZEnemy) crashVic);
        //
        int searInd = arLiSearch(crashVic, enemies);
        if (searInd >= 0) {
          if (enemies != null) {
            enemies.remove(searInd);
          }
        }
      }
    }
  }
}

