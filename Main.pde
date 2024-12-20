PImage bg, earth, titleImage, playerImg, enemyBlueImg, enemyPurpleImg,
  bulletImg, bossImg, bossLaserImg, bossBulletImg, bossRocketsImg;
PImage[] meteorImages, enemyImages;
PFont font;
int buttonWidth = 200;
int buttonHeight = 50;
int selectedButton = -1;

int gameState = 0;
int level = 0;
int score = 0;
int lives = 3;
int maxBullets = 1;

int levelTransitionTimer = 120;
int nextLevel = 0;

ArrayList<Bullet> bullets;
ArrayList<Enemy> enemies;
ArrayList<Meteor> meteors;
ArrayList<BossBullet> bossBullets;
ArrayList<BossRocket> bossRockets;
ArrayList<Laser> bossLasers;

Player player;
Boss boss;

int meteorsDestroyed = 0; //New variable to track destroyed meteors
int meteorsToDestroyLevel2 = 20; // Number of meteors to destroy in Level 2
long levelStartTime = 0; 
int enemiesInFormation = 0; 
long lastShotTime = 0;  
int shotCooldown = 250; // Bullet cooldown in milliseconds
long lastBulletTime = 0;
long lastBossAttackTime = 0;
int bossAttackInterval = 3000; //Milliseconds between boss attacks


void setup() {
  size(1024, 1024); //Adjusted size for better display
  bg = loadImage("Background.png");
  earth = loadImage("Earth.png");
  playerImg = loadImage("spaceship.png");
  bossImg = loadImage("Boss.png");
  bossLaserImg = loadImage("bosslasser.png");
  bossBulletImg = loadImage("bossbullet.png");
  bossRocketsImg = loadImage("bossrockets.png");
  enemyImages = new PImage[]{
    loadImage("blue enemy.png"),
    loadImage("purple enemy.png")
  };
  bulletImg = loadImage("bullet.png");
  titleImage = loadImage("Title.png");

  meteorImages = new PImage[]{
    loadImage("big meteor1.png"),
    loadImage("big meteor2.png"),
    loadImage("Medium meteor1.png"),
    loadImage("Medium meteor2.png"),
    loadImage("small meteor1.png"),
    loadImage("small meteor2.png"),
    loadImage("small meteor3.png")
  };

  font = createFont("SpaceGames-K7zKD.otf", 80); 
  textFont(font);

  player = new Player(playerImg);
  bullets = new ArrayList<Bullet>();
  enemies = new ArrayList<Enemy>();
  meteors = new ArrayList<Meteor>();
  bossLasers= new ArrayList<Laser>();
  bossBullets = new ArrayList<BossBullet>();
  bossRockets = new ArrayList<BossRocket>();
  boss = new Boss(bossImg, bossLaserImg, bossBulletImg, bossRocketsImg);

}

void draw() {
  switch (gameState) {
  case 0:
    drawStartMenu();
    break;
  case 1:
    drawGame();
    break;
  case 2:
    drawLevelTransition(nextLevel);
    break;
  case 3:
    gameOver();
    break;
  case 4:
    youWin();
    break;
   case 5:
      drawDebugMenu();
      break;
    case 6:
    drawControlsMenu();
    break;
  }
}

void drawGame() {
  background(bg);

  if (lives <= 0) {
    gameState = 3;
    return;
  }
  
// Display Score
  fill(255);
  textSize(32);
  textAlign(LEFT, TOP);
  text("Score: " + score, 20, 20);
  
  
 fill(255, 0, 0);
  textSize(32);
  textAlign(LEFT, BOTTOM);
  text("Lives: " + lives, 20, height - 20);



  player.move();
  player.display();
  updateBullets();
  updateLevel();


  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    e.move();
    e.display();

    if (e.isOffScreen()) {
      enemies.remove(i);
    }
  }

  for (int i = meteors.size() - 1; i >= 0; i--) {
    Meteor m = meteors.get(i);
    m.move();
    m.display();
    if (m.isOffScreen()) {
      meteors.remove(i);
    }
  }
  for (int i = bossLasers.size() - 1; i >= 0; i--) {
  Laser l = bossLasers.get(i);
  l.display();
  if (l.isOffScreen()) {
    bossLasers.remove(i);
    }
}
    for (int i = bossBullets.size() - 1; i >= 0; i--) {
    BossBullet b = bossBullets.get(i);
    b.move();
    b.display();
    if (b.isOffScreen()) {
      bossBullets.remove(i);
    }
  }

    for (int i = bossRockets.size() - 1; i >= 0; i--) {
    BossRocket r = bossRockets.get(i);
    r.move();
    r.display();
    if (r.isOffScreen()) {
      bossRockets.remove(i);
    }
  }


  checkCollisions();

  if (level == 3 && boss.isDead()) {
      gameState = 4;
  }
  
