import processing.video.*;
import processing.sound.*;

SoundFile song;
Capture cam;
AudioIn mic;
Amplitude analyzer;

color trackColor;
boolean clapping = false;


void setup() {
  size(640, 480);

  cam = new Capture(this, Capture.list()[0]);
  song = new SoundFile(this, "Vald - Eurotrap.mp3");
  mic = new AudioIn(this, 0);
  analyzer = new Amplitude(this);

  cam.start();
  song.play();
  mic.start();
  analyzer.input(mic);
}

void draw() {
  cam.loadPixels();
  image(cam, 0, 0);

  // edit audio using mouseX, mouseY etc...
  // then decide upon a mapping
  float speed = map(mouseX, 0, width, 0.1, 1);
  song.rate(speed);

  float volume = map(mouseY, 0, height, 0.1, 1);
  song.amp(volume);

  // check if clapping, if clap, then toggle play/stop music
  listenForClap();
}

void captureEvent(Capture input) {
  input.read();
}

void mousePressed() {
  int loc = mouseX + mouseY * cam.width;
  trackColor = cam.pixels[loc];
}

void findClosestMatch() {
  float currentClosest = 500;

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
      if (d < currentClosest) {
        currentClosest = d;
        closestX = x;
        closestY = y;
      }
    }
  }

  if (currentClosest < 10) {
    // Draw a circle at the tracked pixel
    fill(trackColor);
    strokeWeight(4);
    stroke(0);
    ellipse(closestX, closestY, 16, 16);
  }
}

void listenForClap() {
  float micVolume = analyzer.analyze();
  float clapLevel = 0.4; // How loud is a clap
  float threshold = 0.25; // How quiet is silence

  println(micVolume); 

  if (micVolume > clapLevel && !clapping) {
    clapping = true; // I am now clapping!
    println("clap!");
    if (song.isPlaying()) {
      song.pause();
    } else {
      song.play();
    }
  } else if (clapping && micVolume < threshold) {
    clapping = false;
  }
}
