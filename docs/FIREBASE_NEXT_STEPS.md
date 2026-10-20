# Firebase Setup - Next Steps

## ✅ Completed
- Firebase CLI v15.1.0 installed
- FlutterFire CLI v1.3.1 installed

## 🔔 Important: Add FlutterFire to PATH

The `flutterfire` command is installed at:
```
C:\Users\selvakumar.rayappan\AppData\Local\Pub\Cache\bin
```

**Add to PATH (one-time setup):**
1. Press `Win + X` → System
2. Click "Advanced system settings"
3. Click "Environment Variables"
4. Under "User variables", select "Path" → Edit
5. Click "New" and add: `C:\Users\selvakumar.rayappan\AppData\Local\Pub\Cache\bin`
6. Click OK on all dialogs
7. **Restart your terminal**

**OR run this PowerShell command (as Administrator):**
```powershell
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Users\selvakumar.rayappan\AppData\Local\Pub\Cache\bin", "User")
```

---

## 📋 Next Steps (Manual)

### Step 1: Login to Firebase
```bash
firebase login
```
This will open a browser window. Sign in with your Google account.

### Step 2: Verify Login
```bash
firebase projects:list
```
This should show your Firebase projects (or empty if you haven't created one yet).

### Step 3: Create Firebase Project (if needed)
Go to https://console.firebase.google.com/ and:
1. Click "Add project"
2. Name: `sevagan` (or your choice)
3. Disable Google Analytics (optional)
4. Click "Create project"

### Step 4: Configure Customer App
```bash
cd customer_app
flutterfire configure
```

**During configuration:**
- Select your Firebase project
- Select platforms: Android (and iOS if needed)
- Android package name: `com.sevagan.customer` (check `android/app/build.gradle`)

This will create `lib/firebase_options.dart`

### Step 5: Configure Technician App
```bash
cd ../technician_app
flutterfire configure
```

**During configuration:**
- Select the SAME Firebase project
- Select platforms: Android
- Android package name: `com.sevagan.technician`

### Step 6: Get Firebase Admin SDK Credentials

1. Go to Firebase Console → Project Settings
2. Click "Service accounts" tab
3. Click "Generate new private key"
4. Download the JSON file
5. Extract these values and update `backend/.env`:
   - `project_id`
   - `private_key`
   - `client_email`

---

## 🚨 Important Notes

1. **PATH Update**: You MUST add FlutterFire to PATH or use the full path:
   ```bash
   C:\Users\selvakumar.rayappan\AppData\Local\Pub\Cache\bin\flutterfire configure
   ```

2. **Same Firebase Project**: Use the same project for both apps so they can communicate.

3. **Package Names**: Check your actual package names in:
   - `customer_app/android/app/build.gradle`
   - `technician_app/android/app/build.gradle`

---

## ✅ After Configuration

You should have these files created:
- `customer_app/lib/firebase_options.dart`
- `customer_app/android/app/google-services.json`
- `technician_app/lib/firebase_options.dart`
- `technician_app/android/app/google-services.json`

---

## 🎯 Ready to Proceed

Once you complete these steps, I can help you:
1. Update backend Firebase configuration
2. Test push notifications
3. Verify FCM token generation
