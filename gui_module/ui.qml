import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

ApplicationWindow {
    visible: true
    width: Screen.width * 0.9
    height: Screen.height * 0.9
    title: "Computer Vision Studio"
    color: "#f0f4f8"
    
    Component.onCompleted: {
        x = (Screen.width - width) / 2
        y = (Screen.height - height) / 2
    }
    
    // Main container
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16
        
        // Top bar with title and status
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: "#ffffff"
            radius: 12
            border.color: "#e2e8f0"
            border.width: 1
            
            // Drop shadow effect
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 2
                color: "#00000008"
                radius: parent.radius
                z: -1
            }
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 16
                
                // App title with icon
                RowLayout {
                    spacing: 12
                    
                    Rectangle {
                        width: 32
                        height: 32
                        radius: 8
                        color: "#3b82f6"
                        
                        Text {
                            anchors.centerIn: parent
                            text: "👁"
                            font.pixelSize: 18
                        }
                    }
                    
                    Text {
                        text: "Computer Vision Studio"
                        font.pixelSize: 20
                        font.weight: Font.Bold
                        color: "#1e293b"
                    }
                }
                
                Item { Layout.fillWidth: true }
                
                // Status indicators
                RowLayout {
                    spacing: 20
                    
                    // FPS indicator
                    RowLayout {
                        spacing: 6
                        Rectangle {
                            width: 8
                            height: 8
                            radius: 4
                            color: "#22c55e"
                        }
                        Text {
                            text: "FPS: " + controller.fps
                            font.pixelSize: 12
                            color: "#64748b"
                            font.weight: Font.Medium
                        }
                    }

                    // Device indicator
                    RowLayout {
                        spacing: 6
                        Text {
                            text: "️⚙️"
                            font.pixelSize: 12
                        }
                        Text {
                            text: "Device: " + controller.device
                            font.pixelSize: 12
                            color: "#64748b"
                            font.weight: Font.Medium
                        }
                    }
                }
            }
        }
        
        // Main content area
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 16
            
            // Left Sidebar - Control Panel
            Rectangle {
                Layout.preferredWidth: 280
                Layout.fillHeight: true
                color: "#ffffff"
                radius: 12
                border.color: "#e2e8f0"
                border.width: 1
                
                // Drop shadow
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 2
                    color: "#00000008"
                    radius: parent.radius
                    z: -1
                }
                
                ScrollView {
                    anchors.fill: parent
                    anchors.margins: 20
                    clip: true
                    
                    ColumnLayout {
                        width: parent.width
                        spacing: 24
                        
                        // Computer Vision Tasks Section
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "Computer Vision Tasks"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: "#1e293b"
                            }
                            
                            // Task selection cards
                            Repeater {
                                model: [
                                    {icon: "🔍", name: "Object Detection", desc: "Detect and classify objects"},
                                    {icon: "👤", name: "Face Recognition", desc: "Identify faces and emotions"},
                                    {icon: "🚗", name: "Vehicle Tracking", desc: "Track vehicles in real-time"},
                                    {icon: "📏", name: "Pose Estimation", desc: "Human pose detection"},
                                    {icon: "🎯", name: "Instance Segmentation", desc: "Pixel-level object detection"}
                                ]
                                
                                Rectangle {
                                    Layout.fillWidth: true
                                    height: 70
                                    color: index === 0 ? "#dbeafe" : "#f8fafc"
                                    border.color: index === 0 ? "#3b82f6" : "#e2e8f0"
                                    border.width: index === 0 ? 2 : 1
                                    radius: 8
                                    
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        onEntered: parent.color = "#f1f5f9"
                                        onExited: parent.color = index === 0 ? "#dbeafe" : "#f8fafc"
                                        onClicked: {
                                            // Handle task selection
                                            console.log("Selected:", modelData.name)
                                        }
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
                                                color: "#1e293b"
                                            }
                                            
                                            Text {
                                                text: modelData.desc
                                                font.pixelSize: 10
                                                color: "#64748b"
                                                wrapMode: Text.WordWrap
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Model Configuration Section
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12
                            
                            Text {
                                text: "Model Configuration"
                                font.pixelSize: 16
                                font.weight: Font.Bold
                                color: "#1e293b"
                            }
                            
                            // Model selection
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                Text {
                                    text: "Model Version"
                                    font.pixelSize: 12
                                    color: "#64748b"
                                    font.weight: Font.Medium
                                }
                                
                                ComboBox {
                                    Layout.fillWidth: true
                                    model: ["YOLOv8n (Fast)", "YOLOv8s (Balanced)", "YOLOv8m (Accurate)", "YOLOv8l (High Precision)"]
                                    currentIndex: 0
                                }
                            }
                            
                            // Confidence threshold
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                
                                RowLayout {
                                    Text {
                                        text: "Confidence Threshold"
                                        font.pixelSize: 12
                                        color: "#64748b"
                                        font.weight: Font.Medium
                                    }
                                    Item { Layout.fillWidth: true }
                                    Text {
                                        text: Math.round(confidenceSlider.value * 100) + "%"
                                        font.pixelSize: 12
                                        color: "#3b82f6"
                                        font.weight: Font.Bold
                                    }
                                }
                                
                                Slider {
                                    id: confidenceSlider
                                    Layout.fillWidth: true
                                    from: 0.1
                                    to: 0.9
                                    value: 0.5
                                    stepSize: 0.05
                                }
                            }
                        }
                        
                        // Control buttons
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8
                            
                            Button {
                                Layout.fillWidth: true
                                text: "▶️ Start Processing"
                                font.pixelSize: 13
                                font.weight: Font.Medium
                            }
                            
                            Button {
                                Layout.fillWidth: true
                                text: "⏸️ Pause"
                                font.pixelSize: 13
                            }
                        }
                    }
                }
            }
            
            // Image Display Area
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#ffffff"
                radius: 12
                border.color: "#e2e8f0"
                border.width: 1
                
                // Drop shadow
                Rectangle {
                    anchors.fill: parent
                    anchors.topMargin: 2
                    color: "#00000008"
                    radius: parent.radius
                    z: -1
                }
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12
                    
                    // Image area header
                    RowLayout {
                        Layout.fillWidth: true
                        
                        Text {
                            text: "📹 Live Feed"
                            font.pixelSize: 14
                            font.weight: Font.Medium
                            color: "#1e293b"
                        }
                        
                        Item { Layout.fillWidth: true }
                        
                        // Recording indicator
                        RowLayout {
                            spacing: 6
                            Rectangle {
                                width: 8
                                height: 8
                                radius: 4
                                color: "#ef4444"
                                
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
                                color: "#ef4444"
                                font.weight: Font.Bold
                            }
                        }
                    }
                    
                    // Main image display
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: "#f8fafc"
                        radius: 8
                        border.color: "#e2e8f0"
                        border.width: 1
                        clip: true
                        
                        Image {
                            id: inferenceImage
                            source: controller.sourceUrl
                            anchors.fill: parent
                            anchors.margins: 8
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            
                            // Placeholder when no image
                            Rectangle {
                                anchors.centerIn: parent
                                width: 200
                                height: 120
                                color: "#f1f5f9"
                                radius: 8
                                border.color: "#cbd5e1"
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
                                        color: "#64748b"
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