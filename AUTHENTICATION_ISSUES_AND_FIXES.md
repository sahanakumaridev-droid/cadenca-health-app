# Authentication Issues and Fixes

## Issues Reported

### 1. Google Sign-In: "Configuration error. Please check your Firebase setup"
**Status:** ⚠️ Requires Firebase Console Configuration

**Problem:**
- Missing Android OAuth client in Firebase project
- `google-services.json` only has Web and iOS clients, not Android

**Solution:**
Follow the steps in `GOOGLE_SIGNIN_ANDROID_FIX.md`:
1. Get your SHA-1 certificate fingerprint
2. Add it to Firebase Console
3. Download new `google-services.json`
4. Replace the file and rebuild

**Quick Fix Command:**
```bash
cd android
./gradlew signingReport
# Copy the SHA-1 fingerprint
# Add it to Firebase Console
# Download new google-services.json
```

### 2. Apple Sign-In: "webAuthenticationOptions arguments must be provided on Android"
**Status:** ✅ FIXED

**Problem:**
- Apple Sign-In on Android requires `webAuthenticationOptions` parameter
- Missing `clientId` and `redirectUri` configuration

**Solution Applied:**
Added `webAuthenticationOptions` to Apple Sign-In call:
```dart
webAuthenticationOptions: WebAuthenticationOptions(
  clientId: 'com.cadenca.app.signin',
  redirectUri: Uri.parse(
    'https://cadenca-e5c04.firebaseapp.com/__/auth/handler',
  ),
),
```

**Files Modified:**
- `lib/features/authentication/data/datasources/auth_remote_datasource.dart`

## Current APK Status

**Location:** `build/app/outputs/flutter-apk/app-release.apk`
**Size:** 52.1MB
**Build Date:** January 12, 2025

### What Works:
- ✅ Apple Sign-In on Android (web-based login)
- ✅ Apple Sign-In on iOS (native)
- ✅ Email sign-in/sign-up
- ✅ Cancellation handling (no error screens)
- ✅ PlatformException handling

### What Needs Configuration:
- ⚠️ Google Sign-In on Android (needs SHA-1 in Firebase)
- ✅ Google Sign-In on iOS (already configured)

## Testing Instructions

### For Google Sign-In to Work on Android:

1. **Get SHA-1 fingerprint:**
   ```bash
   cd health_app/android
   ./gradlew signingReport
   ```

2. **Add to Firebase:**
   - Go to Firebase Console
   - Project Settings → Your apps → Android app
   - Add fingerprint
   - Download new google-services.json

3. **Rebuild:**
   ```bash
   flutter clean
   flutter build apk --release
   ```

### For Apple Sign-In on Android:

Already configured! Just test:
1. Click "Continue with Apple"
2. Web view opens with Apple login
3. Enter Apple ID email and password
4. Complete 2FA if enabled
5. Sign in successful

## Firebase Configuration Checklist

### Android App (com.cadenca.app)
- ✅ Package name: com.cadenca.app
- ✅ google-services.json added
- ⚠️ SHA-1 fingerprint (NEEDS TO BE ADDED)
- ✅ Firebase Analytics enabled
- ✅ Google Services plugin configured

### iOS App (com.cadenca.app)
- ✅ Bundle ID: com.cadenca.app
- ✅ GoogleService-Info.plist added
- ✅ GIDClientID configured
- ✅ REVERSED_CLIENT_ID configured
- ✅ Apple Sign-In entitlements

## Next Steps

1. **Immediate:** Add SHA-1 fingerprint to Firebase Console for Google Sign-In
2. **Optional:** Configure Apple Sign-In Service ID in Apple Developer Console for better Android experience
3. **Testing:** Test both Google and Apple sign-in on Android device
4. **Testing:** Test both Google and Apple sign-in on iOS device

## Support Files

- `GOOGLE_SIGNIN_ANDROID_FIX.md` - Detailed steps to fix Google Sign-In
- `AUTH_FIXES_COMPLETE.md` - Complete list of all authentication fixes
- `android/app/google-services.json` - Firebase configuration (needs update)
- `ios/Runner/GoogleService-Info.plist` - Firebase iOS configuration (working)

## Error Messages Explained

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "Google Sign-In configuration error" | Missing SHA-1 in Firebase | Add SHA-1 fingerprint |
| "webAuthenticationOptions must be provided" | Missing Apple config | ✅ Fixed in code |
| "Sign-in cancelled" | User pressed back | ✅ Handled gracefully |
| "PlatformException 12501" | User cancelled Google | ✅ Handled gracefully |

## Contact

If you need help with Firebase configuration, the SHA-1 fingerprint is device/keystore specific. Make sure to:
- Use debug keystore SHA-1 for testing
- Use release keystore SHA-1 for production
- You can add multiple SHA-1 fingerprints to Firebase
