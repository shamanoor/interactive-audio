import processing.video.*;
import processing.sound.*;

SoundFile song;
Capture cam;
AudioIn mic;
Amplitude analyzer;

color trackColor;
boolean clapping;
String[] effects;
int index;
boolean previousScreenBlacked;

void setup() {
  size(640, 480);

  effects = new String[]{"none", "blue", "red", "green"};
  clapping = false;
  previousScreenBlacked = false;

  cam = new Capture(this, "USB2.0 HD UVC WebCam");
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

  if (screenIsBlacked() && !previousScreenBlacked) {
    index = (index + 1) % effects.length;
    changeEffect(index);
    previousScreenBlacked = true;
  } else if (!screenIsBlacked()) {
    previousScreenBlacked = false;
  }

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

void changeEffect(int index) {
  String effect = effects[index];
  if (effect == "none") {
    tint(255);
    image(cam, 0, 0);
  } else if ( effect == "blue") {
    tint(0, 0, 255);
    image(cam, 0, 0);
  } else if ( effect == "red") {
    tint(255, 0, 0);
    image(cam, 0, 0);
  } else if ( effect == "green") {
    tint(0, 255, 0);
    image(cam, 0, 0);
  }
}

boolean screenIsBlacked() {
  int numBlacked = 0;

  // Begin loop to walk through every pixel
  for (int x = 0; x < cam.width; x++) {
    for (int y = 0; y < cam.height; y++) {
      int loc = x + y * cam.width;

      // What is current color
      color currentColor = cam.pixels[loc];
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);

      // If sum of current colors is less than 5
      if (brightness(currentColor) <= 6) {
        numBlacked += 1;
      }
    }
  }
  if (numBlacked >= cam.width * cam.height / 2) {
    return true;
  } 
  return false;
}
