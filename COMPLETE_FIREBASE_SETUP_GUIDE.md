# Complete Firebase Setup Guide for Cadenca

## Current Status

### ✅ Already Configured
- Firebase project created: **cadenca-e5c04**
- Android app registered: **com.cadenca.app**
- iOS app registered: **com.cadenca.app**
- google-services.json added (needs update)
- GoogleService-Info.plist added
- Apple Sign-In webAuthenticationOptions configured in code

### ⚠️ Needs Configuration
- SHA-1 and SHA-256 fingerprints for Android
- Google Sign-In enabled in Firebase Authentication
- OAuth clients verified in Google Cloud Console

---

## Step-by-Step Setup

### 1️⃣ Get SHA Fingerprints

Open Terminal and run:

```bash
cd ~/Desktop/HealthApp/health_app/android
./gradlew signingReport
```

**Copy these values:**
```
SHA1: [Copy this entire value]
SHA-256: [Copy this entire value]
```

**Example format:**
```
SHA1: 8A:F4:32:07:2D:9B:F1:BD:1B:AA:1F:C9:36:18:D4:0B:E4:C3:EC:97
SHA-256: 3F:9B:87:4A:0E:2D:C6:B8:9A:1F:3E:5D:7C:4B:6A:8E:9D:0C:1B:2A:3F:4E:5D:6C:7B:8A:9E:0D:1C:2B:3A:4F
```

---

### 2️⃣ Add SHA Fingerprints to Firebase

1. Go to: https://console.firebase.google.com
2. Select project: **cadenca-e5c04**
3. Click ⚙️ → **Project settings**
4. Scroll to **Your apps**
5. Find: **com.cadenca.app** (Android)
6. Click **Add fingerprint**
7. Paste **SHA-1** → Click **Save**
8. Click **Add fingerprint** again
9. Paste **SHA-256** → Click **Save**

**Result:** Firebase will auto-create Android OAuth client

---

### 3️⃣ Download Updated google-services.json

1. Still in Firebase Console (same page)
2. Scroll to Android app section
3. Click **Download google-services.json**
4. Replace file at: `health_app/android/app/google-services.json`

**Verify the new file has:**
```json
{
  "client_id": "XXXXX.apps.googleusercontent.com",
  "client_type": 1,  // ← This is the Android client!
  "android_info": {
    "package_name": "com.cadenca.app",
    "certificate_hash": "YOUR_SHA1_WITHOUT_COLONS"
  }
}
```

---

### 4️⃣ Enable Google Sign-In in Firebase

1. Firebase Console → **Authentication**
2. Click **Sign-in method** tab
3. Find **Google** → Click to expand
4. Toggle **Enable**
5. Set support email (your email)
6. Click **Save**

---

### 5️⃣ Enable Apple Sign-In in Firebase

1. Firebase Console → **Authentication**
2. Click **Sign-in method** tab
3. Find **Apple** → Click to expand
4. Toggle **Enable**
5. Click **Save**

**Note:** For full Apple Sign-In on Android, you'll need to configure Service ID in Apple Developer Console later. For now, basic setup works.

---

### 6️⃣ Verify Google Cloud OAuth Clients

1. Go to: https://console.cloud.google.com
2. Select project: **cadenca-e5c04**
3. Navigate to: **APIs & Services** → **Credentials**

**You should see 3 OAuth 2.0 Client IDs:**

| Type | Client ID | Status |
|------|-----------|--------|
| Android | XXXXX-XXXXX.apps.googleusercontent.com | ✅ Auto-created after SHA added |
| iOS | 1078110054358-7huse1q07sqt7s6hhuebb9o25dv4pcof | ✅ Already exists |
| Web | 1078110054358-eja48004misrn7lh52trd8qnrev46mf3 | ✅ Already exists |

**If Android client is missing:**
- Go back to Step 2 and verify SHA fingerprints were added
- Wait 1-2 minutes for auto-creation
- Refresh the page

---

### 7️⃣ Rebuild the APK

```bash
cd ~/Desktop/HealthApp/health_app
flutter clean
flutter pub get
flutter build apk --release
```

**New APK location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

---

### 8️⃣ Test on Android Device

Install the new APK and test:

**Google Sign-In:**
1. Click "Continue with Google"
2. Google account picker opens
3. Select account
4. ✅ Sign in successful

**Apple Sign-In:**
1. Click "Continue with Apple"
2. Web view opens with Apple login
3. Enter Apple ID and password
4. Complete 2FA if enabled
5. ✅ Sign in successful

---

## Troubleshooting

### Google Sign-In Still Shows Error

**Check:**
1. SHA fingerprints added correctly (no typos)
2. New google-services.json downloaded and replaced
3. APK rebuilt with `flutter clean` first
4. Google Sign-In enabled in Firebase Authentication
5. Android OAuth client exists in Google Cloud Console

### Apple Sign-In Shows Error

**Check:**
1. Apple Sign-In enabled in Firebase Authentication
2. `webAuthenticationOptions` configured in code (✅ already done)
3. Redirect URI matches Firebase project

### "Unable to locate a Java Runtime"

Install Java:
```bash
brew install openjdk@17
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

---

## Configuration Files Checklist

### Android
- [x] `android/app/google-services.json` (needs update with SHA)
- [x] `android/app/build.gradle.kts` (Google Services plugin added)
- [x] `android/settings.gradle.kts` (Google Services plugin added)
- [x] Package name: `com.cadenca.app`

### iOS
- [x] `ios/Runner/GoogleService-Info.plist`
- [x] `ios/Runner/Info.plist` (GIDClientID configured)
- [x] `ios/Runner/Runner.entitlements` (Apple Sign-In capability)
- [x] Bundle ID: `com.cadenca.app`

### Flutter Code
- [x] PlatformException handling (Google cancellation)
- [x] AuthCancelledException handling
- [x] Apple webAuthenticationOptions configured
- [x] Error messages user-friendly

---

## Expected Final Result

| Feature | Android | iOS |
|---------|---------|-----|
| Google Sign-In | ✅ Works | ✅ Works |
| Apple Sign-In | ✅ Works (web) | ✅ Works (native) |
| Email Sign-In | ✅ Works | ✅ Works |
| Cancel Handling | ✅ Silent | ✅ Silent |
| Error Messages | ✅ Clear | ✅ Clear |

---

## Quick Reference

**Firebase Project:** cadenca-e5c04
**Package Name:** com.cadenca.app
**Bundle ID:** com.cadenca.app

**Firebase Console:** https://console.firebase.google.com/project/cadenca-e5c04
**Google Cloud Console:** https://console.cloud.google.com/apis/credentials?project=cadenca-e5c04

---

## Next Steps After Setup

1. Test thoroughly on both Android and iOS
2. Add release keystore SHA for production builds
3. Configure Apple Service ID for better Android experience (optional)
4. Set up backend API integration
5. Test with multiple Google/Apple accounts

---

## Support

If you encounter issues:
1. Check Firebase Console for any warnings
2. Verify all OAuth clients exist in Google Cloud
3. Ensure SHA fingerprints match your keystore
4. Rebuild APK with `flutter clean` first
5. Check device logs for specific error codes
