
class Bullet {
  float x, y;
  PImage img;
  float speed = 10;

  Bullet(float x, float y, PImage img) {
    this.x = x;
    this.y = y;
    this.img = img;
  }

  void move() {
    y -= speed;
  }

  void display() {
    image(img, x, y);
  }

  boolean isOffScreen() {
    return y < -img.height;
  }

  boolean intersects(GameObject other) {
    return collideRectRect(x, y, img.width, img.height, other.getX(), other.getY(), other.getWidth(), other.getHeight());
  }

    boolean intersects(Boss other) { // Added overload for Boss
        return collideRectRect(x, y, img.width, img.height, other.getX(), other.getY(), other.getWidth(), other.getHeight());
  }
}
