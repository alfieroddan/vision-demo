#include "stdafx.h"
#include <iostream>
#include <sstream>
#include "FlyCapture2.h"
#include <gst/gst.h>
#include <gst/app/gstappsrc.h>


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

int main(){
    // FlyCapture basic stuff
    PrintBuildInfo();
    Error error;

    // Gstreamer setup
    GError *gError = nullptr;
    // GstElement *pipeline = gst_parse_launch(
    //     "appsrc name=mysrc is-live=true block=true format=time "
    //     "! videoconvert "
    //     "! video/x-raw,format=GRAY8,width=1280,height=1024,framerate=150/1 "
    //     "! jpegenc "
    //     "! rtpjpegpay "
    //     "! udpsink host=127.0.0.1 port=5000", &gError);

    // if (!pipeline) {
    //     cerr << "Failed to create pipeline: " << (gError ? gError->message : "Unknown error") << endl;
    //     if (gError) g_error_free(gError);
    //     return -1;
    // }

    // get camera
    BusManager busMgr;
    unsigned int numCameras;
    error = busMgr.GetNumOfCameras(&numCameras);
    if (error != PGRERROR_OK){
        PrintError(error);
        return -1;
    }

    cout << "Number of cameras detected: " << numCameras << endl;
    PGRGuid guid;
    error = busMgr.GetCameraFromIndex(0, &guid);
    if (error != PGRERROR_OK){
        PrintError(error);
        return -1;
    }

    // Connect to a camera
	Camera cam;
    error = cam.Connect(&guid);
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return -1;
    }

    // Get the camera information
    CameraInfo camInfo;
    error = cam.GetCameraInfo(&camInfo);
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return -1;
    }

    PrintCameraInfo(&camInfo);

    // Get the camera configuration
    FC2Config config;
    error = cam.GetConfiguration(&config);
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return -1;
    }

    // Set the number of driver buffers used to 10.
    config.numBuffers = 10;

    // Set the camera configuration
    error = cam.SetConfiguration(&config);
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return -1;
    }

    // Start capturing images
    error = cam.StartCapture();
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return -1;
    }

    while (true) {
        // Acquire Image
        Image rawImage;
        error = cam.RetrieveBuffer(&rawImage);
        if (error != PGRERROR_OK)
        {
            PrintError(error);
            // continue;
            return -1;
        }

        cout << "Grabbed image " << endl;

        // Create a converted image
        Image convertedImage;
        // Convert the raw image
        error = rawImage.Convert(PIXEL_FORMAT_MONO8, &convertedImage);
        if (error != PGRERROR_OK){
            PrintError(error);
            return -1;
        }

        // // HERE WE PACKAGE AND SEND WITH GSTREAMER
        // GstBuffer *buffer;
        // GstFlowReturn ret;

        // unsigned int dataSize = convertedImage.GetDataSize();
        // unsigned char* data = convertedImage.GetData();

        // buffer = gst_buffer_new_allocate(NULL, dataSize, NULL);
        // gst_buffer_fill(buffer, 0, data, dataSize);

        // GstCaps *caps = gst_caps_new_simple("video/x-raw",
        //     "format", G_TYPE_STRING, "GRAY8",
        //     "width", G_TYPE_INT, convertedImage.GetCols(),
        //     "height", G_TYPE_INT, convertedImage.GetRows(),
        //     "framerate", GST_TYPE_FRACTION, 30, 1,
        //     NULL);
        // gst_app_src_set_caps(GST_APP_SRC(appsrc), caps);
        // gst_caps_unref(caps);
        
        // GstMapInfo map;
        // gst_buffer_map(buffer, &map, GST_MAP_WRITE);
        // // Data already copied
        // gst_buffer_unmap(buffer, &map);
        
        // GST_BUFFER_PTS(buffer) = gst_util_uint64_scale(gst_clock_get_time(gst_element_get_clock(pipeline)) - gst_element_get_base_time(pipeline), 1, GST_SECOND);
        // GST_BUFFER_DURATION(buffer) = gst_util_uint64_scale(1, GST_SECOND, 30);
        
        // ret = gst_app_src_push_buffer(GST_APP_SRC(appsrc), buffer);
        // if (ret != GST_FLOW_OK) {
        //     cerr << "Error pushing buffer to GStreamer" << endl;
        //     break;
        // }

    }

    // // Cleanup gst
    // gst_element_set_state(pipeline, GST_STATE_NULL);
    // gst_object_unref(appsrc);
    // gst_object_unref(pipeline);

    // Stop capturing images
    error = cam.StopCapture();
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return -1;
    }

    // Disconnect the camera
    error = cam.Disconnect();
    if (error != PGRERROR_OK)
    {
        PrintError(error);
        return -1;
    }

    return 0;
}