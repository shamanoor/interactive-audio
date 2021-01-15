class Timer {
  int startTime;
  int duration;

  Timer() {
  }
  
  void set(int duration_) {
    duration = duration_;  
  }
  
  void start() {
    startTime = millis();
  }

  boolean isFinished() {
    if (millis() - startTime > duration) {
      return true;
    }
    return false;
  }
  
  int getRemainingTime() {
    return millis() - startTime;
  }
}
