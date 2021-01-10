class Timer {
  int startTime;
  int duration;

  Timer(int duration_) {
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
}
