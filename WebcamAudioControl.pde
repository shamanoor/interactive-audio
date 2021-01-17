import processing.video.*;
import processing.sound.*;

SoundFile song;
Capture cam;
AudioIn mic;
Amplitude analyzer;

String[] effects;
int index;
boolean previousScreenBlacked;
boolean displayPlot;
PImage previousFrame;
float motion;
float[] boundaryValues;
float absoluteMin;
float absoluteMax;
float speed;
PFont f;

Timer timer;
MotionPlot plot;
MovingAverage movingAverage;
MotionPlot averageMotionPlot;

void setup() {
  size(640, 480);

  effects = new String[]{"none", "blue", "red", "green"};
  previousScreenBlacked = false;
  motion = 1;
  f = createFont("Georgia", 16);

  cam = new Capture(this, "USB2.0 HD UVC WebCam");
  song = new SoundFile(this, "Vald - Eurotrap.mp3");
  mic = new AudioIn(this, 0);
  analyzer = new Amplitude(this);
  previousFrame = createImage(cam.width, cam.height, RGB);
  timer = new Timer();
  plot = new MotionPlot(300, 150);
  averageMotionPlot = new MotionPlot(300, 150);
  movingAverage = new MovingAverage(100);

  cam.start();
  song.play();
  mic.start();
  analyzer.input(mic);

  plot.initialize();
  averageMotionPlot.initialize();

  // assign initial values to absoluteMin and absoluteMax
  // can be updated using a call to calibrate()
  absoluteMin = 10;
  absoluteMax = 70;
  
  // constain value for speed  
}

void calibrate() {
  float currentMotion;

  absoluteMin = 1000;
  absoluteMax = -1000;

  println("calibrating");

  // print out information to screen, let it on screen for like 5 seconds or something
  timer.set(5000);

  timer.start();
  println("Get ready to stand still!");
  // give time to prepare
  while (!timer.isFinished()) {
    // wait
  }

  timer.start();
  println("Stand still!");
  // give first instruction: stand still
  while (!timer.isFinished()) {
    println("getMotion(): ", getMotion());
    currentMotion = getMotion();
    if (currentMotion < absoluteMin) {
      absoluteMin = currentMotion;
    }
  }

  timer.start();
  println("Get ready to dance like crazy!");
  // give first instruction: stand still
  while (!timer.isFinished()) {
    // wait
  }

  println("Dance like crazy!");
  timer.start();
  // give first instruction: stand still
  while (!timer.isFinished()) {
    println("getMotion(): ", getMotion());
    currentMotion = getMotion();
    if (currentMotion > absoluteMax) {
      absoluteMax = currentMotion;
    }
  }

  println("absoluteMin: ", absoluteMin, "absoluteMax: ", absoluteMax);
}

void draw() {
  cam.loadPixels();
  image(cam, 0, 0);

  if (screenIsBlacked() && !previousScreenBlacked) {
    song.pause();

    // change camera effect
    index = (index + 1) % effects.length;
    changeEffect(index);

    previousScreenBlacked = true;
  } else if (!screenIsBlacked() && !song.isPlaying()) {
    song.play();
    previousScreenBlacked = false;
  }

  motion = getMotion();
  // update moving average
  movingAverage.update(motion);

  float motionMA = movingAverage.getAverage();
  speed = map(motionMA, absoluteMin, absoluteMax, 0.1, 1.5);
  speed = constrain(speed, 0.1, 1.5);
  song.rate(speed);
  
  println("motionMA: ", motionMA);
  println("speed: ", speed);

  float volume = map(mouseY, 0, height, 0.1, 1);
  song.amp(volume);

  plot.update(motion);
  averageMotionPlot.update(motionMA);

  if (displayPlot) {
    plot.display(true, color(255, 0, 0));
    averageMotionPlot.display(false, color(0, 255, 0));
  }
}

void captureEvent(Capture input) {
  // store previous frame to do motion detection
  previousFrame.copy(input, 0, 0, input.width, input.height, 
    0, 0, input.width, input.height);
  previousFrame.updatePixels();

  // read new frame
  input.read();
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

// function to calculate how much motion was detected 
float getMotion() {
  float totalDiff = 0;

  for (int x=0; x<cam.width; x++) {
    for (int y=0; y<cam.height; y++) {
      int loc = x + y*cam.width;
      color currentPixel = cam.pixels[loc];
      color previousPixel = previousFrame.pixels[loc];

      float r1 = red(currentPixel);
      float g1 = green(currentPixel);
      float b1 = blue(currentPixel);
      float r2 = red(previousPixel);
      float g2 = green(previousPixel);
      float b2 = blue(previousPixel);

      // compute difference between current and previous pixel

      float diff = dist(r1, r2, b1, b2, g1, g2);

      totalDiff += diff;
    }
  }

  // average motion is computed as average difference of all pixels
  // between current and previous frame
  return totalDiff/(cam.pixels.length);
}

void keyPressed() {
  if (key == ' ') {
    println("Start calibration process");
    calibrate();
  }

  if (key=='p') {
    displayPlot = !displayPlot;
  }
}
