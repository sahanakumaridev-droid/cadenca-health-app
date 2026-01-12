# Get SHA-1 and SHA-256 Fingerprints for Firebase

## Quick Commands to Run

### Option 1: Using Gradle (Recommended)

Open Terminal and run:

```bash
cd ~/Desktop/HealthApp/health_app/android
./gradlew signingReport
```

**Look for this section in the output:**

```
Variant: debug
Config: debug
Store: ~/.android/debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX:...
SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
SHA-256: 11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11
Valid until: ...
```

**Copy both:**
- SHA1 (20 bytes, separated by colons)
- SHA-256 (32 bytes, separated by colons)

---

### Option 2: Using keytool (Alternative)

If Gradle doesn't work, use keytool:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Look for:**
```
Certificate fingerprints:
     SHA1: AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD
     SHA256: 11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11:22:33:44:55:66:77:88:99:AA:BB:CC:DD:EE:FF:00:11
```

---

## What to Do with These Fingerprints

### Step 1: Add to Firebase Console

1. Go to: https://console.firebase.google.com
2. Select project: **cadenca-e5c04**
3. Click ⚙️ (Settings) → **Project settings**
4. Scroll to **Your apps** section
5. Find Android app: **com.cadenca.app**
6. Click **Add fingerprint**
7. Paste **SHA-1** → Save
8. Click **Add fingerprint** again
9. Paste **SHA-256** → Save

### Step 2: Download New google-services.json

1. Still in Firebase Console, same page
2. Click **Download google-services.json**
3. Replace file at: `health_app/android/app/google-services.json`

### Step 3: Enable Google Sign-In

1. Firebase Console → **Authentication**
2. Click **Sign-in method** tab
3. Find **Google** → Click **Enable**
4. Click **Save**

### Step 4: Verify Google Cloud OAuth

1. Go to: https://console.cloud.google.com
2. Select project: **cadenca-e5c04**
3. Go to: **APIs & Services** → **Credentials**
4. You should see:
   - ✅ OAuth 2.0 Client ID (Android)
   - ✅ OAuth 2.0 Client ID (Web)
   - ✅ OAuth 2.0 Client ID (iOS)

If Android OAuth client is missing, it will be auto-created when you add SHA fingerprints to Firebase.

### Step 5: Rebuild APK

```bash
cd ~/Desktop/HealthApp/health_app
flutter clean
flutter pub get
flutter build apk --release
```

---

## For Release Builds (Production)

If you're building a release APK with your own keystore:

```bash
keytool -list -v -keystore /path/to/your/release.keystore -alias your-key-alias
```

You'll need to enter your keystore password.

Then add those SHA fingerprints to Firebase as well.

---

## Troubleshooting

### "Unable to locate a Java Runtime"

Install Java JDK:
```bash
brew install openjdk@17
```

Then add to your PATH:
```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 17)
```

### "Keystore file does not exist"

The debug keystore is auto-generated. If missing, run:
```bash
flutter run
```

This will create `~/.android/debug.keystore`

---

## Expected Result

After adding SHA fingerprints and rebuilding:

| Sign-In Method | Status |
|----------------|--------|
| Google (Android) | ✅ Works |
| Google (iOS) | ✅ Works |
| Apple (Android) | ✅ Works (web-based) |
| Apple (iOS) | ✅ Works (native) |
| Email | ✅ Works |

---

## Quick Checklist

- [ ] Run `./gradlew signingReport` or `keytool` command
- [ ] Copy SHA-1 fingerprint
- [ ] Copy SHA-256 fingerprint
- [ ] Add both to Firebase Console
- [ ] Download new google-services.json
- [ ] Replace the file in android/app/
- [ ] Enable Google Sign-In in Firebase Authentication
- [ ] Verify OAuth clients in Google Cloud Console
- [ ] Run `flutter clean`
- [ ] Run `flutter build apk --release`
- [ ] Install and test new APK

---

## Need Help?

If you get the SHA fingerprints, paste them here and I'll verify they're correct format before you add them to Firebase.

Example format:
```
SHA1: 8A:F4:32:07:2D:9B:F1:BD:1B:AA:1F:C9:36:18:D4:0B:E4:C3:EC:97
SHA-256: 3F:9B:87:4A:0E:2D:C6:B8:9A:1F:3E:5D:7C:4B:6A:8E:9D:0C:1B:2A:3F:4E:5D:6C:7B:8A:9E:0D:1C:2B:3A:4F
```
