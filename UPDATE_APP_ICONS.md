# Update App Icons with New Cadenca Logo

## Steps to Update App Icons:

### 1. Save the New Logo
- Save the new Cadenca logo image (with light green background) as `assets/images/cadenca_logo_light_green.png`
- Make sure it's a high-resolution PNG (at least 1024x1024 pixels)

### 2. Install Required Dependencies
```bash
pip install Pillow
```

### 3. Run the Icon Generation Script
```bash
python3 scripts/generate_app_icons.py
```

This will automatically generate all required app icon sizes for both Android and iOS:

**Android Icons Generated:**
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

**iOS Icons Generated:**
- All required sizes from 20x20 to 1024x1024 in `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### 4. Clean and Rebuild
```bash
flutter clean
flutter build apk --debug
```

### 5. Test the New Icons
- Install the APK on an Android device to see the new app icon
- For iOS, build and run on a simulator or device

## What's Updated:

✅ **In-App Logo**: Updated `CadencaLogo` widget to use modern design with dark circular "n" and "cadenca" text
✅ **App Icons**: Script ready to generate all required icon sizes from your new logo
✅ **Consistent Branding**: Logo now matches the new light green design instead of beige

The app will now display the new modern Cadenca logo throughout the interface and as the app icon when installed on devices.