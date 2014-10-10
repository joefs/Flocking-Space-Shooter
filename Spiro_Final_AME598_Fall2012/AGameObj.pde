abstract class AGameObj {
  PVector prevLocation;
  PVector location;
  PVector velocity;
  PVector acceleration;
  //
  PVector arrivalDestination;
  boolean arrival_state;
  boolean neutral_state;
  boolean wander_state;
  boolean run_state;
  int wide;
  boolean thanatos;
  //
  int age;
  int lifetime;
  //

  AGameObj() {
  }
  AGameObj(float x, float y) {
    prevLocation = new PVector( x, y );
    location = new PVector( x, y );
    velocity = new PVector( 0, 0 );
    acceleration = new PVector( 0, 0 );
    thanatos = false;
  }

  abstract void process();
  abstract void render();
}

