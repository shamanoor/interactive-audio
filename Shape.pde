class Shape {
  /* The shape will start out as circle, concsisting of curve vertices
   The shape's form will change over time
   */
  Ellipse[] points;
  int radius;
  int pointSize;
  int numPoints;
  int numCoords;

  // to control shape size
  int maxOuterRadius;
  int maxInnerRadius;

  // then we need to define these two based on the radius of the shape probably...?
  // and then... or better to do this in the Ellipse class??...

  Shape(int radius_, int pointSize_, int numPoints_) {
    this.radius = radius_;
    this.pointSize = pointSize_;
    this.numPoints = numPoints_;
    this.numCoords = numPoints + 3; // we need to do +3 to get a closed shape
    this.points = new Ellipse[numCoords];
  }

  void initialize() {
    for (int i=0; i<points.length; i++) {
      int xcoord = int(radius * sin(TWO_PI/numPoints * i));
      int ycoord = int(radius *cos(TWO_PI/numPoints * i));
      points[i] = new Ellipse(xcoord + width/2, ycoord + height/2, pointSize, i, 4);
    }
  }

  void move() {
    for (int i=0; i<points.length; i++) {
      // update control points with their new locations
      points[i].update();
    }

    // necessary to ensure the shape stays soft in the edges: assign the end point the same
    // as the starting point
    points[points.length-2] = points[1]; // copy last point so they get updated with the same

    for (int i=0; i<points.length; i++) {
      // update control points with their new locations
      points[i].display();
    }
  }

  void update() {
    for (int i=0; i<points.length; i++) {
      // update control points with where they have been dragged to
      if (points[i].hovering()) {
        points[i].update(mouseX, mouseY);
        points[i].display();
      }
    }
  }

  void updateSpeed(float currentSpeed) {
    for (int i=0; i<points.length; i++) {
      // update control points with where they have been dragged to
      points[i].updateSpeed(currentSpeed);
    }
  }

  void display() {
    beginShape();
    for (int i=0; i<points.length; i++) {
      points[i].display();
      fill(255, 0, 0, 100);
      curveVertex(points[i].x, points[i].y);
    }
    endShape();
  }
}
