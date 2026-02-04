#!/bin/bash

# Cadenca App - Automatic Launcher Icon Update Script
# This script runs before build to ensure launcher icons use the latest logo

echo "🎨 Cadenca App - Updating Launcher Icons..."

# Check if Python and Pillow are available
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3 not found. Please install Python3 to update launcher icons."
    exit 1
fi

# Check if Pillow is installed
python3 -c "import PIL" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "📦 Installing Pillow for image processing..."
    pip3 install Pillow
fi

# Check if logo file exists
LOGO_PATH="assets/images/cadenca_new_logo.png"
if [ ! -f "$LOGO_PATH" ]; then
    echo "⚠️  Logo file not found at: $LOGO_PATH"
    echo "📋 Please save your Cadenca logo as 'assets/images/cadenca_new_logo.png'"
    echo "🔄 Using existing launcher icons for now..."
    exit 0
fi

# Run the launcher icon generation script
echo "🚀 Generating launcher icons from your logo..."
python3 scripts/create_launcher_icon.py

if [ $? -eq 0 ]; then
    echo "✅ Launcher icons updated successfully!"
else
    echo "❌ Failed to update launcher icons"
    exit 1
fi

echo "🎉 Ready to build with your new Cadenca logo!"