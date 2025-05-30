import QtQuick 2.15
import QtQuick.Controls 2.15

ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: "Computer Vision: GUI"

    Column {
        anchors.centerIn: parent
        spacing: 10

        Label {
            id: inferenceLabel
            objectName: "inferenceLabel"
            text: "Waiting for inference..."
            font.pixelSize: 20
        }
    }
}
