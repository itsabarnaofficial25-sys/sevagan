# Firebase Setup Guide for Sevagan

## Prerequisites
- Google account
- Node.js and npm installed
- Flutter installed
- Firebase project (create at https://console.firebase.google.com/)

---

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `sevagan` (or your preferred name)
4. Disable Google Analytics (optional for MVP)
5. Click "Create project"

---

## Step 2: Install Firebase CLI

```bash
npm install -g firebase-tools
```

Verify installation:
```bash
firebase --version
```

---

## Step 3: Login to Firebase

```bash
firebase login
```

This will open a browser window. Sign in with your Google account.

---

## Step 4: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

Add to PATH if needed (Windows):
```bash
# Add to PATH: %USERPROFILE%\AppData\Local\Pub\Cache\bin
```

Verify installation:
```bash
flutterfire --version
```

---

## Step 5: Configure Customer App

```bash
cd customer_app
flutterfire configure
```

**What this does:**
- Creates `firebase_options.dart` file
- Configures Android app
- Sets up FCM (Firebase Cloud Messaging)
- Links app to your Firebase project

**During configuration:**
1. Select your Firebase project (or create new)
2. Select platforms: **Android** (and iOS if needed)
3. Enter Android package name: `com.sevagan.customer` (or as per your app)
4. Confirm configuration

---

## Step 6: Configure Technician App

```bash
cd ../technician_app
flutterfire configure
```

Repeat the same process:
1. Select the same Firebase project
2. Select Android platform
3. Enter Android package name: `com.sevagan.technician`
4. Confirm configuration

---

## Step 7: Enable Firebase Services

### In Firebase Console:

1. **Cloud Messaging (FCM)**
   - Already enabled by default
   - No additional setup needed

2. **Authentication** (Optional - if you want Firebase Auth)
   - Go to Authentication → Sign-in method
   - Enable "Phone" provider
   - Note: We're using custom OTP, so this is optional

---

## Step 8: Configure Backend Firebase Admin SDK

### Get Service Account Key:

1. Go to Firebase Console → Project Settings
2. Click "Service accounts" tab
3. Click "Generate new private key"
4. Download the JSON file
5. Open the JSON file and extract these values:
   - `project_id`
   - `private_key`
   - `client_email`

### Update Backend .env:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour-Private-Key-Here\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
```

**Important**: Keep the private key in quotes and preserve the `\n` characters.

---

## Step 9: Verify Firebase Setup

### Check Customer App:

```bash
cd customer_app
flutter run
```

Look for Firebase initialization in logs:
```
[firebase_core] Successfully initialized Firebase
```

### Check Technician App:

```bash
cd technician_app
flutter run
```

Verify Firebase initialization.

### Check Backend:

```bash
cd backend
npm run start:dev
```

Look for Firebase Admin SDK initialization in logs.

---

## Step 10: Test Push Notifications

### Send Test Notification from Firebase Console:

1. Go to Firebase Console → Cloud Messaging
2. Click "Send your first message"
3. Enter notification title and text
4. Click "Send test message"
5. Enter FCM token (get from app logs)
6. Send

### Get FCM Token from App:

The token is logged when the app starts. Look for:
```
FCM Token: xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

## Troubleshooting

### Issue: `flutterfire: command not found`

**Solution**: Add Dart pub cache to PATH
```bash
# Windows
setx PATH "%PATH%;%USERPROFILE%\AppData\Local\Pub\Cache\bin"

# macOS/Linux
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

### Issue: Firebase initialization failed

**Solution**: 
1. Check `firebase_options.dart` exists
2. Verify Firebase project is active
3. Check internet connection
4. Run `flutter clean` and rebuild

### Issue: FCM token not received

**Solution**:
1. Ensure Firebase is initialized
2. Check notification permissions
3. Test on physical device (emulator may have issues)
4. Verify Firebase Cloud Messaging is enabled

### Issue: Backend Firebase Admin SDK error

**Solution**:
1. Verify private key format (must include `\n` characters)
2. Check service account has proper permissions
3. Ensure project ID is correct

---

## Files Created by Firebase Setup

### Customer App:
- `lib/firebase_options.dart` - Auto-generated Firebase config
- `android/app/google-services.json` - Android Firebase config

### Technician App:
- `lib/firebase_options.dart` - Auto-generated Firebase config
- `android/app/google-services.json` - Android Firebase config

---

## Testing Checklist

- [ ] Firebase CLI installed and logged in
- [ ] FlutterFire CLI installed
- [ ] Customer app `firebase_options.dart` generated
- [ ] Technician app `firebase_options.dart` generated
- [ ] Backend `.env` updated with Firebase credentials
- [ ] Customer app initializes Firebase successfully
- [ ] Technician app initializes Firebase successfully
- [ ] Backend connects to Firebase Admin SDK
- [ ] FCM tokens are generated
- [ ] Test notification received

---

## Optional: Skip Firebase for Now

If you want to test other features first without Firebase:

1. **Comment out Firebase initialization** in mobile apps
2. **Skip notification features** for now
3. **Test core flows**: OTP login, profile creation, job creation
4. **Come back to Firebase** when you need push notifications

The app will work without Firebase, but you won't have:
- Push notifications for job requests
- Real-time job status updates
- Notification-based navigation

---

## Next Steps After Firebase Setup

1. Test OTP login flow
2. Test job creation and matching
3. Test push notifications
4. Move to Phase 2: Maps integration

---

## Quick Reference

```bash
# Install tools
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Login
firebase login

# Configure apps
cd customer_app && flutterfire configure
cd ../technician_app && flutterfire configure

# Test
flutter run
```

---

## Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
