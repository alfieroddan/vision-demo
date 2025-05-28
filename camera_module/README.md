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

Extra notes:

There are some really cool libraries and resources to help:

- [mediamtx](https://github.com/bluenviron/mediamtx?tab=readme-ov-file#generic-webcam): basically a server that runs extremely efficiently, grabs whatever you send it and converts it to some useful formats.
- [learn ffmpeg the hard way](https://github.com/leandromoreira/ffmpeg-libav-tutorial?tab=readme-ov-file#video---what-you-see): good intuition behind what ffmpeg does and also just general media sharing
- [simple ffmpeg streamer](https://github.com/leixiaohua1020/simplest_ffmpeg_streamer/): simple implemenation of ffmpeg c++

ChatGPT summary:

```text
- Discussed how transport layers like ZeroMQ, ROS2, and RTI DDS work for text and custom data (tensors, images).
- DDS provides structured, real-time, reliable pub/sub communication with QoS, zero-copy shared memory locally; ZeroMQ handles raw messages but needs framing; ROS2 uses DDS internally.
- DDS is suited for local real-time structured data exchange; GStreamer and ffmpeg are specialized for media streaming with codecs and compression over networks.
- DDS is best for robotics/control data, while GStreamer/ffmpeg excel at video/audio streaming.
- Shared memory IPC on the same device can be done using Python `multiprocessing.shared_memory` or C++ `shm_open`; network communication requires protocols like DDS or ZeroMQ.
- Consumer detection of new frames: via signaling (sequence numbers, semaphores) in shared memory or subscriber callbacks in DDS/ZeroMQ.
- Transferring a 12 MB uncompressed file over a 1 Gbps LAN takes roughly 100 ms; DDS adds some overhead; TCP is reliable but can add retransmission delays; shared memory transport is much faster locally.
- Over WiFi, TCP/IP streaming raw bytes is generally the best reliable method for RGB frame transfer on embedded devices.
- Clarified that GStreamer/ffmpeg are not replacements for DDS in structured data transport but are ideal for video/audio streaming.
- Use case: streaming 1280p RGB frames from Raspberry Pi with a custom C++ SDK to a laptop GUI.
- Recommended compressing frames (JPEG or hardware H264) before sending over TCP/UDP to handle WiFi bandwidth constraints.
- GStreamer with hardware-accelerated encoding offers low latency and bandwidth-efficient streaming.
- Raw RGB TCP streaming is simplest but bandwidth-heavy and less practical at 30 FPS over WiFi.
- Offered assistance with example implementations: JPEG + TCP streaming or GStreamer pipelines.
```