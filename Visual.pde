class Visual {
  float motionSpeed;
  int xpos, ypos;
  float noiseLevel;

  Visual() {
    xpos = width/2;
    ypos = height/2;
  }

  void display(float size_) {
    // display visual, update with motion
    float size = map(size_, 30, 75, 5, 500);
    
    fill(255, 255, 255, 200);
    ellipse(xpos, ypos, size, size);
  }
}
