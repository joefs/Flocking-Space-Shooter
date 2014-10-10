abstract class ZAgent extends AGameObj {
  PVector previousSeek;
  //
  float mass;
  float max_force;
  float max_speed;
  float orientation;
  float max_turn_rate;
  boolean arrived;
  //
  AGameObj target;

  ZAgent() {
  }

  ZAgent(float x, float y) {
    super(x, y);
    mass = 1.0;
    max_force = 0.1;
    max_speed = 5.0;
    orientation = 0;
    max_turn_rate = TWO_PI / 10.0;
    arrival_state = false;
    neutral_state = true;
    wander_state = false;
    run_state = false;
    arrivalDestination = new PVector(0, 0);
    arrived = false;
  }


  //

  abstract void process();
  abstract void render();

  //

  void thrust( float magnitude ) {
    float vx = magnitude * cos( orientation );
    float vy = magnitude * sin( orientation );
    velocity.x += vx;
    velocity.y += vy;
  }

  void turn( float magnitude ) {
    acceleration.x = velocity.y;
    acceleration.y = -velocity.x;
    acceleration.normalize();
    acceleration.mult( magnitude );
  }

  void wrap() {// If not wandering, it needs to die on leaving the screen
    if (wander_state) {
      if (location.x > width)
        location.x = location.x % width;
      else if (location.x < 0)
        location.x += width;
      if (location.y > height) 
        location.y = location.y % height;
      else if (location.y < 0)
        location.y += height;
    }
  }

  //
  PVector seek( PVector seek_position ) {
    PVector desired_velocity = PVector.sub( seek_position, location );
    desired_velocity.normalize();
    float desired_heading = desired_velocity.heading2D();
    float heading_diff = desired_heading - orientation;
    if (heading_diff > PI) {
      heading_diff = -(TWO_PI - heading_diff);
    }
    else if (heading_diff < -PI) {
      heading_diff = TWO_PI - abs( heading_diff );
    }

    noStroke();
    fill( 255 );

    float turn_delta = constrain( heading_diff, -max_turn_rate, max_turn_rate );
    float desire = orientation + turn_delta;
    PVector seek = new PVector( cos( desire ) * max_speed, sin( desire ) * max_speed );
    return seek;
  }




  PVector wander(float wanderStrength, float wanderRate) {
    float distanceAhead = 20;
    PVector CenterAhead = new PVector(location.x + (distanceAhead * cos(orientation)), location.y + (distanceAhead * sin(orientation)));
    float mappedOrientation = ((noise(location.x / wanderRate, location.y / wanderRate) -.5) + (noise(CenterAhead.x / wanderRate, CenterAhead.y / wanderRate) -.5)) * TWO_PI;
    PVector LocationOnCirc = new PVector(CenterAhead.x + (wanderStrength * cos(mappedOrientation)), CenterAhead.y + (wanderStrength * sin(mappedOrientation)));
    PVector seekingIt = seek(LocationOnCirc);
    fill(255);
    ellipse(LocationOnCirc.x, LocationOnCirc.y, 10, 10);
    return seekingIt;
  }

  PVector pursuit( AGameObj target ) {
    PVector predicted_velocity = target.velocity.get();// puts the targets velocity into a variable called predicted velocity
    predicted_velocity.mult( 60 );
    PVector predicted = PVector.add( target.location, predicted_velocity );
    PVector arrival = arrival( predicted, 10 );
    return arrival;
  }


  PVector arrival( PVector arrival_position, float proximity ) {
    PVector target_offset = PVector.sub(arrival_position, location);
    float thisDistance = target_offset.mag();
    float ramped_speed = max_speed * ((thisDistance- proximity)/ 100 ); /* Magic number but should be an area around the target*/
    if ((ramped_speed < 2)&& (thisDistance < proximity + 5)) {
      ramped_speed = 0;
      arrived = true;
    }
    float clipped_speed = min(ramped_speed, max_speed);// Constrains true speed to below max
    PVector desired_velocity = PVector.mult(target_offset, (clipped_speed / thisDistance));
    PVector steering = PVector.sub(desired_velocity, velocity);
    return steering;
  }
  //
  boolean colided(AGameObj posi) {
    float distLimit = (wide + posi.wide)/2;
    float distAct = dist(location.x, location.y, posi.location.x, posi.location.y);
    if (distAct <= distLimit) {
      return true;
    }
    return false;
  }
  //
  

  
  
}

