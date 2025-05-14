import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid

Item {
    id: chatViewRoot
    
    // Properties
    property var chatHistory: []
    property string apiKey: ""
    property bool isLoading: false
    property int fontSize: 12
    
    // Color properties
    property color textColor: Kirigami.Theme.textColor
    property color backgroundColor: Kirigami.Theme.backgroundColor
    
    // Signals
    signal sendMessage(string message)
    signal clearChat()
    
    // Background
    Rectangle {
        anchors.fill: parent
        color: backgroundColor
    }
    
    ColumnLayout {
        anchors.fill: parent
        spacing: 8
        
        // Title bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            color: Kirigami.Theme.highlightColor
            
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                
                PlasmaComponents3.Label {
                    text: "Plasma Chat"
                    color: Kirigami.Theme.highlightedTextColor
                    font.pixelSize: fontSize + 2
                    font.bold: true
                }
                
                Item { Layout.fillWidth: true }
                
                PlasmaComponents3.Button {
                    icon.name: "trash-empty"
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    onClicked: clearChat()
                    PlasmaComponents3.ToolTip.text: "Clear Chat"
                    PlasmaComponents3.ToolTip.visible: hovered
                    PlasmaComponents3.ToolTip.delay: Kirigami.Units.toolTipDelay
                }
                
                PlasmaComponents3.Button {
                    id: configureButton
                    icon.name: "configure"
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    onClicked: {
                        // Use parent reference instead of Plasmoid directly
                        if (parent && parent.parent && parent.parent.parent) {
                            var root = parent.parent.parent.parent;
                            if (root.Plasmoid) {
                                root.Plasmoid.action("configure").trigger();
                            }
                        }
                    }
                    PlasmaComponents3.ToolTip.text: "Configure"
                    PlasmaComponents3.ToolTip.visible: hovered
                    PlasmaComponents3.ToolTip.delay: Kirigami.Units.toolTipDelay
                }
            }
        }
        
        // Chat messages area
        ScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            ListView {
                id: chatListView
                clip: true
                spacing: 8
                model: chatHistory
                
                // Auto-scroll to bottom when new messages arrive
                onCountChanged: {
                    if (count > 0) {
                        positionViewAtEnd()
                    }
                }
                
                delegate: ChatMessageItem {
                    width: chatListView.width
                    message: modelData
                    fontSize: chatViewRoot.fontSize
                    textColor: chatViewRoot.textColor
                }
            }
        }
        
        // Input area with loading indicator
        Rectangle {
            id: inputArea
            Layout.fillWidth: true
            Layout.preferredHeight: 60
            color: Qt.alpha(backgroundColor, 0.8)
            border.color: Qt.alpha(Kirigami.Theme.textColor, 0.2)
            border.width: 1
            radius: 4
            
            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 8
                
                PlasmaComponents3.TextField {
                    id: messageInput
                    Layout.fillWidth: true
                    placeholderText: isLoading ? "Waiting for response..." : "Type your message here..."
                    font.pixelSize: fontSize
                    enabled: !isLoading
                    focus: true
                    
                    onAccepted: {
                        if (text.trim() !== "" && !isLoading) {
                            sendMessage(text)
                            text = ""
                        }
                    }
                }
                
                PlasmaComponents3.Button {
                    id: sendButton
                    icon.name: isLoading ? "process-working" : "go-next"
                    display: PlasmaComponents3.AbstractButton.IconOnly
                    enabled: !isLoading && messageInput.text.trim() !== ""
                    onClicked: {
                        sendMessage(messageInput.text)
                        messageInput.text = ""
                    }
                    PlasmaComponents3.ToolTip.text: isLoading ? "Processing..." : "Send message"
                    PlasmaComponents3.ToolTip.visible: hovered
                    PlasmaComponents3.ToolTip.delay: Kirigami.Units.toolTipDelay
                }
            }
        }
    }
    
    // Welcome message shown when chat is empty
    Loader {
        active: chatHistory.length === 0 && !isLoading
        anchors.centerIn: parent
        
        sourceComponent: Column {
            spacing: 16
            width: chatViewRoot.width * 0.8
            
            Kirigami.Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 64
                height: 64
                source: "dialog-messages"
            }
            
            PlasmaComponents3.Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: "Welcome to Plasma Chat"
                font.bold: true
                font.pixelSize: fontSize + 4
            }
            
            PlasmaComponents3.Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                text: apiKey ? 
                    "Chat with Gemini AI. Your conversations will " + 
                    (chatViewRoot.parent.saveConversations ? "be saved." : "not be saved.") : 
                    "Please set your Gemini API key in the widget settings."
                wrapMode: Text.Wrap
            }
        }
    }
    
    // Loading indicator
    Loader {
        active: isLoading && chatHistory.length === 0
        anchors.centerIn: parent
        
        sourceComponent: Column {
            spacing: 16
            
            PlasmaComponents3.BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                running: true
            }
            
            PlasmaComponents3.Label {
                text: "Contacting Gemini..."
            }
        }
    }
} 