class ZEnemy extends ZAgent {
  char intel;
  float avoid_max_distance;
  float closest_distance;
  PVector closest_intersect;
  boolean lockedOnto;

  ZEnemy() {
  }

  ZEnemy(float x, float y, PVector vec, char newchar) {
    super(x, y);
    arrivalDestination = vec;
    arrival_state = true;
    neutral_state = false;
    max_force = 0.3;
    max_speed = 1.0;
    wide = 12;
    intel = newchar;
    avoid_max_distance = 150.0;
    lockedOnto = false;
  }


  void process() {
    prevLocation.x = location.x;
    prevLocation.y = location.y;
    PVector avoid_force = new PVector(0, 0);
    if (intel == 'd') {
    }
    else if (intel == 'm') {
      avoid_force = avoid();
      acceleration.add( avoid_force );
    }

    if (avoid_force.mag() < .05) {
      if (velocity.mag() <.1 && agent != null) {
        arrivalDestination = agent.location;
      }

      if (arrival_state) {
        PVector arrival_force;
        if (intel == 's') {
          PVector diff = PVector.sub(location, arrivalDestination);
          diff.mult(-1.5);
          PVector newDestiny = PVector.add(diff, location);
          arrival_force = arrival( newDestiny, 5 );
        }
        else {
          arrival_force = arrival( arrivalDestination, 5 );
        }
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
    for (int i = 0; i < harmfuls.size(); i++) {
      realdColAndMaybeDie(harmfuls.get(i));
    }
  }

  void render() {
    pushMatrix();
    translate( location.x, location.y );
    rotate( orientation );    
    strokeWeight( 1 );
    if ( intel == 's') {
      //stroke(255);
      //fill(255);
      rotate( -orientation ); //to have them remain in the same direction
      noStroke();
      fill(255, 20, 0);
      ellipse(0, 0, 32, 16);
      fill(random(255), random(255), random(255));
      ellipse(0, 0, 16, 16);
      fill(0);
      ellipse(0, 0, 8, 16);
    }
    else if ( intel == 'd') {
      //stroke(255);
      //fill(255);
      noStroke();
      fill(6, 250, 55);
      beginShape();
      vertex(-6, 0);
      vertex(2, -1);
      vertex(-3, -5);
      vertex(6, -2);
      vertex(4, -1);
      vertex(4, 1);
      vertex(6, 2);
      vertex(-3, 5);
      vertex(2, 1);
      endShape(CLOSE);
    }
    else if ( intel == 'm') {
      float percento = 300/velocity.mag();
      float flap = sin(TWO_PI*((float)frameCount%percento)/percento);
      scale(1, flap);
      stroke(255, 0, 0);
      fill(0, 255, 255);
      beginShape();
      vertex(-3, -3);
      vertex(-5, -6);
      vertex(3, -3);
      vertex(1, -1);
      vertex(-3, 4);
      vertex(-5, 6);
      vertex(3, 4);
      vertex(-1, -1);
      endShape(CLOSE);
    }
    popMatrix();
  }
  //

  void realdColAndMaybeDie(AGameObj crashVic) {
    if (colided(crashVic)) {
      thanatos = true;
      WHarmful expl2 = new WHarmful( location.x, location.y, 'e');
      gameObjs.add(expl2);
      int searInd = arLiSearch(this, enemies);
      if (searInd >= 0) {
        if (enemies != null) {
          enemies.remove(searInd);
        }
      }
    }
  }


  PVector avoid() {
    PVector steer = new PVector( 0, 0 );
    PVector direction = velocity.get();
    direction.normalize();
    direction.mult( avoid_max_distance );
    closest_distance = Float.MAX_VALUE;
    closest_intersect = new PVector( 0, 0 );
    boolean apply_steer = false;

    for (int i = 0; i < harmfuls.size(); i++) {
      WHarmful b = (WHarmful)harmfuls.get(i);
      PVector b_dir = PVector.sub( b.location, location );
      b_dir.normalize();
      PVector v_dir = velocity.get();
      v_dir.normalize();
      float dot_product = v_dir.dot( b_dir );
      if (dot_product > 0) {
        float distance_to_barrier = location.dist( b.location );
        if (distance_to_barrier < avoid_max_distance) {
          if (avoid_barrier( b, direction )) {
            PVector velocity_normal = velocity.get();
            velocity_normal.normalize();
            steer = new PVector( -velocity_normal.y, velocity_normal.x );
            PVector q = PVector.sub( b.location, location );
            float w = q.dot( steer );
            if (w > 0) {
              steer.mult( -1.0 );
            }
            float m = map( distance_to_barrier, 0, avoid_max_distance, max_speed, 0 );
            m = constrain( m, 0, max_speed );
            steer.mult( m );
            apply_steer = true;
          }
        }
      }
    }

    if (apply_steer) {
      stroke( 0, 255, 0 );
      strokeWeight( 2 );
      line( location.x, location.y, closest_intersect.x, closest_intersect.y );
    }

    return steer;
  }



  boolean avoid_barrier( WHarmful b, PVector direction ) {
    PVector a0 = new PVector( location.x - b.location.x, location.y - b.location.y );
    PVector b0 = new PVector( location.x + direction.x - b.location.x, location.y + direction.y - b.location.y );
    float dx = b0.x - a0.x;
    float dy = b0.y - a0.y;
    float dr = sqrt( dx * dx + dy * dy );
    float d  = a0.x * b0.y - b0.x * a0.y;
    float discrim = ((b.wide + 5) * (b.wide + 5) * dr * dr) - (d * d);
    if (discrim > 0) {
      float sqrt_discrim = sqrt( discrim );
      float x1 = (d * dy + sgn(dy) * dx * sqrt_discrim) / (dr * dr);
      float y1 = (-d * dx + abs(dy) * sqrt_discrim) / (dr * dr);
      PVector p1 = new PVector( x1, y1 );
      float x2 = (d * dy - sgn(dy) * dx * sqrt_discrim) / (dr * dr);
      float y2 = (-d * dx - abs(dy) * sqrt_discrim) / (dr * dr);
      PVector p2 = new PVector( x2, y2 );
      float distance_p1 = a0.dist( p1 );
      float distance_p2 = a0.dist( p2 );
      float distance_to_barrier = min( distance_p1, distance_p2 );

      if (distance_to_barrier < closest_distance) {
        stroke( 255 );
        //line( location.x, location.y, b.location.x, b.location.y );
        closest_distance = distance_to_barrier;
        if (distance_p1 < distance_p2) {
          closest_intersect.x = b.location.x + x1;
          closest_intersect.y = b.location.y + y1;
        }
        else {
          closest_intersect.x = b.location.x + x2;
          closest_intersect.y = b.location.y + y2;
        }
        //line( location.x, location.y, closest_intersect.x, closest_intersect.y );
        return true;
      }
    }
    return false;
  }

  float sgn( float x ) {
    if (x < 0)
      return -1.0;
    else
      return 1.0;
  }
}

