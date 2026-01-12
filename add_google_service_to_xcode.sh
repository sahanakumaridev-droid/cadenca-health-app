#!/bin/bash

# Script to add GoogleService-Info.plist to Xcode project

echo "🔧 Adding GoogleService-Info.plist to Xcode project..."

# Open Xcode and add the file
open -a Xcode ios/Runner.xcworkspace

echo ""
echo "📋 Manual Steps in Xcode:"
echo "1. In Xcode Project Navigator, right-click on 'Runner' folder"
echo "2. Select 'Add Files to Runner...'"
echo "3. Navigate to ios/Runner/ and select 'GoogleService-Info.plist'"
echo "4. ✅ Check 'Copy items if needed'"
echo "5. ✅ Check 'Add to targets: Runner'"
echo "6. Click 'Add'"
echo ""
echo "After adding, close Xcode and run:"
echo "  flutter clean"
echo "  flutter pub get"
echo "  cd ios && pod install && cd .."
echo "  flutter run"
echo ""
echo "✅ This will fix the Google Sign-In crash!"
