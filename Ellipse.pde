class Ellipse {
  int x, y, size;
  float moveX, moveY;
  float speed;
  color fillColor;
  String id;
  PFont font;

  Ellipse(int x_, int y_, int size_, int id_, float speed_) {
    this.x = x_;
    this.y = y_;
    this.size = size_;
    this.moveX = random(2, 4);
    this.moveY = random(2, 4);
    this.speed = speed_;
    this.id = str(id_);

    font = createFont("Georgia", 32);
    textFont(font);
  }

  // display control points
  void display() {
    fill(0, 0, 0, 0);
    noStroke();
    ellipse(x, y, size, size);
    //text(id, x, y);
  }

  void update() {
    // here check if it is within the acceptable range
    // currently that is the window's edges, but in the future
    // they will be boundaries surrounding the shape, probably
    // in the form of an outer circle and an inner circle
    this.x += moveX*speed;
    this.y += moveY*speed;

    if (x <= 0 || x >= width) {
      this.moveX *= -1;
    }

    if (y <= 0 || y >= height) {
      this.moveY *= -1;
    }
  }

  void update(int newX, int newY) {
    this.x = newX;
    this.y = newY;
  }
  
  void updateSpeed(float speed_) {
    this.speed = speed_;
  }

  boolean hovering() {
    if (mouseX >= (x - size/2) && mouseX <= (x + size/2)
      && mouseY >= (y - size/2) && mouseY <= (y + size/2)) {
      return true;
    }
    return false;
  }

  float[] getCoords() {
    float[] coords = {x, y};
    return coords;
  }
}
