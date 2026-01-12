# 📦 Cadenca Package Names

## ✅ Updated Package Names:

### iOS Bundle Identifier:
```
com.cadenca.flutterAuthApp
```

### Android Package Name:
```
com.cadenca.flutter_auth_app
```

## 🔥 Firebase Setup Instructions:

### 1. Add iOS App to Firebase:
- Click "+ Add app" in Firebase Console
- Select **iOS** (Apple icon)
- **Bundle ID:** `com.cadenca.flutterAuthApp`
- **App nickname:** Cadenca iOS
- Click "Register app"
- Download `GoogleService-Info.plist`
- Place in: `health_app/ios/Runner/`

### 2. Add Android App to Firebase:
- Click "+ Add app" in Firebase Console (again)
- Select **Android** (Android icon)
- **Package name:** `com.cadenca.flutter_auth_app`
- **App nickname:** Cadenca Android
- Click "Register app"
- Download `google-services.json`
- Place in: `health_app/android/app/`

### 3. Enable Google Sign-In:
- Go to **Authentication** in Firebase Console
- Click **"Get started"** (if not enabled)
- Go to **"Sign-in method"** tab
- Click **"Google"** provider
- Toggle **"Enable"**
- Click **"Save"**

### 4. Configure iOS (Info.plist):
1. Open the downloaded `GoogleService-Info.plist`
2. Find the `REVERSED_CLIENT_ID` key
3. Copy its value (looks like: `com.googleusercontent.apps.123456789-abc123xyz`)
4. Open `health_app/ios/Runner/Info.plist`
5. Find this line:
   ```xml
   <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
   ```
6. Replace `YOUR-CLIENT-ID` with your actual REVERSED_CLIENT_ID

### 5. Configure Android (google-services.json):
- Just copy the downloaded `google-services.json` to `health_app/android/app/`
- That's it! Android configuration is automatic.

### 6. Disable Mock Mode:
The mock mode is already disabled. Real Google Sign-In will work once Firebase is configured.

### 7. Rebuild the App:
```bash
cd health_app
flutter clean
flutter pub get
cd ios
pod install
cd ..
flutter run
```

## 📋 Files Changed:

### Android:
- ✅ `android/app/build.gradle.kts` - Updated namespace and applicationId
- ✅ `android/app/src/main/kotlin/com/cadenca/flutter_auth_app/MainActivity.kt` - Moved and updated package

### iOS:
- ✅ `ios/Runner.xcodeproj/project.pbxproj` - Updated PRODUCT_BUNDLE_IDENTIFIER (3 configurations)

## 🎯 Summary:

**Old Package Names:**
- iOS: `com.example.flutterAuthApp`
- Android: `com.example.flutter_auth_app`

**New Package Names:**
- iOS: `com.cadenca.flutterAuthApp`
- Android: `com.cadenca.flutter_auth_app`

All references have been updated globally! 🎉

## ⚠️ Important Notes:

1. **Firebase Setup Required:**
   - You must add both iOS and Android apps to Firebase
   - Use the new package names above
   - Download both config files

2. **Clean Build Required:**
   - After changing package names, always run `flutter clean`
   - This ensures all cached files are regenerated

3. **Apple Developer Account:**
   - For production iOS builds, you'll need to register the new bundle ID
   - Current development team: `9233Q4H4ZQ`

4. **Google Play Console:**
   - For production Android builds, register the new package name
   - Package name cannot be changed after first upload

## 🚀 Next Steps:

1. Go to Firebase Console
2. Add iOS app with: `com.cadenca.flutterAuthApp`
3. Add Android app with: `com.cadenca.flutter_auth_app`
4. Download both config files
5. Place them in the correct locations
6. Update Info.plist with REVERSED_CLIENT_ID
7. Run `flutter clean && flutter pub get && cd ios && pod install && cd .. && flutter run`

Your app is now branded as Cadenca! 🎊
