# Get SHA Fingerprints Without Java/Gradle

Since Java is not installed on your Mac, here are alternative ways to get your SHA fingerprints:

---

## Option 1: Use Android Studio (Easiest)

### Step 1: Open Project in Android Studio
1. Open Android Studio
2. File → Open
3. Navigate to: `~/Desktop/HealthApp/health_app/android`
4. Click Open

### Step 2: Get SHA from Gradle Panel
1. In Android Studio, look for **Gradle** panel on the right side
2. Expand: **health_app → android → Tasks → android**
3. Double-click: **signingReport**
4. Wait for it to run
5. Look at the output in the **Run** panel at the bottom

**Copy these values:**
```
SHA1: XX:XX:XX:...
SHA-256: XX:XX:XX:...
```

---

## Option 2: Install Java First (Quick)

### Install Java via Homebrew:
```bash
brew install openjdk@17
```

### Set JAVA_HOME:
```bash
export JAVA_HOME=/opt/homebrew/opt/openjdk@17
export PATH="$JAVA_HOME/bin:$PATH"
```

### Then run:
```bash
cd ~/Desktop/HealthApp/health_app/android
./gradlew signingReport
```

---

## Option 3: Get SHA from Firebase Console (If Already Added)

If you've previously added SHA fingerprints:

1. Go to: https://console.firebase.google.com/project/cadenca-e5c04/settings/general
2. Scroll to **Your apps** → Android app
3. Look for **SHA certificate fingerprints** section
4. You'll see any previously added fingerprints

---

## Option 4: Use Flutter Doctor to Check

```bash
flutter doctor -v
```

This might show Android SDK location, then you can find keytool there.

---

## Option 5: Skip SHA for Now - Test Current Behavior

Since the app is already running on your phone, let's first see what happens:

### Test Google Sign-In:
1. Click "Continue with Google"
2. What error do you see?
3. Take a screenshot if possible

### Test Apple Sign-In:
1. Click "Continue with Apple"
2. Does it open a web view?
3. What happens?

### Test Cancellation:
1. Click Google/Apple sign-in
2. Press back button
3. Does it return to login without error?

**Tell me what you see, and we can decide if we need SHA fingerprints or if there's another issue.**

---

## Why We Need SHA Fingerprints

Google Sign-In on Android requires:
- Your app's package name: `com.cadenca.app` ✅
- Your app's SHA-1 fingerprint: ❌ Missing
- Your app's SHA-256 fingerprint: ❌ Missing

Without these, Google can't verify your app is legitimate, so it blocks sign-in.

---

## Quick Decision Tree

**If you have Android Studio installed:**
→ Use Option 1 (easiest)

**If you don't mind installing Java:**
→ Use Option 2 (5 minutes)

**If you want to test first:**
→ Use Option 5 (test current behavior)

**If you're stuck:**
→ Tell me what you see on your phone when you click "Continue with Google"

---

## What to Do After Getting SHA

Once you have SHA-1 and SHA-256:

1. Go to Firebase Console
2. Add both fingerprints
3. Download new google-services.json
4. Replace the file
5. Rebuild: `flutter build apk --release`

---

## Current Status

- ✅ App running on your Android phone
- ✅ Code is correct
- ✅ Firebase project exists
- ❌ SHA fingerprints not added to Firebase
- ❌ Java not installed (blocking Gradle/keytool)

**Next Step:** Choose one of the options above, or tell me what you see when you test the app!
