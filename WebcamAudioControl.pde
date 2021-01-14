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
PImage previousFrame;
float motion;

Timer timer;
MotionPlot plot;
MovingAverage movingAverage;
MotionPlot averageMotionPlot;

void setup() {
  size(640, 480);

  effects = new String[]{"none", "blue", "red", "green"};
  clapping = false;
  previousScreenBlacked = false;
  motion = 1;

  cam = new Capture(this, "USB2.0 HD UVC WebCam");
  song = new SoundFile(this, "Vald - Eurotrap.mp3");
  mic = new AudioIn(this, 0);
  analyzer = new Amplitude(this);
  previousFrame = createImage(cam.width, cam.height, RGB);
  timer = new Timer(1);
  plot = new MotionPlot(300, 150);
  averageMotionPlot = new MotionPlot(300, 150);
  movingAverage = new MovingAverage(50);

  cam.start();
  song.play();
  mic.start();
  analyzer.input(mic);

  timer.start();
  plot.initialize();
  averageMotionPlot.initialize();
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

  if (timer.isFinished()) {
    motion = getMotion();
    timer.start();

    // update moving average
    movingAverage.update(motion);
    println("time!");
  } else {
    println("motion: ", motion);
  }
  float motionMA = movingAverage.getAverage();
  float speed = map(motionMA, 15, 55, 0.1, 1);
  song.rate(speed);

  float volume = map(mouseY, 0, height, 0.1, 1);
  song.amp(volume);

  plot.update(motion);
  plot.display(true, color(255, 0, 0));

  averageMotionPlot.update(motionMA);

  averageMotionPlot.display(false, color(0, 255, 0));

  println("moving average: ", movingAverage.getAverage());
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
