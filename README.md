# interactive-audio

The intention of this project is to interact with the audio speed of a song through motion. The motion is detected by a webcam.

To use this project, modify in the main file (WebcamAudioControl.pde) the following two lines to reference to your webcam and to a .mp3 file. The .mp3 file should be placed in a ./data folder.

```
  cam = new Capture(this, "USB2.0 HD UVC WebCam");
  song = new SoundFile(this, "Vald - Eurotrap.mp3");
```
