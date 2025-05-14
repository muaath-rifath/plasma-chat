# Plasma Chat

A KDE Plasma 6 widget that provides an AI chat interface powered by Google's Gemini Flash 2.0 API.

## Features

- Clean integration with KDE Plasma 6
- Uses system theme colors for a native look
- Markdown rendering for responses
- Configurable font size
- Option to save conversation history
- Works in both desktop and panel contexts

## Requirements

- KDE Plasma 6
- Gemini API key from [Google AI Studio](https://ai.google.dev/)

## Installation

1. Clone this repository or download the source code
2. Run the installation script:

```bash
chmod +x install.sh
./install.sh
```

3. Add the widget to your desktop or panel:
   - Right-click on your desktop or panel
   - Select "Add Widgets..."
   - Search for "Plasma Chat" and drag it to your desktop or panel

## Configuration

1. Right-click on the widget and select "Configure Plasma Chat..."
2. Enter your Gemini API key
3. Adjust the font size if desired
4. Enable or disable conversation history saving

## Usage

1. Type your message in the input field
2. Press Enter or click the send button to send your message
3. The AI response will appear in the chat history

## Notes for Developers

The widget is built using:
- QML for the UI
- Kirigami for theme integration
- XMLHttpRequest for API communication
- StyledText for markdown rendering

### File Structure

- `package/metadata.json` - Widget definition
- `package/contents/ui/main.qml` - Main widget code
- `package/contents/ui/ChatView.qml` - Chat message display component
- `package/contents/ui/configGeneral.qml` - Configuration dialog
- `package/contents/config/main.xml` - Configuration structure

## Troubleshooting

If you encounter issues:

1. Ensure you have a valid Gemini API key
2. Check for permission issues with the widget installation
3. Try reinstalling the widget: `./install.sh`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- KDE Plasma team for their excellent desktop environment
- Google for providing the Gemini API 