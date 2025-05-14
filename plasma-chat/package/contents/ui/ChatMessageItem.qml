import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
    id: root
    
    // Required properties
    property var message: null
    property int fontSize: 12
    property color textColor: Kirigami.Theme.textColor
    
    // Computed properties 
    property bool isUserMessage: message ? message.role === "user" : false
    property bool isError: message ? message.role === "error" : false
    
    // Size the item based on content
    height: messageLayout.height + 20
    
    // Message bubble color based on role
    property color bubbleColor: {
        if (!message) return Qt.alpha(Kirigami.Theme.backgroundColor, 0.6);
        
        if (isUserMessage) {
            return Qt.alpha(Kirigami.Theme.highlightColor, 0.2);
        } else if (isError) {
            return Qt.alpha(Kirigami.Theme.negativeTextColor, 0.1);
        } else {
            return Qt.alpha(Kirigami.Theme.backgroundColor, 0.6);
        }
    }
    
    // Message bubble
    Rectangle {
        id: messageBubble
        width: messageLayout.width + 24
        height: messageLayout.height + 16
        radius: 10
        color: bubbleColor
        border.color: Qt.alpha(Kirigami.Theme.textColor, 0.1)
        border.width: 1
        anchors.right: isUserMessage ? parent.right : undefined
        anchors.left: isUserMessage ? undefined : parent.left
    }
    
    // Message content
    ColumnLayout {
        id: messageLayout
        width: Math.min(parent.width * 0.9, implicitWidth)
        anchors.left: isUserMessage ? undefined : parent.left
        anchors.right: isUserMessage ? parent.right : undefined
        anchors.leftMargin: isUserMessage ? 0 : 8
        anchors.rightMargin: isUserMessage ? 8 : 0
        anchors.verticalCenter: parent.verticalCenter
        spacing: 4
        
        // Sender
        PlasmaComponents3.Label {
            text: {
                if (!message) return "";
                
                switch(message.role) {
                    case "user": return "You";
                    case "model": return "Gemini";
                    case "error": return "Error";
                    default: return message.role;
                }
            }
            font.bold: true
            font.pixelSize: fontSize - 2
            color: isError ? Kirigami.Theme.negativeTextColor : textColor
        }
        
        // Message text
        TextEdit {
            id: textDisplay
            Layout.fillWidth: true
            Layout.preferredWidth: messageLayout.width
            wrapMode: TextEdit.Wrap
            readOnly: true
            selectByMouse: true
            textFormat: Text.StyledText
            font.pixelSize: fontSize
            color: isError ? Kirigami.Theme.negativeTextColor : textColor
            
            // Set background to transparent
            Rectangle {
                z: -1
                anchors.fill: parent
                color: "transparent"
            }
            
            Component.onCompleted: {
                text = formatMarkdown(message ? message.content : "");
                // Adjust height based on content
                height = contentHeight;
            }
            
            // Convert basic markdown to StyledText HTML
            function formatMarkdown(markdown) {
                if (!markdown) return "";
                
                var html = markdown;
                
                // Handle code blocks
                html = html.replace(/```([^`]+)```/g, '<pre style="background-color: ' + Qt.alpha(Kirigami.Theme.complementaryBackgroundColor, 0.5) + '; padding: 8px; border-radius: 4px; font-family: monospace;">$1</pre>');
                
                // Handle inline code
                html = html.replace(/`([^`]+)`/g, '<code style="background-color: ' + Qt.alpha(Kirigami.Theme.complementaryBackgroundColor, 0.3) + '; padding: 2px 4px; border-radius: 3px; font-family: monospace;">$1</code>');
                
                // Handle bold
                html = html.replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>');
                
                // Handle italic
                html = html.replace(/\*([^*]+)\*/g, '<i>$1</i>');
                
                // Handle links
                html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2" style="color: ' + Kirigami.Theme.linkColor + ';">$1</a>');
                
                // Handle headers
                html = html.replace(/^### (.*$)/gm, '<h3 style="margin: 0;">$1</h3>');
                html = html.replace(/^## (.*$)/gm, '<h2 style="margin: 0;">$1</h2>');
                html = html.replace(/^# (.*$)/gm, '<h1 style="margin: 0;">$1</h1>');
                
                // Handle lists
                html = html.replace(/^\* (.*$)/gm, '• $1<br>');
                html = html.replace(/^(\d+)\. (.*$)/gm, '$1. $2<br>');
                
                // Handle blockquotes
                var quoteColor = Qt.alpha(Kirigami.Theme.disabledTextColor, 0.8);
                html = html.replace(/^> (.*$)/gm, '<div style="border-left: 3px solid ' + quoteColor + '; padding-left: 8px; color: ' + quoteColor + ';">$1</div>');
                
                // Handle paragraphs with line breaks
                html = html.replace(/\n\n/g, '<br><br>');
                html = html.replace(/\n/g, '<br>');
                
                return html;
            }
            
            // Handle links
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
} 