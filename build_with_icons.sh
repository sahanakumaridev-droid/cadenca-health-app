#!/bin/bash

# Cadenca App - Build Script with Automatic Icon Updates
# Usage: ./build_with_icons.sh [android|ios|apk|appbundle]

echo "🚀 Cadenca App - Build with Auto Icon Update"
echo "============================================"

# Update launcher icons first
echo "📱 Step 1: Updating launcher icons..."
./scripts/update_launcher_icons.sh

if [ $? -ne 0 ]; then
    echo "⚠️  Icon update failed, but continuing with build..."
fi

# Determine build type
BUILD_TYPE=${1:-android}

echo ""
echo "📦 Step 2: Building app ($BUILD_TYPE)..."

case $BUILD_TYPE in
    "android"|"apk")
        echo "🤖 Building Android APK..."
        flutter clean
        flutter build apk --debug
        ;;
    "appbundle"|"aab")
        echo "🤖 Building Android App Bundle..."
        flutter clean
        flutter build appbundle --release
        ;;
    "ios")
        echo "🍎 Building iOS app..."
        flutter clean
        flutter build ios --debug
        ;;
    *)
        echo "❌ Unknown build type: $BUILD_TYPE"
        echo "📋 Usage: ./build_with_icons.sh [android|ios|apk|appbundle]"
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Build completed successfully!"
    echo "📱 Your app now uses the new Cadenca logo as launcher icon!"
    
    case $BUILD_TYPE in
        "android"|"apk")
            echo "📂 APK location: build/app/outputs/flutter-apk/app-debug.apk"
            ;;
        "appbundle"|"aab")
            echo "📂 AAB location: build/app/outputs/bundle/release/app-release.aab"
            ;;
        "ios")
            echo "📂 iOS build completed - open in Xcode to run on device/simulator"
            ;;
    esac
else
    echo "❌ Build failed!"
    exit 1
fi