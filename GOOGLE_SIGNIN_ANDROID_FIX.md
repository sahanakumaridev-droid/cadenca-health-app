# Google Sign-In Android Configuration Fix

## Problem
Getting error: "Google Sign-In configuration error. Please check your Firebase setup"

## Root Cause
The `google-services.json` file is missing the Android OAuth client (client_type 1). It only has:
- client_type 3 (Web client)
- client_type 2 (iOS client)

## Solution: Add Android OAuth Client in Firebase Console

### Step 1: Get Your SHA-1 Certificate Fingerprint

Run this command in your terminal:

```bash
cd android
./gradlew signingReport
```

Look for the **SHA-1** fingerprint under `Variant: debug` section. It will look like:
```
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
```

Copy this SHA-1 fingerprint.

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **cadenca-e5c04**
3. Click the gear icon ⚙️ → **Project settings**
4. Scroll down to **Your apps** section
5. Find your Android app: **com.cadenca.app**
6. Click **Add fingerprint**
7. Paste your SHA-1 fingerprint
8. Click **Save**

### Step 3: Download New google-services.json

1. Still in Firebase Console, in the same Android app section
2. Click **Download google-services.json**
3. Replace the file at: `health_app/android/app/google-services.json`

The new file should now include an Android OAuth client (client_type 1) that looks like:

```json
{
  "client_id": "XXXXX-XXXXX.apps.googleusercontent.com",
  "client_type": 1,
  "android_info": {
    "package_name": "com.cadenca.app",
    "certificate_hash": "AABBCCDDEEFF00112233445566778899AABBCCDD"
  }
}
```

### Step 4: Rebuild the APK

```bash
cd health_app
flutter clean
flutter build apk --release
```

## Alternative: Use Debug Keystore SHA-1

If you're testing with debug builds, you can get the debug keystore SHA-1:

**macOS/Linux:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Windows:**
```bash
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## Verification

After following these steps:
1. Install the new APK on your Android device
2. Click "Continue with Google"
3. Google account picker should open
4. Select an account
5. You should be signed in successfully

## Current Configuration Status

Your current `google-services.json` has:
- ✓ Project ID: cadenca-e5c04
- ✓ Package name: com.cadenca.app
- ✓ Web OAuth client (for web)
- ✓ iOS OAuth client (for iOS)
- ✗ **MISSING: Android OAuth client** ← This is the issue!

## Notes

- The SHA-1 fingerprint is tied to your signing key
- Debug builds use the debug keystore
- Release builds need the release keystore SHA-1
- You can add multiple SHA-1 fingerprints (debug + release)
