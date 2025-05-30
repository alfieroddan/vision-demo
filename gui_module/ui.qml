import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 800
    height: 600
    title: "Computer Vision: GUI"

    Image {
        id: inferenceImage
        objectName: "inferenceImage"
        source: "image://frameprovider/current"
        fillMode: Image.PreserveAspectFit

        // Bind width and height dynamically to controller.imageSize
        width: controller.imageSize.width
        height: controller.imageSize.height

        // Optional: limit max size to window size, preserve aspect ratio, etc.
        // You can add anchors or maximum size limits here if needed
    }
}