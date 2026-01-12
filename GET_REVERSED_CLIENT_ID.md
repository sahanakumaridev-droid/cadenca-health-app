# 🔑 How to Get REVERSED_CLIENT_ID

## ⚠️ Current Issue:

The app is crashing because `REVERSED_CLIENT_ID` is set to a placeholder value. We need the **real** value from Firebase.

## 🔧 Quick Fix Applied:

I've temporarily **re-enabled mock mode** so the app won't crash. Google Sign-In will use mock data until we get the correct REVERSED_CLIENT_ID.

## 📋 How to Get the Real REVERSED_CLIENT_ID:

### Method 1: Re-download GoogleService-Info.plist (Easiest)

1. **Go to Firebase Console:** https://console.firebase.google.com/
2. **Click on Project Settings** (gear icon ⚙️)
3. **Scroll down to "Your apps"**
4. **Click on your iOS app** (com.cadenca.app)
5. **Click "Download GoogleService-Info.plist"** button
6. **Replace the current file:**
   ```bash
   cp ~/Downloads/GoogleService-Info.plist health_app/ios/Runner/GoogleService-Info.plist
   ```

The new file should have the correct `REVERSED_CLIENT_ID` key.

### Method 2: Get from Google Cloud Console

1. **Go to:** https://console.cloud.google.com/
2. **Select your project:** cadenca-e5c04
3. **Go to:** APIs & Services → Credentials
4. **Find:** OAuth 2.0 Client IDs
5. **Look for:** iOS client (for com.cadenca.app)
6. **Copy the Client ID** - it looks like:
   ```
   1078110054358-abc123xyz789.apps.googleusercontent.com
   ```
7. **Reverse it** to get REVERSED_CLIENT_ID:
   ```
   com.googleusercontent.apps.1078110054358-abc123xyz789
   ```

### Method 3: From Firebase Authentication Settings

1. **In Firebase Console**, go to **Authentication**
2. **Click on "Sign-in method" tab**
3. **Click on "Google"** (the one with checkmark)
4. **Scroll down** to see **Web SDK configuration**
5. **Look for iOS OAuth client ID**
6. **Copy it** and reverse the format

## 🎯 What to Do After Getting REVERSED_CLIENT_ID:

### Option A: If you re-downloaded GoogleService-Info.plist

Just replace the file and rebuild:
```bash
cp ~/Downloads/GoogleService-Info.plist health_app/ios/Runner/GoogleService-Info.plist
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Option B: If you got the REVERSED_CLIENT_ID manually

1. **Update GoogleService-Info.plist:**
   - Open `health_app/ios/Runner/GoogleService-Info.plist`
   - Find: `<string>com.googleusercontent.apps.1078110054358-PLACEHOLDER</string>`
   - Replace with your actual REVERSED_CLIENT_ID

2. **Update Info.plist:**
   - Open `health_app/ios/Runner/Info.plist`
   - Find: `<string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>`
   - Replace with your actual REVERSED_CLIENT_ID

3. **Disable mock mode:**
   - Open `health_app/lib/features/authentication/data/datasources/auth_remote_datasource.dart`
   - Change: `static const bool _useMockGoogleSignIn = false;`

4. **Rebuild:**
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   flutter run
   ```

## 📝 Example:

If your REVERSED_CLIENT_ID is:
```
com.googleusercontent.apps.1078110054358-abc123xyz789
```

Then both files should have:

**GoogleService-Info.plist:**
```xml
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.1078110054358-abc123xyz789</string>
```

**Info.plist:**
```xml
<string>com.googleusercontent.apps.1078110054358-abc123xyz789</string>
```

## 🚀 Current Status:

- ✅ Mock mode enabled (app won't crash)
- ✅ Google Sign-In works with mock data
- ⏳ Need real REVERSED_CLIENT_ID for production
- ⏳ Need to update both plist files
- ⏳ Need to disable mock mode

## 🎯 Quick Test (Mock Mode):

Right now you can test the app with mock data:
```bash
flutter run
```

Tap "Continue with Google" - it will work with mock data (no crash!).

Once you get the real REVERSED_CLIENT_ID, follow the steps above to enable real Google authentication.

---

**Recommended:** Use Method 1 (re-download the file) - it's the easiest and most reliable way! 🎉