if (level == 1 && enemies.isEmpty() && enemiesInFormation > 0) { // Only check if enemies were present
      levelComplete();
  }
}

void updateBullets() {
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    b.move();
    b.display();
    if (b.isOffScreen()) {
      bullets.remove(i);
    }
  }
}


void updateLevel() {
  if (level == 1) { // Enemy level
    createEnemyFormation(); //This function will be defined below
  }
  else if (level == 2) {
    if (frameCount % 60 == 0 && meteors.size() < 15) {
      createMeteor();
    }
  } else if (level == 3) {
    boss.display();
    if (millis() - lastBossAttackTime > bossAttackInterval) {
      boss.attack();
      lastBossAttackTime = millis();
    }
  }
   if (level == 2 && meteorsDestroyed >= meteorsToDestroyLevel2) {
    levelComplete();
  }
}

void createEnemyFormation() {
  if (enemies.isEmpty()) {
    int numCols = 6;
    int numRows = 6;
    enemiesInFormation = numCols * numRows; 
    int spacingX = 30; 
    int spacingY = 30; 
    int startX = (width - (numCols * (enemyImages[0].width + spacingX) ) + spacingX) / 2;
    int startY = -600; // Start enemies above the screen
    int enemySpeed = 3;

    for (int row = 0; row < numRows; row++) {
      for (int col = 0; col < numCols; col++) {
        int enemyIndex = (row + col) % enemyImages.length;
        int x = startX + col * (enemyImages[0].width + spacingX);
        int y = startY + row * (enemyImages[0].height + spacingY);
        enemies.add(new Enemy(enemyImages[enemyIndex], x, y, enemySpeed)); // Pass speed to the constructor
      }
    }
  }
}

void createMeteor() {
  float meteorX = random(width);
  float meteorY = -random(100);
  int meteorIndex = int(random(meteorImages.length));
  float meteorSpeed = random(3, 7);
  float angle = atan2(height, random(-30,30)); //Angle for diagonal movement

  meteors.add(new Meteor(meteorImages[meteorIndex], meteorX, meteorY, meteorSpeed, angle));
}


void levelComplete() {
  if (level < 3) {
    gameState = 2; // Transition to the level transition state
    nextLevel = level + 1;
    levelTransitionTimer = 120;
    enemies.clear(); // Clear enemies from the previous level
    meteors.clear(); // Clear meteors from the previous level (this is crucial)
    bullets.clear(); // Clear bullets from the previous level
    player.reset();
    maxBullets++; //Increase maximum bullets per level completion.
  }
}



void checkCollisions() {
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    for (int j = enemies.size() - 1; j >= 0; j--) {
      Enemy e = enemies.get(j);
      if (b.intersects(e)) {
        bullets.remove(i);
        enemies.remove(j);
        score += 100; //Adjust score as needed.
        break;
      }
    }
      for (int j = meteors.size() - 1; j >= 0; j--) {
      Meteor m = meteors.get(j);
      if (b.intersects(m)) {
        bullets.remove(i);
        meteors.remove(j);
        score += 50;
        meteorsDestroyed++; //Increment meteorsDestroyed when a meteor is hit
        break;
      }
    }
  
    if (level == 3 && b.intersects(boss)) {
        bullets.remove(i);
        score += 100;
        boss.takeDamage(2); 
    }
  }
  //Player collision with enemies
  for (int i = enemies.size() - 1; i >= 0; i--) {
    Enemy e = enemies.get(i);
    if (player.intersects(e)) {
      enemies.remove(i);
      player.takeDamage();
    }
  }
    //Player collision with meteors
  for (int i = meteors.size() - 1; i >= 0; i--) {
    Meteor m = meteors.get(i);
    if (player.intersects(m)) {
      meteors.remove(i);
      player.takeDamage();
    }
  }

    for (int i = bossLasers.size() - 1; i >= 0; i--) {
        Laser l = bossLasers.get(i);
        l.display();
         if (player.intersects(l)) { // Check for player collision
            player.takeDamage();
        }
    }

  for (int i = bossBullets.size() - 1; i >= 0; i--) {
    BossBullet b = bossBullets.get(i);
    if (player.intersects(b)) {
      bossBullets.remove(i);
      player.takeDamage();
    }
  }
  
  for (int i = bullets.size() - 1; i >= 0; i--) {
    Bullet b = bullets.get(i);
    for (int j = bossRockets.size() - 1; j >= 0; j--) {
      BossRocket r = bossRockets.get(j);
      if (b.intersects(r)) {
        bullets.remove(i);
        bossRockets.remove(j);
        score += 200; // Adjust score as needed
        break; // Exit inner loop after collision
      }
    }
  }

   //Player collision with boss rockets
  for (int i = bossRockets.size() - 1; i >= 0; i--) {
    BossRocket r = bossRockets.get(i);
    if (player.intersects(r)) {
      bossRockets.remove(i);
      player.takeDamage();
    }
  }
}


