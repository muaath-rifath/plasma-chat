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
        width: Math.min(parent.width * 0.9, implicitWidth || parent.width * 0.85)
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
            Layout.preferredWidth: parent.width
            Layout.maximumWidth: parent.width
            width: parent.width
            wrapMode: TextEdit.Wrap
            readOnly: true
            selectByMouse: true
            textFormat: Text.RichText
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
            
            // Enhanced markdown to HTML conversion
            function formatMarkdown(markdown) {
                if (!markdown) return "";
                
                var html = markdown;
                
                // Preprocessing to handle nested markdown within code blocks
                var codeBlocks = [];
                var codeBlockRegex = /```([\s\S]*?)```/g;
                var codeBlockMatch;
                var blockCount = 0;
                
                while ((codeBlockMatch = codeBlockRegex.exec(markdown)) !== null) {
                    var placeholder = "CODE_BLOCK_" + blockCount + "_PLACEHOLDER";
                    codeBlocks.push({
                        placeholder: placeholder,
                        content: codeBlockMatch[1]
                    });
                    html = html.replace(codeBlockMatch[0], placeholder);
                    blockCount++;
                }
                
                // Handle inline code the same way
                var inlineCodeBlocks = [];
                var inlineCodeRegex = /`([^`]+)`/g;
                var inlineCodeMatch;
                var inlineCount = 0;
                
                while ((inlineCodeMatch = inlineCodeRegex.exec(html)) !== null) {
                    var placeholder = "INLINE_CODE_" + inlineCount + "_PLACEHOLDER";
                    inlineCodeBlocks.push({
                        placeholder: placeholder,
                        content: inlineCodeMatch[1]
                    });
                    html = html.replace(inlineCodeMatch[0], placeholder);
                    inlineCount++;
                }
                
                // Process normal markdown
                // Handle headers with proper styling
                html = html.replace(/^### (.*$)/gm, '<h3 style="margin: 6px 0; font-size: ' + (fontSize + 2) + 'px;">$1</h3>');
                html = html.replace(/^## (.*$)/gm, '<h2 style="margin: 8px 0; font-size: ' + (fontSize + 4) + 'px;">$1</h2>');
                html = html.replace(/^# (.*$)/gm, '<h1 style="margin: 10px 0; font-size: ' + (fontSize + 6) + 'px;">$1</h1>');
                
                // Handle bold
                html = html.replace(/\*\*([^*]+)\*\*/g, '<b>$1</b>');
                html = html.replace(/__([^_]+)__/g, '<b>$1</b>');
                
                // Handle italic
                html = html.replace(/\*([^*]+)\*/g, '<i>$1</i>');
                html = html.replace(/_([^_]+)_/g, '<i>$1</i>');
                
                // Handle links with proper Kirigami styling
                html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g, 
                    '<a href="$2" style="color: ' + Kirigami.Theme.linkColor + 
                    '; text-decoration: none;">$1</a>');
                
                // Handle lists with proper indentation
                html = html.replace(/^\* (.*$)/gm, 
                    '<div style="margin-left: 10px;">• $1</div>');
                html = html.replace(/^- (.*$)/gm, 
                    '<div style="margin-left: 10px;">• $1</div>');
                
                // Handle ordered lists
                html = html.replace(/^(\d+)\. (.*$)/gm, 
                    '<div style="margin-left: 10px;">$1. $2</div>');
                
                // Handle blockquotes with Kirigami styling
                var quoteColor = Qt.alpha(Kirigami.Theme.disabledTextColor, 0.8);
                html = html.replace(/^> (.*$)/gm, 
                    '<div style="border-left: 3px solid ' + quoteColor + 
                    '; padding-left: 8px; margin: 5px 0; color: ' + quoteColor + ';">$1</div>');
                
                // Handle horizontal rules
                html = html.replace(/^---$/gm, 
                    '<hr style="border: 0; height: 1px; background-color: ' + 
                    Qt.alpha(Kirigami.Theme.textColor, 0.3) + '; margin: 10px 0;" />');
                
                // Replace code block placeholders with properly styled code blocks
                for (var i = 0; i < codeBlocks.length; i++) {
                    var codeBackground = Qt.alpha(Kirigami.Theme.complementaryBackgroundColor, 0.5);
                    var codeBorder = Qt.alpha(Kirigami.Theme.textColor, 0.2);
                    
                    html = html.replace(
                        codeBlocks[i].placeholder, 
                        '<pre style="background-color: ' + codeBackground + 
                        '; color: ' + Kirigami.Theme.textColor + 
                        '; padding: 10px; border-radius: 5px; ' +
                        'border: 1px solid ' + codeBorder + '; ' + 
                        'font-family: monospace; overflow-x: auto; ' +
                        'white-space: pre-wrap; word-wrap: break-word; ' +
                        'margin: 5px 0; line-height: 1.5;">' + 
                        codeBlocks[i].content + '</pre>'
                    );
                }
                
                // Replace inline code placeholders
                for (var j = 0; j < inlineCodeBlocks.length; j++) {
                    var inlineCodeBackground = Qt.alpha(Kirigami.Theme.complementaryBackgroundColor, 0.3);
                    
                    html = html.replace(
                        inlineCodeBlocks[j].placeholder, 
                        '<code style="background-color: ' + inlineCodeBackground + 
                        '; padding: 2px 4px; border-radius: 3px; ' + 
                        'font-family: monospace;">' + 
                        inlineCodeBlocks[j].content + '</code>'
                    );
                }
                
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