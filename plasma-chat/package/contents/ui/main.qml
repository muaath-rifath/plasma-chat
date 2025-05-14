import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components as PlasmaComponents
import QtQuick.LocalStorage as LS
import Qt.labs.platform
import org.kde.kirigami as Kirigami

PlasmoidItem {
    id: root
    
    // Configuration properties
    property string apiKey: Plasmoid.configuration.apiKey || ""
    property int fontSize: Plasmoid.configuration.fontSize || 12
    property bool saveConversations: Plasmoid.configuration.saveConversations || false
    
    // Internal properties
    property var chatHistory: []
    property bool isExpanded: false
    property bool isLoading: false
    property string dbName: "PlasmaChat"
    property string dbVersion: "1.0"
    property string dbDisplayName: "Plasma Chat Database"
    property int dbEstimatedSize: 10000
    
    // Compact representation (the icon in the panel)
    compactRepresentation: Item {
        id: compactRoot
        
        PlasmaComponents.ToolButton {
            anchors.fill: parent
            icon.name: "dialog-messages"
            onClicked: {
                isExpanded = !isExpanded
                if (isExpanded) {
                    Plasmoid.expanded = true
                }
            }
            
            PlasmaComponents.ToolTip {
                text: i18n("Plasma Chat")
            }
        }
    }
    
    // Full representation (the expanded view)
    fullRepresentation: Item {
        id: fullRoot
        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 25
        Layout.preferredWidth: Kirigami.Units.gridUnit * 25
        Layout.preferredHeight: Kirigami.Units.gridUnit * 30
        
        // Load the chat view
        ChatView {
            id: chatView
            anchors.fill: parent
            apiKey: root.apiKey
            fontSize: root.fontSize
            chatHistory: root.chatHistory
            isLoading: root.isLoading
            
            onSendMessage: function(message) {
                root.sendMessage(message)
            }
            
            onClearChat: function() {
                root.clearChat()
            }
        }
    }
    
    // Database functions
    function getDatabase() {
        return LS.LocalStorage.openDatabaseSync(
            dbName, dbVersion, dbDisplayName, dbEstimatedSize
        );
    }
    
    function initDatabase() {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('CREATE TABLE IF NOT EXISTS messages(id INTEGER PRIMARY KEY AUTOINCREMENT, role TEXT, content TEXT, timestamp INTEGER)');
        });
    }
    
    function loadMessages() {
        if (!saveConversations) return;
        
        var db = getDatabase();
        var messages = [];
        
        db.transaction(function(tx) {
            var results = tx.executeSql('SELECT * FROM messages ORDER BY timestamp ASC');
            for (var i = 0; i < results.rows.length; i++) {
                var row = results.rows.item(i);
                messages.push({
                    role: row.role,
                    content: row.content
                });
            }
        });
        
        chatHistory = messages;
    }
    
    function saveMessage(role, content) {
        if (!saveConversations) return;
        
        var db = getDatabase();
        var timestamp = Date.now();
        
        db.transaction(function(tx) {
            tx.executeSql('INSERT INTO messages(role, content, timestamp) VALUES(?, ?, ?)', 
                [role, content, timestamp]);
        });
    }
    
    function clearDatabase() {
        var db = getDatabase();
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM messages');
        });
    }
    
    // Chat functions
    function sendMessage(message) {
        if (!message.trim() || isLoading) return;
        
        // Add user message to chat
        chatHistory.push({ role: "user", content: message });
        saveMessage("user", message);
        
        // Set loading state
        isLoading = true;
        
        // Make API request to Gemini
        var xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                isLoading = false;
                
                if (xhr.status === 200) {
                    try {
                        var response = JSON.parse(xhr.responseText);
                        var botMessage = response.candidates[0].content.parts[0].text;
                        
                        // Add bot response to chat
                        chatHistory.push({ role: "model", content: botMessage });
                        saveMessage("model", botMessage);
                        
                        // Force update
                        var temp = chatHistory;
                        chatHistory = [];
                        chatHistory = temp;
                    } catch (e) {
                        console.error("Error parsing response:", e);
                        handleApiError("Failed to parse response");
                    }
                } else {
                    console.error("API error:", xhr.status, xhr.responseText);
                    handleApiError("API request failed");
                }
            }
        };
        
        // Prepare request to Gemini API using the correct model
        xhr.open("POST", "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=" + apiKey);
        xhr.setRequestHeader("Content-Type", "application/json");
        
        // Create conversation history for context
        var requestMessages = [];
        for (var i = 0; i < chatHistory.length; i++) {
            requestMessages.push({
                role: chatHistory[i].role === "model" ? "model" : "user",
                parts: [{ text: chatHistory[i].content }]
            });
        }
        
        // Send the request
        xhr.send(JSON.stringify({
            contents: requestMessages,
            generationConfig: {
                responseMimeType: "text/plain"
            }
        }));
    }
    
    function handleApiError(message) {
        chatHistory.push({ 
            role: "error", 
            content: message + ". Please check your API key and internet connection."
        });
        
        // Force update
        var temp = chatHistory;
        chatHistory = [];
        chatHistory = temp;
    }
    
    function clearChat() {
        chatHistory = [];
        clearDatabase();
    }
    
    // Initialize
    Component.onCompleted: {
        initDatabase();
        loadMessages();
    }
}