void keyPressed() {
  if (key == ' ' && gameState == 1) {
    if (millis() > lastShotTime + shotCooldown) { // Check the cooldown
      float bulletSpacing = 60; 
      for (int i = 0; i < maxBullets; i++) {
        float xOffset = (i - (maxBullets - 1) / 2.0) * bulletSpacing; 
        bullets.add(new Bullet(player.x + player.img.width / 2 - bulletImg.width / 2 + xOffset, player.y, bulletImg));
      }
      lastShotTime = millis(); // Update last shot time after firing
    }
  }
  if (key == 'r' && (gameState == 3 || gameState == 4)) { 
    restartGame();
  }
}

void restartGame() {
  gameState = 0;
  level = 0;
  lives = 3;
  score = 0;
  bullets.clear();
  enemies.clear();
  meteors.clear();
  bossBullets.clear();
  bossRockets.clear();
  bossLasers.clear();
  boss.reset();
  player.reset();
  meteorsDestroyed=0;
  maxBullets=1;
  loop();
}


void drawStartMenu() {
  image(bg, 0, 0);
  float earthX = width / 2 - earth.width / 2;
  float earthY = height * 0.6f - earth.height / 2;
  image(earth, earthX, earthY);
  image(player.img, width / 2 - player.img.width / 2, height / 3 - player.img.height / 2);

  float titleY = height / 2 + 100;
  image(titleImage, width / 2 - titleImage.width / 2, titleY - titleImage.height / 2);

  drawButton("START", 0, height / 2 - buttonHeight - 10);
  drawButton("LEVELS", 1, height / 2 + 10);  //Options button triggers debug menu
  drawButton("CONTROLS", 2, height / 2 + buttonHeight + 30);
}

void drawDebugMenu() {
  background(bg);
  image(earth, width / 2 - earth.width / 2, height * 0.6f - earth.height / 2);

  fill(255);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Level", width / 2, height / 3+ 30);

  float buttonY = height / 2 - buttonHeight * 1.5f; // Starting Y position
  drawButton("Level 1", 1, buttonY);
  buttonY += buttonHeight * 1.2f; // Adjust spacing between buttons.  1.2f is for some spacing
  drawButton("Level 2", 2, buttonY);
  buttonY += buttonHeight * 1.2f;
  drawButton("Level 3", 3, buttonY);
  buttonY += buttonHeight * 1.2f;
  drawButton("Back", 0, buttonY);
}
void drawControlsMenu() {
  background(bg);
  fill(207, 214, 101); // Yellow
  textSize(32);
  textAlign(CENTER, CENTER);
  text("CONTROLS", width / 2, height / 4);

  textSize(20);
  textAlign(CENTER, CENTER);
  fill(207, 214, 101); // Yellow

  float yOffset = height / 4 + 50; // Starting y-position for text
  float lineSpacing = 30;       // Vertical spacing between lines

  text("Movement:", width / 2, yOffset);
  yOffset += lineSpacing;
  text("W - Move Up", width / 2, yOffset);
  yOffset += lineSpacing;
  text("S - Move Down", width / 2, yOffset);
  yOffset += lineSpacing;
  text("A - Move Left", width / 2, yOffset);
  yOffset += lineSpacing;
  text("D - Move Right", width / 2, yOffset);
  yOffset += lineSpacing * 2; // Add extra spacing for separation

  text("Shooting:", width / 2, yOffset);
  yOffset += lineSpacing;
  text("Spacebar - Fire bullets", width / 2, yOffset);
  yOffset += lineSpacing * 2; // Add extra spacing before "Back"

  // Add the Back button (assuming drawButton is defined elsewhere)
  drawButton("Back", 0, height * 0.55);
}

