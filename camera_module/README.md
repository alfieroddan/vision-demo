# Camera Module


TODO:
- Try RGB 8 instead of MONO 8
- FPS is wrong
- Improve gstreamer output, gotta be better than current
- https://github.com/bluenviron/mediamtx

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
Linux:
```
cmake -DFLYCAPTURE2_ROOT=/home/tay/Documents/flycapture.2.13.3.31_arm64 ..
```

Windows:
```
cmake -DFLYCAPTURE2_ROOT="C:/Program Files/Point Grey Research/FlyCapture2" ..
```


## Run

```bash
gst-launch-1.0 -v udpsrc port=5000 caps="application/x-rtp,media=video,encoding-name=H264,payload=96" \
! rtph264depay \
! avdec_h264 \
! videoconvert \
! autovideosink
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
