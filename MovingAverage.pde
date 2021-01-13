class MovingAverage {
  float[] values;

  MovingAverage(int windowSize) {
    values = new float[windowSize];

    for (int i=0; i<values.length; i++) {
      values[i] = 0;
    }
  }

  // add latest measured motion to array
  void update(float value) {
    for (int i=values.length - 1; i>0; i--) {
      values[i] = values[i-1];
    }
    values[0] = value;
  }
  
  float getAverage() {
    float sumOfValues = 0;
    for (float value : values) {
      sumOfValues += value;
    }
    return sumOfValues/values.length; 
  }
}
