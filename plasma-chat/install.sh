#!/bin/bash

# Plasma Chat Installation Script

echo "Installing Plasma Chat widget..."

# Check if kpackagetool6 is available
if ! command -v kpackagetool6 &> /dev/null; then
    echo "Error: kpackagetool6 command not found."
    echo "Please install the plasma6-sdk package for your distribution."
    exit 1
fi

# Get the directory of this script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Create temporary directory for plugin
TMP_DIR=$(mktemp -d)
mkdir -p "$TMP_DIR/contents/ui"

# Copy files to temporary directory
cp -r "$SCRIPT_DIR/package/contents"/* "$TMP_DIR/contents/"
cp "$SCRIPT_DIR/package/metadata.json" "$TMP_DIR/"

# Try to remove existing installation (ignore errors)
if kpackagetool6 -l | grep -q "me.muaathrifath.plasmachat"; then
    echo "Removing existing installation..."
    kpackagetool6 -t Plasma/Applet -r me.muaathrifath.plasmachat 2>/dev/null || true
fi

# Also try to manually remove the directory
rm -rf ~/.local/share/plasma/plasmoids/me.muaathrifath.plasmachat

# Install the widget
echo "Installing widget..."
kpackagetool6 -t Plasma/Applet -i "$TMP_DIR"
INSTALL_RESULT=$?

# Clean up
rm -rf "$TMP_DIR"

# Check if installation was successful
if [ $INSTALL_RESULT -eq 0 ]; then
    echo "Installation completed successfully!"
    echo "You can now add the 'Plasma Chat' widget to your desktop or panel:"
    echo "1. Right-click on your desktop or panel"
    echo "2. Select 'Add Widgets...'"
    echo "3. Search for 'Plasma Chat' and drag it to your desktop or panel"
    echo ""
    echo "Note: You will need to configure your Gemini API key in the widget settings."
    echo "Right-click on the widget and select 'Configure Plasma Chat...'"
else
    echo "Installation failed with error code $INSTALL_RESULT!"
    echo "Try manually removing the widget with:"
    echo "rm -rf ~/.local/share/plasma/plasmoids/me.muaathrifath.plasmachat"
    echo "Then run this script again."
fi

exit 0 