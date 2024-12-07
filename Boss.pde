class Boss {
float x, y;
PImage img;
PImage laserImg;
PImage bulletImg;
PImage rocketImg;
boolean isDead = false;
int health = 100;
int maxHealth = 100;
long lastLaserFireTime = 0;
long lastRocketFireTime = 0;
long lastBulletFireTime = 0;
long laserFireInterval = 10000; 
long rocketFireInterval = 1000; 
long bulletFireInterval = 7000;

Boss(PImage img, PImage laserImg, PImage bulletImg, PImage rocketImg) {
        this.img = img;
        this.laserImg = laserImg;
        this.bulletImg = bulletImg;
        this.rocketImg = rocketImg;
    }
    
    void display() {
    image(img, x, y);
    fill(255);
    textSize(32);
    textAlign(LEFT, TOP);
    text("Score: " + score, 20, 20);
     drawHealthBar();
      }
      
    void drawHealthBar() {
     
    float barWidth = 512;  
    float barHeight = 20;       
    float healthRatio = (float) health / maxHealth;

    fill(100); // Gray background bar
    rect(512, y - barHeight +30, barWidth, barHeight);

    fill(255, 0, 0); // Red health bar
    rect(512, y - barHeight + 30, barWidth * healthRatio, barHeight);

    }

  void attack() {
    float bulletSpacing = 175;
    //Bullets
    bossBullets.add(new BossBullet(x + img.width / 2 - bulletImg.width / 2 - bulletSpacing, y + img.height, bulletImg));
    bossBullets.add(new BossBullet(x + img.width / 2 - bulletImg.width / 2 + bulletSpacing, y + img.height, bulletImg));

    //Lasers (Now using Laser class)
    bossLasers.add(new Laser(x + 132, y + img.height, laserImg)); //Create ArrayList<Laser> bossLasers in setup()
    bossLasers.add(new Laser(x + 822, y + img.height, laserImg));
    
    // Rockets: Fire 3 rockets, homing in on the player's real-time position
    for (int i = 0; i < 3; i++) {
    float rocketX = random(width - rocketImg.width); // Random horizontal position for rockets
    bossRockets.add(new BossRocket(rocketX, y + img.height, rocketImg, player)); // Pass the player object
    }
}
  
  
  
void takeDamage(int damage) {
health -= damage;
if (health <= 0) {
isDead = true;
}
}


boolean isDead() {
return isDead;
}

void reset() {
isDead = false;
health = 100;
}

float getX() {
return x;
}

float getY() {
return y;
}

float getWidth() {
return img.width;
}

float getHeight() {
return img.height;
}
}
