# Camera Module

## Raspberry Pi + Flea 3 PointGrey

## Sofware

### Raspberry Pi (RPI)

We used a [RPI](https://www.raspberrypi.com) since everyone has one, or something similar. It's lightweight and has just enough computing power for my needs. To Flash we used the [RPI imager](https://www.raspberrypi.com/software/), we used **Ubuntu 24.10**. Follow the instructions from RPI imager to install Ubuntu.

### FlyCapture2 SDK

For the camera software, you can use whatever your camera suits. We have a point greay flea 3 so I will use this.

We need [FlyCapture2](https://www.teledynevisionsolutions.com/en-gb/products/flycapture-sdk/) for arm64 linux. At the time of writing we download flycapture.2.13.3.31_arm64 (note it's not actually supported for Ubuntu 24, but it works).

Then to install the SDK, follow [these steps](https://www.teledynevisionsolutions.com/en-gb/support/support-center/application-note/iis/getting-started-with-flycapture-2-and-arm/).

## Custom Software

### Prerequisites

- CMake
- Gstreamer
- GLib

## Build

Build process:

```bash
cmake -DFLYCAPTURE2_ROOT=<path/to/flycapture_arm64> ..
i.e
cmake -DFLYCAPTURE2_ROOT=/home/tay/Documents/flycapture.2.13.3.31_arm64 ..
```

## Run

```bash
./main 192.168.1.42 6000
```


## Helpful

Gstreamer fake command:
```bash
HOST=192.128.xxxxx
gst-launch-1.0 -v \
  videotestsrc is-live=true pattern=ball ! \
  video/x-raw,width=854,height=480,framerate=30/1 ! \
  x264enc tune=zerolatency bitrate=1500 speed-preset=ultrafast ! \
  rtph264pay config-interval=1 pt=96 ! \
  udpsink host=$HOST port=5000

```
gstreamer receiver command

```bash
gst-launch-1.0 -v \
    udpsrc port=5000 caps="application/x-rtp, media=(string)video, encoding-name=(string)H264, payload=96, clock-rate=90000" ! \
    rtph264depay ! avdec_h264 ! videoconvert ! autovideosink sync=false
```

or for the gui:

```
udpsrc port=5100 caps="application/x-rtp, media=(string)video, encoding-name=(string)H264, payload=96, clock-rate=90000" ! rtph264depay ! avdec_h264 ! videoconvert ! video/x-raw,format=BGR ! appsink
```

## Notes

```text
For UNIX I had to install these three things for gst:
1. sudo apt-get install glib2.0
2. sudo apt-get install libgstreamer1.0-dev
3. sudo apt-get install libgstreamer-plugins-base1.0-dev
4. sudo apt install gstreamer1.0-plugins-ugly
5. sudo apt install gstreamer1.0-libav
```

Extra notes:

There are some really cool libraries and resources to help:

- [mediamtx](https://github.com/bluenviron/mediamtx?tab=readme-ov-file#generic-webcam): basically a server that runs extremely efficiently, grabs whatever you send it and converts it to some useful formats.
- [learn ffmpeg the hard way](https://github.com/leandromoreira/ffmpeg-libav-tutorial?tab=readme-ov-file#video---what-you-see): good intuition behind what ffmpeg does and also just general media sharing
- [simple ffmpeg streamer](https://github.com/leixiaohua1020/simplest_ffmpeg_streamer/): simple implemenation of ffmpeg c++
