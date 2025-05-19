#include "stdafx.h"
#include <iostream>
#include <sstream>
#include <chrono>
#include <thread>
#include "FlyCapture2.h"
#include <gst/gst.h>
#include <gst/app/gstappsrc.h>
#define DEBUG 0  // Will capture exactly 100 frames
using namespace FlyCapture2;
using namespace std;

static void PrintBuildInfo()
{
    FC2Version fc2Version;
    Utilities::GetLibraryVersion(&fc2Version);

    ostringstream version;
    version << "FlyCapture2 library version: " << fc2Version.major << "."
            << fc2Version.minor << "." << fc2Version.type << "."
            << fc2Version.build;
    cout << version.str() << endl;

    ostringstream timeStamp;
    timeStamp << "Application build date: " << __DATE__ << " " << __TIME__;
    cout << timeStamp.str() << endl << endl;
}

static void PrintCameraInfo(CameraInfo *pCamInfo)
{
    cout << endl;
    cout << "*** CAMERA INFORMATION ***" << endl;
    cout << "Serial number - " << pCamInfo->serialNumber << endl;
    cout << "Camera model - " << pCamInfo->modelName << endl;
    cout << "Camera vendor - " << pCamInfo->vendorName << endl;
    cout << "Sensor - " << pCamInfo->sensorInfo << endl;
    cout << "Resolution - " << pCamInfo->sensorResolution << endl;
    cout << "Firmware version - " << pCamInfo->firmwareVersion << endl;
    cout << "Firmware build time - " << pCamInfo->firmwareBuildTime << endl
         << endl;
}

static void PrintError(Error error) { error.PrintErrorTrace(); }

// Option 1: UDP streaming with lossless x264
// Receiver command: gst-launch-1.0 udpsrc port=5000 caps="application/x-rtp" ! rtph264depay ! h264parse ! avdec_h264 ! videoconvert ! autovideosink
GstElement *create_udp_lossless_pipeline(const string& host, int port) {
    ostringstream pipeline_str;
    pipeline_str << "appsrc name=mysrc format=time is-live=true "
                 << "caps=video/x-raw,format=GRAY8,width=1280,height=1024,framerate=30/1 ! "
                 << "videoconvert ! "
                 << "x264enc tune=zerolatency speed-preset=ultrafast ! "
                 << "rtph264pay config-interval=1 ! "
                 << "udpsink host=" << host << " port=" << port;
    
    return gst_parse_launch(pipeline_str.str().c_str(), nullptr);
}

// Option 2: TCP streaming with lossless x264
// Receiver command: gst-launch-1.0 tcpclientsrc host=YOUR_SERVER_IP port=5000 ! tsdemux ! h264parse ! avdec_h264 ! videoconvert ! autovideosink
GstElement *create_tcp_lossless_pipeline(int port) {
    ostringstream pipeline_str;
    pipeline_str << "appsrc name=mysrc format=time is-live=true "
                 << "caps=video/x-raw,format=GRAY8,width=1280,height=1024,framerate=30/1 ! "
                 << "videoconvert ! "
                 << "x264enc tune=zerolatency ! "
                 << "h264parse ! "
                 << "mpegtsmux ! "
                 << "tcpserversink host=0.0.0.0 port=" << port;
    
    return gst_parse_launch(pipeline_str.str().c_str(), nullptr);
}

// Option 3: File recording with lossless x264
// View file: ffplay output.mp4 or vlc output.mp4
GstElement *create_file_lossless_pipeline(const string& filename) {
    ostringstream pipeline_str;
    pipeline_str << "appsrc name=mysrc format=time is-live=true "
                 << "caps=video/x-raw,format=GRAY8,width=1280,height=1024,framerate=30/1 ! "
                 << "videoconvert ! "
                 << "x264enc tune=zerolatency ! "
                 << "mp4mux ! "
                 << "filesink location=" << filename;
    
    return gst_parse_launch(pipeline_str.str().c_str(), nullptr);
}

// Option 4: Raw UDP streaming (no compression)
// Receiver command: gst-launch-1.0 udpsrc port=5000 caps="application/x-rtp,media=video,clock-rate=90000,encoding-name=RAW,sampling=YCbCr-4:2:0,depth=8,width=1280,height=1024" ! rtpvrawdepay ! videoconvert ! autovideosink
GstElement *create_raw_udp_pipeline(const string& host, int port) {
    ostringstream pipeline_str;
    pipeline_str << "appsrc name=mysrc format=time is-live=true "
                 << "caps=video/x-raw,format=GRAY8,width=1280,height=1024,framerate=30/1 ! "
                 << "videoconvert ! "
                 << "rtpvrawpay ! "
                 << "udpsink host=" << host << " port=" << port;
    
    return gst_parse_launch(pipeline_str.str().c_str(), nullptr);
}