void drawLevelTransition(int levelToDisplay) {
  image(bg, 0, 0);
  fill(#D9D900);
  textAlign(CENTER, CENTER);
  textSize(80);
  text("LEVEL " + levelToDisplay, width / 2, height / 2);

  levelTransitionTimer--;

  if (levelTransitionTimer <= 0) {
    level++;
    gameState = 1;

  }
}


void drawButton(String label, int buttonIndex, float y) {
  color buttonColor = (buttonIndex == selectedButton) ? color(207, 214, 101) : color(200, 211, 25);
  fill(buttonColor);
  rectMode(CENTER);
  rect(width / 2, y, buttonWidth, buttonHeight, 10);
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(22);
  text(label, width / 2, y);
}

void gameOver() {
  textSize(64);
  fill(#D9D900);
  textAlign(CENTER, CENTER);
  text("Game Over", width / 2, height / 2);
  textSize(40);
  text("Press 'R' to restart", width / 2, height / 2 + 70);
  noLoop();
}

void youWin() {
  textSize(50);
  fill(#D9D900);
  textAlign(CENTER, CENTER);
  text("You Win!", width / 2, height / 2);
  textSize(40);
  text("Press 'R' to restart", width / 2, height / 2 + 70);
  noLoop();
}

void mouseMoved() {
    selectedButton = getHoveredButton(gameState);
}

int getHoveredButton(int menuState) {
    if (menuState == 0) { // Main Menu
        return getMainMenuHoveredButton();
    } else if (menuState == 5) { // Debug Menu
        return getDebugMenuHoveredButton();
    } else if (menuState == 6) { // Controls Menu
        return getControlsMenuHoveredButton();
    } else {
        return -1; // No button hovered in other game states
    }
}


int getMainMenuHoveredButton() {
    for (int i = 0; i < 3; i++) {
        float y = (i == 0) ? height / 2 - buttonHeight - 10 : (i == 1) ? height / 2 + 10 : height / 2 + buttonHeight + 30;
        if (mouseX > width / 2 - buttonWidth / 2 && mouseX < width / 2 + buttonWidth / 2 && mouseY > y - buttonHeight / 2 && mouseY < y + buttonHeight / 2) {
            return i;
        }
    }
    return -1; // No button hovered
}

int getDebugMenuHoveredButton() {
  float buttonY = height / 2 - buttonHeight * 1.5f;
  for (int i = 0; i < 4; i++) {
    if (mouseX > width / 2 - buttonWidth / 2 && mouseX < width / 2 + buttonWidth / 2 &&
        mouseY > buttonY - buttonHeight / 2 && mouseY < buttonY + buttonHeight / 2) {
      return (i < 3) ? i + 1 : 0; //Corrected: Return level (1-3) or 0 for Back
    }
    buttonY += buttonHeight * 1.2f;
  }
  return -1;
}

int getControlsMenuHoveredButton() {
  float backButtonY = height * 0.55;
  if (mouseX > width / 2 - buttonWidth / 2 && mouseX < width / 2 + buttonWidth / 2 && mouseY > backButtonY - buttonHeight / 2 && mouseY < backButtonY + buttonHeight / 2) {
    return 0; // Back button
  }
  return -1; // No button hovered
}

void mouseClicked() {
  if (gameState == 6) { //Handle clicks in the Controls Menu
    handleControlsMenuClick();
  } else if (gameState == 0) { //Handle clicks in the Main Menu
      handleMainMenuClick();
  } else if (gameState == 5) {
      handleDebugMenuClick();
  }
}

void handleMainMenuClick() {
  if (selectedButton == 0) { // Start Game
    gameState = 2;
    nextLevel = 1;
    level = 0;
    levelTransitionTimer = 120;
    selectedButton = -1;
  } else if (selectedButton == 1) { // Options (now goes to debug menu)
    gameState = 5;
    selectedButton = -1;
  } else if (selectedButton == 2) { // Controls
    gameState = 6; //Go to Controls menu
    selectedButton = -1;
  }
}
void handleControlsMenuClick() {
    if (selectedButton == 0) { // Back button
        gameState = 0;
        selectedButton = -1;
    }
}

void handleDebugMenuClick() {
  if (selectedButton == 1 || selectedButton == 2 || selectedButton == 3) {
    gameState = 2;
    nextLevel = selectedButton;
    level = selectedButton - 1;
    levelTransitionTimer = 120;
    selectedButton = -1;
  } else if (selectedButton == 0) {
    gameState = 0;
    selectedButton = -1;
  }
}

boolean collideRectRect(float x1, float y1, float w1, float h1, float x2, float y2, float w2, float h2) {
  return (x1 < x2 + w2 &&
          x1 + w1 > x2 &&
          y1 < y2 + h2 &&
          y1 + h1 > y2);
}
