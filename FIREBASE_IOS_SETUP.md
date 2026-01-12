# 🍎 Firebase iOS Setup Guide

## 📍 Step 1: Add GoogleService-Info.plist

Place your downloaded `GoogleService-Info.plist` file here:

```
health_app/ios/Runner/GoogleService-Info.plist
```

### Quick Command:
```bash
cp ~/Downloads/GoogleService-Info.plist health_app/ios/Runner/
```

### Manual Method:
1. Find `GoogleService-Info.plist` in your Downloads folder
2. Copy it
3. Paste into: `health_app/ios/Runner/` folder
4. Should be at the same level as `Info.plist`

## 📂 Final Structure:

```
health_app/
└── ios/
    └── Runner/
        ├── Info.plist
        ├── GoogleService-Info.plist  ← Add this file here!
        ├── Runner.entitlements
        ├── AppDelegate.swift
        └── ...
```

## 🔧 Step 2: Update Info.plist with REVERSED_CLIENT_ID

### 2.1 Open GoogleService-Info.plist
1. Open the `GoogleService-Info.plist` file you just added
2. Find the key: `REVERSED_CLIENT_ID`
3. Copy its value (looks like: `com.googleusercontent.apps.123456789-abc123xyz`)

### 2.2 Update Info.plist
Open `health_app/ios/Runner/Info.plist` and find this section:

```xml
<!-- Google Sign-In Configuration -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

**Replace this line:**
```xml
<string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
```

**With your actual REVERSED_CLIENT_ID:**
```xml
<string>com.googleusercontent.apps.123456789-abc123xyz</string>
```

## 📋 Example:

If your `REVERSED_CLIENT_ID` in `GoogleService-Info.plist` is:
```xml
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.987654321-xyz789abc</string>
```

Then update `Info.plist` to:
```xml
<string>com.googleusercontent.apps.987654321-xyz789abc</string>
```

## 🚀 Step 3: Rebuild the App

After adding both files:

```bash
cd health_app
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
```

## ✅ Checklist:

- [ ] Download `GoogleService-Info.plist` from Firebase Console
- [ ] Place `GoogleService-Info.plist` in `health_app/ios/Runner/`
- [ ] Open `GoogleService-Info.plist` and copy `REVERSED_CLIENT_ID` value
- [ ] Update `Info.plist` with your `REVERSED_CLIENT_ID`
- [ ] Run `flutter clean && flutter pub get`
- [ ] Run `cd ios && pod install && cd ..`
- [ ] Run `flutter run`
- [ ] Test Google Sign-In!

## 🎯 What to Test:

1. **Run the app on iOS device or simulator**
2. **Tap "Continue with Google"**
3. **Should open Google account picker**
4. **Select your Google account**
5. **Sign in successfully!**
6. **Go through onboarding**
7. **Reach home screen**

## ⚠️ Important Notes:

1. **REVERSED_CLIENT_ID is different from CLIENT_ID**
   - Use the one that starts with `com.googleusercontent.apps.`
   - NOT the one that ends with `.apps.googleusercontent.com`

2. **Bundle ID must match Firebase**
   - Your iOS Bundle ID: `com.cadenca.app`
   - Must match what you registered in Firebase Console

3. **Pod Install Required**
   - Always run `pod install` after adding GoogleService-Info.plist
   - This ensures Firebase SDK is properly configured

## 🔍 Troubleshooting:

### If Google Sign-In doesn't work:

1. **Check REVERSED_CLIENT_ID:**
   - Open `GoogleService-Info.plist`
   - Verify you copied the correct value
   - Make sure it starts with `com.googleusercontent.apps.`

2. **Check Bundle ID:**
   - In Firebase Console, verify iOS app bundle ID is: `com.cadenca.app`
   - In Xcode, verify bundle ID matches

3. **Clean and Rebuild:**
   ```bash
   flutter clean
   cd ios
   pod deintegrate
   pod install
   cd ..
   flutter run
   ```

## 📱 Testing on Simulator vs Device:

- **Simulator:** Google Sign-In works ✅
- **Real Device:** Google Sign-In works ✅
- **Apple Sign-In:** Only works on real device ⚠️

## 🎉 Success!

Once you complete these steps, Google Sign-In will work on iOS! The mock mode is already disabled, so it will use real Google authentication.

---

**Next:** After iOS setup is complete, test on both iOS and Android to ensure Google Sign-In works on both platforms! 🚀
