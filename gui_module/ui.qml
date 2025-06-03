import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls.Material 2.15

ApplicationWindow {
    visible: true
    width: Screen.width * 0.9
    height: Screen.height * 0.9
    title: "Computer Vision Demo"

    Material.theme: Material.System
    Material.accent: Material.Teal
    Material.primary: Material.BlueGrey

    // Adaptive color properties
    readonly property color surfaceColor: Material.theme === Material.Dark ? "#1e1e1e" : "#ffffff"
    readonly property color surfaceVariantColor: Material.theme === Material.Dark ? "#2d2d2d" : "#f5f5f5"
    readonly property color primaryTextColor: Material.theme === Material.Dark ? "#ffffff" : "#1a1a1a"
    readonly property color secondaryTextColor: Material.theme === Material.Dark ? "#b0b0b0" : "#6b6b6b"
    readonly property color borderColor: Material.theme === Material.Dark ? "#404040" : "#e0e0e0"
    readonly property color selectedColor: Material.theme === Material.Dark ? "#004d40" : "#e0f2f1"
    readonly property color hoverColor: Material.theme === Material.Dark ? "#383838" : "#f0f0f0"
    readonly property color accentColor: Material.accent
    readonly property color successColor: "#4caf50"
    readonly property color warningColor: "#ff9800"
    readonly property color errorColor: "#f44336"

    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Header
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: surfaceColor
            radius: 12
            border.color: borderColor
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 16

                RowLayout {
                    spacing: 12

                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: accentColor

                        Text {
                            anchors.centerIn: parent
                            text: "👁"
                            font.pixelSize: 18
                        }
                    }

                    Text {
                        text: "Computer Vision Demo"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: primaryTextColor
                    }
                }

                Item { Layout.fillWidth: true }

                RowLayout {
                    spacing: 20

                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: successColor
                        }
                        Text {
                            text: "FPS: " + controller.fps
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: secondaryTextColor
                        }
                    }

                    RowLayout {
                        spacing: 6
                        Text {
                            text: "⚙️"
                            font.pixelSize: 12
                        }
                        Text {
                            text: "Device: " + controller.device
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: secondaryTextColor
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16

            // Left Panel
            Rectangle {
                Layout.preferredWidth: 300
                Layout.fillHeight: true
                color: surfaceColor
                radius: 12
                border.color: borderColor
                border.width: 1

                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 20
                    clip: true
                    contentWidth: availableWidth

                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        spacing: 24

                        // Computer Vision Tasks Section
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "Computer Vision Tasks"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: primaryTextColor
                            }

                            Repeater {
                                model: [
                                    {icon: "🖼️", name: "Semantic Segmentation", desc: "Pixel-level segmentation"}
                                ]

                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 70
                                    color: index === 0 ? selectedColor : "transparent"
                                    border.color: index === 0 ? accentColor : borderColor
                                    border.width: index === 0 ? 2 : 1
                                    radius: 8

                                    MouseArea {
                                        id: taskMouseArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: if (index !== 0) parent.color = hoverColor
                                        onExited: parent.color = index === 0 ? selectedColor : "transparent"
                                        onClicked: console.log("Selected:", modelData.name)
                                    }

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 12

                                        Text {
                                            text: modelData.icon
                                            font.pixelSize: 20
                                        }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 2

                                            Text {
                                                text: modelData.name
                                                font.pixelSize: 13
                                                font.weight: Font.Medium
                                                color: primaryTextColor
                                            }

                                            Text {
                                                text: modelData.desc
                                                font.pixelSize: 10
                                                color: secondaryTextColor
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Source Section
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Text {
                                text: "Source"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: primaryTextColor
                            }

                            ButtonGroup { id: sourceGroup }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                RadioButton {
                                    id: webcamRadio
                                    text: "Webcam"
                                    checked: true
                                    ButtonGroup.group: sourceGroup
                                    Material.accent: accentColor
                                    
                                    contentItem: Text {
                                        text: webcamRadio.text
                                        font.pixelSize: 14
                                        color: primaryTextColor
                                        leftPadding: webcamRadio.indicator.width + webcamRadio.spacing
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Rectangle {
                                    visible: webcamRadio.checked
                                    Layout.fillWidth: true
                                    height: 70
                                    color: surfaceVariantColor
                                    border.color: borderColor
                                    border.width: 1
                                    radius: 8

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 8

                                        Text {
                                            text: "Select Webcam Device"
                                            font.pixelSize: 12
                                            color: secondaryTextColor
                                        }

                                        ComboBox {
                                            Layout.fillWidth: true
                                            model: ["0", "1"]
                                            Material.accent: accentColor
                                            
                                            contentItem: Text {
                                                text: parent.displayText
                                                font.pixelSize: 12
                                                color: primaryTextColor
                                                leftPadding: 12
                                                verticalAlignment: Text.AlignVCenter
                                            }
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                RadioButton {
                                    id: gstRadio
                                    text: "GStreamer"
                                    ButtonGroup.group: sourceGroup
                                    Material.accent: accentColor
                                    
                                    contentItem: Text {
                                        text: gstRadio.text
                                        font.pixelSize: 14
                                        color: primaryTextColor
                                        leftPadding: gstRadio.indicator.width + gstRadio.spacing
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                }

                                Rectangle {
                                    visible: gstRadio.checked
                                    Layout.fillWidth: true
                                    height: 130
                                    color: surfaceVariantColor
                                    border.color: borderColor
                                    border.width: 1
                                    radius: 8

                                    ColumnLayout {
                                        anchors.fill: parent
                                        anchors.margins: 12
                                        spacing: 8

                                        Text {
                                            text: "Enter GStreamer Pipeline"
                                            font.pixelSize: 12
                                            color: secondaryTextColor
                                        }

                                        TextField {
                                            id: gstreamerInput
                                            placeholderText: "e.g. videotestsrc ! videoconvert ! appsink"
                                            Layout.fillWidth: true
                                            font.pixelSize: 11
                                            color: primaryTextColor
                                            Material.accent: accentColor
                                            
                                            background: Rectangle {
                                                color: surfaceColor
                                                border.color: borderColor
                                                border.width: 1
                                                radius: 4
                                            }
                                        }

                                        Button {
                                            text: "Set Source"
                                            Layout.alignment: Qt.AlignRight
                                            Material.accent: accentColor
                                            Material.background: accentColor
                                            
                                            contentItem: Text {
                                                text: parent.text
                                                font.pixelSize: 12
                                                color: "white"
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                            }

                                            onClicked: {
                                                if (gstRadio.checked) {
                                                    console.log("GStreamer string set:", gstreamerInput.text)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Main Content Area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: surfaceColor
                radius: 12
                border.color: borderColor
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true

                        Text {
                            text: "📹 Live Feed"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: primaryTextColor
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            spacing: 6
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: errorColor

                                SequentialAnimation on opacity {
                                    running: true
                                    loops: Animation.Infinite
                                    NumberAnimation { to: 0.3; duration: 1000 }
                                    NumberAnimation { to: 1.0; duration: 1000 }
                                }
                            }
                            Text {
                                text: "LIVE"
                                font.pixelSize: 11
                                color: errorColor
                                font.weight: Font.Bold
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: surfaceVariantColor
                        radius: 8
                        border.color: borderColor
                        border.width: 1
                        clip: true

                        Image {
                            id: inferenceImage
                            source: controller.sourceUrl
                            anchors.fill: parent
                            anchors.margins: 8
                            fillMode: Image.PreserveAspectFit
                            smooth: true

                            Rectangle {
                                anchors.centerIn: parent
                                width: 200
                                height: 120
                                color: surfaceColor
                                radius: 8
                                border.color: borderColor
                                border.width: 2
                                visible: inferenceImage.status !== Image.Ready

                                ColumnLayout {
                                    anchors.centerIn: parent
                                    spacing: 8

                                    Text {
                                        text: "📷"
                                        font.pixelSize: 32
                                        Layout.alignment: Qt.AlignHCenter
                                    }

                                    Text {
                                        text: "Waiting for video feed..."
                                        font.pixelSize: 12
                                        color: secondaryTextColor
                                        Layout.alignment: Qt.AlignHCenter
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}