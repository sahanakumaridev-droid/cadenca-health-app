# Update Launcher Icon with Your Cadenca Logo

## 🎯 Quick Setup (Recommended)

### 1. Save Your Logo
- Save your Cadenca logo as: `assets/images/cadenca_new_logo.png`
- Make sure it's high resolution (1024x1024+ pixels)

### 2. Use Automated Build Script
```bash
# Install dependencies (one time)
pip install Pillow

# Build with automatic icon updates
./build_with_icons.sh android    # For Android APK
./build_with_icons.sh ios        # For iOS
./build_with_icons.sh appbundle  # For Play Store
```

**That's it!** Your app will build with the new launcher icon automatically.

---

## 🔧 Manual Setup (Alternative)

### 1. Save Your Logo Image
- Save your new Cadenca logo image as: `assets/images/cadenca_new_logo.png`
- **Important**: Make sure it's high resolution (at least 1024x1024 pixels)
- The script will use your exact logo design

### 2. Install Required Dependencies
```bash
pip install Pillow
```

### 3. Generate Launcher Icons
```bash
python3 scripts/create_launcher_icon.py
```

### 4. Build and Test
```bash
flutter clean
flutter build apk --debug
```

---

## 🍎 Xcode Integration

For automatic icon updates in Xcode builds, see: `XCODE_BUILD_PHASE_SETUP.md`

---

## 📱 What Gets Created

**Android Icons (5 sizes):**
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)  
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

**iOS Icons (15 sizes):**
- All required sizes from 20x20 to 1024x1024 in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

## ✅ What This Does:
- Uses your **exact logo image** (no modifications)
- Resizes it to all required launcher icon sizes
- Maintains the light green background and dark circular design
- Works for both Android and iOS
- High quality resizing preserves logo clarity
- **Automatic**: Runs every time you build

## 🎉 Result:
When users install your app, they'll see your beautiful new Cadenca logo with the light green background as the app icon on their device home screen - no more beige logo!