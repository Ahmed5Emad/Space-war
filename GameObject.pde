abstract class GameObject {
  float x, y;
  PImage img;
  float width, height;

  GameObject(PImage img, float x, float y) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.width = img.width;
    this.height = img.height;
  }

  void display() {
    image(img, x, y);
  }

  float getX() {
    return x;
  }

  float getY() {
    return y;
  }

  float getWidth() {
    return width;
  }

  float getHeight() {
    return height;
  }

  boolean isOffScreen() {
   return y > 1100;
  }
}

class Enemy extends GameObject {
  float speed;

  Enemy(PImage img, float x, float y, float speed) { 
    super(img, x, y);  //Corrected constructor call
    this.speed = speed;
  }

  void move() {
    y += speed;
  }
}

class Meteor extends GameObject {
  float speed;
  float angle;

  Meteor(PImage img, float x, float y, float speed, float angle) { // Added angle to constructor
    super(img, x, y);
    this.speed = speed;
    this.angle = angle;
  }

  void move() {
    x += speed * cos(angle);
    y += speed * sin(angle);
  }

  boolean isOffScreen() {
    return y > 1024 || x < 0 || x > 1024; // Check all sides
  }
}

class Laser extends GameObject {
  int lifespan = 90; // Lifespan in frames (1 second at 60 fps)
  int timer = 0;

  Laser(float x, float y, PImage img) {
    super(img, x, y);
  }

  void display() {
    image(img, x, y); // No need to adjust height dynamically
  }

  boolean isOffScreen() {
    timer++;
    return timer > lifespan;
  }
}

class BossBullet extends GameObject {
  float speed = 8; // Adjust speed as needed

  BossBullet(float x, float y, PImage img) {
    super(img, x, y); 
  }

  void move() {
    y += speed; //Boss bullets move downwards
  }

   boolean isOffScreen() {
      return y > 1024;
    }
}


class BossRocket extends GameObject {
  float speed = 6;
  float angle; 
  float turnRate = 0.001; 
  boolean homingEnabled = true; 
  Player player; // Reference to the player object

  BossRocket(float x, float y, PImage img, Player player) {
    super(img, x, y);
    this.player = player; // Pass the player object to the rocket
    angle = atan2(player.y - y, player.x - x); // Initially aim at the player
  }

  void move() {
    if (homingEnabled) {
      // Dynamically update the target to the player's current position
      float dx = player.x - x;
      float dy = player.y - y;
      float targetAngle = atan2(dy, dx);

      // Smoothly rotate the rocket towards the target angle
      float angleDiff = (targetAngle - angle + PI) % (TWO_PI) - PI; // Normalize to [-PI, PI]
      angle += constrain(angleDiff, -turnRate, turnRate);

      // Update the rocket's position
      x += speed * cos(angle);
      y += speed * sin(angle);

      // Disable homing after passing the player's position
      if (y > player.y) {
        homingEnabled = false;
      }
    } else {
      // Continue in the current direction after homing is disabled
      x += speed * cos(angle);
      y += speed * sin(angle);
    }
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle- PI / 2); // Adjust for image alignment
    image(img, 0, 0);
    popMatrix();
  }
  boolean isOffScreen() {
    return y > 1024 || x < 0 || x > 1024;
  }
}
