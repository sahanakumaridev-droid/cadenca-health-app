# Apple Sign-In on Android - Complete Setup Guide

## Why "Invalid Account" Error?

Apple Sign-In on Android requires a **Service ID** configured in Apple Developer Console. Without it, Apple rejects the authentication request.

---

## Option 1: Full Apple Sign-In Setup (Requires Apple Developer Account)

### Prerequisites:
- Apple Developer Account ($99/year)
- Access to Apple Developer Console
- Domain ownership (can use Firebase domain)

### Step 1: Create Service ID

1. Go to: https://developer.apple.com/account/resources/identifiers/list/serviceId
2. Click **+** to create new Service ID
3. **Description:** Cadenca Web Service
4. **Identifier:** `com.cadenca.app.signin`
5. Click **Continue** → **Register**

### Step 2: Configure Service ID

1. Click on the Service ID you just created
2. Check **"Sign In with Apple"**
3. Click **Configure**

**Primary App ID:**
- Select: `com.cadenca.app` (your iOS app)

**Website URLs:**
- **Domains:** `cadenca-e5c04.firebaseapp.com`
- **Return URLs:** `https://cadenca-e5c04.firebaseapp.com/__/auth/handler`

4. Click **Save**
5. Click **Continue** → **Save**

### Step 3: Verify Domain (if required)

1. Download the verification file from Apple
2. Upload to your Firebase Hosting (if using custom domain)
3. For Firebase default domain, this is usually auto-verified

### Step 4: Update Flutter Code

The code is already configured with:
```dart
webAuthenticationOptions: WebAuthenticationOptions(
  clientId: 'com.cadenca.app.signin',
  redirectUri: Uri.parse(
    'https://cadenca-e5c04.firebaseapp.com/__/auth/handler',
  ),
),
```

### Step 5: Enable Apple Sign-In in Firebase

1. Go to: https://console.firebase.google.com/project/cadenca-e5c04/authentication/providers
2. Click **Apple**
3. Toggle **Enable**
4. **Service ID:** `com.cadenca.app.signin`
5. **OAuth code flow configuration:**
   - **Apple Team ID:** (from Apple Developer Console)
   - **Key ID:** (from Apple Developer Console)
   - **Private Key:** (download from Apple Developer Console)
6. Click **Save**

---

## Option 2: Disable Apple Sign-In on Android (Quick Fix)

If you don't have Apple Developer Account or want to test Google Sign-In first:

### Hide Apple Button on Android

This is the simplest solution - only show Apple Sign-In on iOS where it works natively.

**Pros:**
- Works immediately
- No Apple Developer Account needed
- Google Sign-In works perfectly

**Cons:**
- Android users can't use Apple Sign-In
- They can still use Google or Email

---

## Option 3: Show Apple Button But Handle Error Gracefully

Keep the button visible but show a better error message when clicked on Android.

---

## Recommendation

**For now (testing phase):**
- Hide Apple Sign-In button on Android
- Focus on Google Sign-In (which should work now!)
- Add Apple Sign-In for Android later when you have Apple Developer Account

**For production:**
- Complete Apple Service ID setup
- Enable Apple Sign-In on both platforms

---

## Current Status

| Sign-In Method | iOS | Android |
|----------------|-----|---------|
| Google | ✅ Works | ✅ Should work now |
| Apple | ✅ Works (native) | ❌ Needs Service ID |
| Email | ✅ Works | ✅ Works |

---

## Quick Fix: Hide Apple Button on Android

Would you like me to:
1. Hide Apple Sign-In button on Android?
2. Keep it visible but show better error message?
3. Wait and set up Apple Service ID properly?

Let me know which option you prefer!

---

## Testing Priority

**Test Google Sign-In first:**
1. Click "Continue with Google"
2. Does it open account picker?
3. Can you sign in successfully?

If Google works, we can decide on Apple Sign-In strategy.
