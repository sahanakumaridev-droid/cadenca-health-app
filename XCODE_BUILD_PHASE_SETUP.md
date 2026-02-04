# Xcode Build Phase Setup for Automatic Icon Updates

## 🍎 Add Build Phase to Xcode Project

To automatically update app icons when building in Xcode, follow these steps:

### 1. Open Xcode Project
```bash
open ios/Runner.xcworkspace
```

### 2. Add Build Phase Script

1. **Select the Runner project** in the left sidebar
2. **Select the Runner target** (not the project)
3. **Go to "Build Phases" tab**
4. **Click the "+" button** at the top left
5. **Select "New Run Script Phase"**

### 3. Configure the Script

1. **Drag the new script phase** to the top (before "Dependencies")
2. **Name it**: "Update App Icons"
3. **In the script box**, paste this:

```bash
# Update App Icons with Cadenca Logo
echo "🍎 Updating Cadenca app icons..."

# Navigate to project root
cd "${SRCROOT}/../.."

# Run the icon update script
if [ -f "ios/scripts/update_app_icons.sh" ]; then
    ./ios/scripts/update_app_icons.sh
else
    echo "⚠️  Icon update script not found"
fi
```

4. **Check "Run script only when installing"** (optional - for faster debug builds)

### 4. Build Settings (Optional)

For better performance, you can also:

1. Go to **"Build Settings"** tab
2. Search for **"User-Defined"**
3. Add a new setting: `UPDATE_ICONS = YES`
4. Modify the script to check this setting

## 🚀 How It Works

Now whenever you:
- **Build in Xcode** → Icons automatically update
- **Archive for App Store** → Icons automatically update
- **Run on simulator/device** → Icons automatically update

## ✅ Alternative: Use Build Script

If you prefer command line, use our build script:

```bash
# Build Android with auto icon update
./build_with_icons.sh android

# Build iOS with auto icon update  
./build_with_icons.sh ios

# Build App Bundle for Play Store
./build_with_icons.sh appbundle
```

## 📱 Result

Your Cadenca logo will automatically be used as the app icon every time you build, ensuring consistency across all builds!