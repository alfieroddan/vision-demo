import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: Screen.width * 0.9
    height: Screen.height * 0.9
    title: "Computer Vision: GUI"
    color: "#121212"  // Dark background

    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
    }

    RowLayout {
        anchors.fill: parent
        spacing: 12

        // Left Sidebar
        Rectangle {
            Layout.preferredWidth: 220
            Layout.fillHeight: true
            color: "#1E1E1E"
            radius: 8
            border.color: "#333"
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 16

                Rectangle {
                    radius: 6
                    color: "#2C2C2C"
                    Layout.fillWidth: true
                    height: 40

                    ComboBox {
                        id: inputSelector
                        anchors.fill: parent
                        model: ["WebCam", "Stream"]
                        currentIndex: 0
                        font.pixelSize: 14
                        palette.text: "white"
                    }
                }

                Rectangle {
                    radius: 6
                    color: "#2C2C2C"
                    Layout.fillWidth: true
                    height: 40

                    ComboBox {
                        id: inferenceSelector
                        anchors.fill: parent
                        model: ["None", "YOLO"]
                        currentIndex: 0
                        font.pixelSize: 14
                        palette.text: "white"
                    }
                }

                Item { Layout.fillHeight: true }

                Rectangle {
                    radius: 6
                    color: "#B00020"
                    Layout.fillWidth: true
                    height: 40

                    Button {
                        anchors.fill: parent
                        text: "Exit"
                        font.bold: true
                        font.pixelSize: 14
                        palette.buttonText: "white"
                        onClicked: Qt.quit()
                    }
                }
            }
        }

        // Main Content Area
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 400
                color: "#222222"
                radius: 8

                Image {
                    id: inferenceImage
                    source: "image://frameprovider/current"
                    fillMode: Image.PreserveAspectFit
                    anchors.centerIn: parent
                    width: Math.min(controller.imageSize.width, parent.width - 20)
                    height: Math.min(controller.imageSize.height, parent.height - 20)
                    smooth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                TextArea {
                    id: messageBox
                    Layout.fillHeight: true
                    Layout.maximumHeight: 150
                    readOnly: true
                    text: "Messages will appear here..."
                    font.pixelSize: 14
                    color: "#DDD"
                }

                Rectangle {
                    Layout.fillHeight: true
                    radius: 8
                    border.color: "#333"
                    border.width: 1
                    color: "#1E1E1E"

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 8

                        Label {
                            text: "Device: Webcam"
                            font.pixelSize: 16
                            font.bold: true
                            color: "#BBB"
                        }
                        Label {
                            text: "FPS: 0"
                            font.pixelSize: 14
                            color: "#999"
                        }
                        Label {
                            text: "Usage: 0%"
                            font.pixelSize: 14
                            color: "#999"
                        }
                    }
                }
            }
        }
    }
}
