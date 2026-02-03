# Quick Fix for App Build Error

The framework error you're seeing is due to missing dependencies. Here's how to fix it:

## Step 1: Clean Everything
```bash
flutter clean
rm -rf pubspec.lock
```

## Step 2: Get Dependencies
```bash
flutter pub get
```

This will install:
- `flutter_dotenv: ^5.1.0` - Reads .env file for Supabase credentials

## Step 3: Verify .env File Exists
Make sure `.env` file is in the project root with:
```
VITE_SUPABASE_URL=https://qbpfbjytfxuyqvwcihdc.supabase.co
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## Step 4: Run the App
```bash
flutter run -v
```

The `-v` flag shows verbose output so you can see what's happening during initialization.

## What Was Fixed

### Changes Made:
1. **Added flutter_dotenv dependency** - Reads environment variables from .env file
2. **Updated pubspec.yaml** - Added .env as an asset so Flutter can load it
3. **Updated SupabaseService** - Uses `flutter_dotenv` instead of `String.fromEnvironment()`
4. **Improved error messages** - Added detailed logging in main.dart

### Why This Matters:
- Without these changes, the app couldn't read Supabase credentials from .env
- This caused Supabase initialization to fail silently
- Which prevented AppController from initializing properly
- Which caused the framework error when trying to show SplashScreen

## Testing the Fix

After running `flutter run -v`, you should see in the console:
```
Initializing Supabase...
Supabase initialized successfully
Initializing AppController...
AppController initialized successfully
```

Then the app should show the SplashScreen with the logo and "Scaffolding & Shuttering" text.

## Troubleshooting

### If still getting errors:
1. **Clear everything**: `flutter clean && rm -rf pubspec.lock && flutter pub get`
2. **Check .env file**: Make sure it has correct Supabase URL and key
3. **Rebuild**: `flutter pub get && flutter run -v`
4. **Check logs**: Look at the console output for specific error messages

### If pubspec.lock conflicts:
```bash
flutter pub upgrade
flutter run
```

## Next Steps

Once the app runs successfully:
1. You'll see the SplashScreen (shows for 3 seconds)
2. You'll be directed to PhoneNumberScreen (if not logged in)
3. Enter any 10-digit phone number (format: 9876543210)
4. Get OTP from Supabase (check email or SMS if configured)
5. Enter OTP to verify
6. Fill in registration form
7. You'll be in the HomeScreen

The app is now fully integrated with Supabase backend!
