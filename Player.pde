class Player {
  float x, y;
  PImage img;
  float speed = 5;
  long lastDamageTime = 0;
  int damageCooldown = 1000; 
  
  
  Player(PImage img) {
    this.img = img;
    x = width / 2 - img.width / 2;
    y = height - img.height - 20;
  }

void move() {
  if (keyPressed) {
    if (keyPressed && (key == 'w' || keyCode == UP) && y > 0) {
      y -= speed;
    }
    if (keyPressed && (key == 's' || keyCode == DOWN) && y < height - img.height) {
      y += speed;
    }
    if (keyPressed && (key == 'a' || keyCode == LEFT) && x > 0) {
      x -= speed;
    }
    if (keyPressed && (key == 'd' || keyCode == RIGHT) && x < width - img.width) {
      x += speed;
    }
  }
}

   void takeDamage() {
    if (millis() - lastDamageTime > damageCooldown) {
      lives--;
      lastDamageTime = millis();
    }
  }

 void display() {
  if (millis() - lastDamageTime < damageCooldown) {
    tint(255, 150); // Make the player semi-transparent
  } else {
    noTint(); // Restore normal appearance
  }
  image(img, x, y);
  noTint();
}

  boolean intersects(GameObject other) {
    return collideRectRect(x, y, img.width, img.height, other.getX(), other.getY(), other.getWidth(), other.getHeight());
  }

  void reset() {
    x = width / 2 - img.width / 2;
    y = height - img.height - 20;
  }
}
