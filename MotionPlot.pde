class MotionPlot {
  float[] motions;
  int plotWidth;
  int plotHeight;

  MotionPlot(int plotWidth_, int plotHeight_) {
    plotWidth = plotWidth_;
    plotHeight = plotHeight_;
  }

  void initialize() {
    motions = new float[150];

    for (int i=0; i<motions.length; i++) {
      motions[i] = 0;
    }
  }

  void update(float motion) {
    // keep track of motions
    for (int i=motions.length - 1; i>0; i--) {
      motions[i] = motions[i-1];
    }

    motions[0] = motion;
  }


  void display() {
    // display plot with white background
    fill(255);
    rect(width-plotWidth, height-plotHeight, plotWidth, plotHeight);
    
    // display motionvalues as points. This is how we go about it:
    // we loop over motion FROM BACK TO FRONT and then display a point
    // on top of our rectangle. we use red dots/ellipses?
    noStroke();
    fill(255, 0, 0);
    for (int i=motions.length - 1; i>=0; i--) {
      ellipse(width - 2*i, height - motions[i], 5, 5);
      println("motions[i]: ", motions[i]);
    }
  }
}
