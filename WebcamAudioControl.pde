import processing.video.*;
import processing.sound.*;

SoundFile song;
Capture cam;

color trackColor;

void setup() {
  size(640, 480);
  
  cam = new Capture(this, Capture.list()[0]);
  song = new SoundFile(this, "Vald - Eurotrap.mp3");

  cam.start();
  song.play();
}

void draw() {
  cam.loadPixels();
  image(cam, 0, 0);
  float closestMatch = 500;

  // (x,y) coordinate of closest color
  int closestX = 0;
  int closestY = 0;

  // Begin loop to walk through every pixel
  for (int x = 0; x < cam.width; x++) {
    for (int y = 0; y < cam.height; y++) {
      int loc = x + y * cam.width;

      // What is current color
      color currentColor = cam.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      // Using euclidean distance to compare colors
      float d = dist(r1, g1, b1, r2, g2, b2);

      // If current color is more similar to tracked
      // color than closest color, save current location
      // and current difference
      if (d < closestMatch) {
        closestMatch = d;
        closestX = x;
        closestY = y;
      }
    }
  }

  if (closestMatch < 10) {
    // Draw a circle at the tracked pixel
    fill(trackColor);
    strokeWeight(4);
    stroke(0);
    ellipse(closestX, closestY, 16, 16);
  }
  
  // edit audio using mouseX, mouseY etc...
  // then decide upon a mapping
  
}

void captureEvent(Capture input) {
  input.read();
}

void mousePressed() {
  int loc = mouseX + mouseY * cam.width;
  trackColor = cam.pixels[loc];
}
