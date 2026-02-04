#!/bin/bash

# Xcode Build Phase Script - Update App Icons
# This script runs automatically during Xcode build to update app icons

echo "🍎 Xcode Build Phase - Updating App Icons for Cadenca..."

# Navigate to project root (from ios folder)
cd "${SRCROOT}/../.."

# Check if logo exists
LOGO_PATH="assets/images/cadenca_new_logo.png"
if [ ! -f "$LOGO_PATH" ]; then
    echo "⚠️  Logo not found at: $LOGO_PATH"
    echo "🔄 Using existing app icons..."
    exit 0
fi

# Check if Python3 is available
if ! command -v python3 &> /dev/null; then
    echo "⚠️  Python3 not found. Skipping icon update."
    exit 0
fi

# Check if Pillow is installed
python3 -c "import PIL" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "📦 Installing Pillow..."
    pip3 install Pillow --user
fi

# Update the app icons
echo "🚀 Updating iOS app icons..."
python3 scripts/create_launcher_icon.py

if [ $? -eq 0 ]; then
    echo "✅ iOS app icons updated with your Cadenca logo!"
else
    echo "❌ Failed to update iOS app icons"
fi