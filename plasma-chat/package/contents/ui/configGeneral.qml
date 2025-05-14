import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root
    
    // Expose the configuration to the parent
    property alias cfg_apiKey: apiKeyField.text
    property alias cfg_fontSize: fontSizeSpinBox.value
    property alias cfg_saveConversations: saveConversationsCheckbox.checked
    
    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        
        // API Key section
        Kirigami.Heading {
            Kirigami.FormData.label: i18n("API Configuration")
            Kirigami.FormData.isSection: true
            level: 2
            text: i18n("API Configuration")
            visible: false
        }
        
        TextField {
            id: apiKeyField
            Kirigami.FormData.label: i18n("Gemini API Key:")
            Layout.fillWidth: true
            placeholderText: i18n("Enter your Gemini API key here")
            echoMode: apiKeyRevealButton.checked ? TextInput.Normal : TextInput.Password
            
            Button {
                id: apiKeyRevealButton
                anchors.right: parent.right
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                icon.name: checked ? "visibility" : "hint"
                checkable: true
                display: AbstractButton.IconOnly
                width: height
                ToolTip.text: checked ? i18n("Hide API key") : i18n("Show API key")
                ToolTip.visible: hovered
            }
        }
        
        Label {
            text: i18n("You can obtain an API key from <a href='https://ai.google.dev/'>Google AI Studio</a>")
            textFormat: Text.RichText
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            onLinkActivated: Qt.openUrlExternally(link)
        }
        
        // UI Settings
        Kirigami.Heading {
            Kirigami.FormData.label: i18n("Appearance")
            Kirigami.FormData.isSection: true
            level: 2
            text: i18n("Appearance")
            visible: false
        }
        
        Label {
            text: i18n("The widget automatically uses your system's color theme.")
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
        
        SpinBox {
            id: fontSizeSpinBox
            Kirigami.FormData.label: i18n("Font Size:")
            from: 8
            to: 24
            stepSize: 1
            value: 12
            
            textFromValue: function(value) {
                return value + " px";
            }
            
            valueFromText: function(text) {
                return parseInt(text);
            }
        }
        
        // Storage Settings
        Kirigami.Heading {
            Kirigami.FormData.label: i18n("Storage")
            Kirigami.FormData.isSection: true
            level: 2
            text: i18n("Storage")
            visible: false
        }
        
        CheckBox {
            id: saveConversationsCheckbox
            Kirigami.FormData.label: i18n("Conversation History:")
            text: i18n("Save conversations between sessions")
        }
    }
} 