int main(){
    // FlyCapture basic stuff
    PrintBuildInfo();
    Error error;

    // Gstreamer setup
    int argc = 0;
    char **argv = nullptr;
    gst_init(&argc, &argv);
    gst_debug_set_default_threshold(GST_LEVEL_WARNING);
    
    // Choose your pipeline here:
    
    // Option 1: UDP streaming
    GstElement *pipeline = create_udp_lossless_pipeline("127.0.0.1", 5000);
    
    // Option 2: TCP streaming
    // GstElement *pipeline = create_tcp_lossless_pipeline(5000);
    
    // Option 3: File recording (default)
    // GstElement *pipeline = create_file_lossless_pipeline("output_lossless.mp4");
    
    // Option 4: Raw UDP streaming (largest bandwidth but truly lossless)
    // GstElement *pipeline = create_raw_udp_pipeline("192.168.1.100", 5000);

    if (!pipeline) {
        cerr << "Failed to create pipeline" << endl;
        return -1;
    }

    gst_element_set_state(pipeline, GST_STATE_PLAYING);

    GstElement *appsrc = gst_bin_get_by_name(GST_BIN(pipeline), "mysrc");

    // Set caps with the correct framerate
    GstCaps *caps = gst_caps_new_simple("video/x-raw",
        "format", G_TYPE_STRING, "GRAY8",
        "width", G_TYPE_INT, 1280,
        "height", G_TYPE_INT, 1024,
        "framerate", GST_TYPE_FRACTION, 30, 1,
        NULL);
    gst_app_src_set_caps(GST_APP_SRC(appsrc), caps);
    gst_caps_unref(caps);
        
    // Get camera
    BusManager busMgr;
    unsigned int numCameras;
    error = busMgr.GetNumOfCameras(&numCameras);
    if (error != PGRERROR_OK){
        PrintError(error);
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(appsrc);
        gst_object_unref(pipeline);
        return -1;
    }

    cout << "Number of cameras detected: " << numCameras << endl;
    if (numCameras == 0) {
        cout << "No cameras detected!" << endl;
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(appsrc);
        gst_object_unref(pipeline);
        return -1;
    }

    PGRGuid guid;
    error = busMgr.GetCameraFromIndex(0, &guid);
    if (error != PGRERROR_OK){
        PrintError(error);
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(appsrc);
        gst_object_unref(pipeline);
        return -1;
    }

    // Connect to a camera
    Camera cam;
    error = cam.Connect(&guid);
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(appsrc);
        gst_object_unref(pipeline);
        return -1;
    }

    // Get the camera information
    CameraInfo camInfo;
    error = cam.GetCameraInfo(&camInfo);
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        cam.Disconnect();
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(appsrc);
        gst_object_unref(pipeline);
        return -1;
    }

    PrintCameraInfo(&camInfo);

    // Get the camera configuration
    FC2Config config;
    error = cam.GetConfiguration(&config);
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        cam.Disconnect();
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(appsrc);
        gst_object_unref(pipeline);
        return -1;
    }

    // Set the number of driver buffers used to 10.
    config.numBuffers = 10;

    // Set the camera configuration
    error = cam.SetConfiguration(&config);
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        cam.Disconnect();
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(appsrc);
        gst_object_unref(pipeline);
        return -1;
    }

    // Start capturing images
    error = cam.StartCapture();
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        cam.Disconnect();
        gst_element_set_state(pipeline, GST_STATE_NULL);
        gst_object_unref(appsrc);
        gst_object_unref(pipeline);
        return -1;
    }

    cout << "Starting capture..." << endl;

    static GstClockTime timestamp = 0;
    const int fps = 30;
    const GstClockTime duration = GST_SECOND / fps;
    const auto frame_delay = std::chrono::milliseconds(1000 / fps);
    int frameCount = 0;
    int max_frames = 100;
    while (true) {
        auto start = std::chrono::steady_clock::now();
        #if DEBUG
            // In debug mode, stop after max_frames
            if (frameCount >= max_frames){
                cout << "\nDebug mode: Reached " << max_frames << " frames. Stopping..." << endl;
                break;
            }
        #endif
        
        // Acquire Image
        Image rawImage;
        error = cam.RetrieveBuffer(&rawImage);
        if (error != PGRERROR_OK) {
            PrintError(error);
            break;
        }

        // Convert to MONO8 (grayscale)
        Image convertedImage;
        error = rawImage.Convert(PIXEL_FORMAT_MONO8, &convertedImage);
        if (error != PGRERROR_OK) {
            PrintError(error);
            break;
        }

        // Create GstBuffer
        GstBuffer *buffer;
        GstFlowReturn ret;
        unsigned int dataSize = 1280 * 1024;
        unsigned char* data = convertedImage.GetData();
        buffer = gst_buffer_new_allocate(NULL, dataSize, NULL);
        gst_buffer_fill(buffer, 0, data, dataSize);

        // Set timestamps for proper streaming
        GST_BUFFER_PTS(buffer) = timestamp;
        GST_BUFFER_DURATION(buffer) = duration;
        timestamp += duration;

        // Push buffer to pipeline
        ret = gst_app_src_push_buffer(GST_APP_SRC(appsrc), buffer);
        if (ret != GST_FLOW_OK) {
            cerr << "Error pushing buffer to GStreamer: " << ret << endl;
            break;
        }

        frameCount++;
        auto elapsed = std::chrono::steady_clock::now() - start;
        if (elapsed < frame_delay) {
            std::this_thread::sleep_for(frame_delay - elapsed);
        }
        if (frameCount % 30 == 0) {
            cout << "Frames processed: " << frameCount << endl;
        }
    }

    cout << "Stopping capture..." << endl;

    // Send EOS to properly close the stream
    gst_app_src_end_of_stream(GST_APP_SRC(appsrc));

    // Cleanup gst
    gst_element_set_state(pipeline, GST_STATE_NULL);
    gst_object_unref(appsrc);
    gst_object_unref(pipeline);

    // Stop capturing images
    error = cam.StopCapture();
    if (error != PGRERROR_OK)
    {
        PrintError(error);
    }

    // Disconnect the camera
    error = cam.Disconnect();
    if (error != PGRERROR_OK)
    {
        PrintError(error);
    }

    cout << "Application finished successfully." << endl;
    return 0;
}