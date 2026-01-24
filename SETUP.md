# Trippified Setup Guide

## Prerequisites

1. **Flutter SDK** (installed via Homebrew)
2. **Xcode** (for iOS development)
3. **Android Studio** (for Android development)

## Quick Start (Demo Mode)

The app can run without Supabase in demo mode:

```bash
flutter run
```

## Full Setup with Supabase

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign up
2. Click "New Project"
3. Choose an organization (or create one)
4. Fill in:
   - **Name**: Trippified
   - **Database Password**: (save this securely)
   - **Region**: Choose closest to you
5. Click "Create new project" and wait for setup

### Step 2: Apply Database Schema

1. In Supabase dashboard, go to **SQL Editor**
2. Copy contents from `supabase/migrations/20240122000000_initial_schema.sql`
3. Paste into SQL Editor and click "Run"

### Step 3: Configure Environment

1. In Supabase dashboard, go to **Settings** → **API**
2. Copy the **Project URL** and **anon public** key
3. Create `.env` file in project root:

```bash
cp .env.example .env
```

4. Edit `.env` and add your Supabase credentials:

```
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

### Step 4: Configure OAuth Providers

#### Google Sign-In

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing
3. Enable **Google Sign-In** API
4. Create OAuth 2.0 credentials (Web application)
5. Add authorized redirect URI:
   - `https://your-project-ref.supabase.co/auth/v1/callback`
6. In Supabase dashboard → **Authentication** → **Providers** → **Google**:
   - Enable Google provider
   - Add Client ID and Client Secret

#### Apple Sign-In

1. Go to [Apple Developer Portal](https://developer.apple.com)
2. Create a new App ID with Sign in with Apple capability
3. Create a Services ID for web authentication
4. In Supabase dashboard → **Authentication** → **Providers** → **Apple**:
   - Enable Apple provider
   - Add required credentials

#### Facebook Sign-In

1. Go to [Facebook Developers](https://developers.facebook.com)
2. Create a new app (Consumer type)
3. Add Facebook Login product
4. In Settings → Basic, copy App ID and App Secret
5. In Supabase dashboard → **Authentication** → **Providers** → **Facebook**:
   - Enable Facebook provider
   - Add App ID and App Secret

### Step 5: Run the App

```bash
# Using the helper script
chmod +x scripts/run_dev.sh
./scripts/run_dev.sh

# Or manually with dart-define flags
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

## Running on Devices

### iOS Simulator

```bash
open -a Simulator
./scripts/run_dev.sh
```

### Android Emulator

```bash
# List available emulators
flutter emulators

# Launch an emulator
flutter emulators --launch <emulator_id>

# Run app
./scripts/run_dev.sh
```

### Physical Device

1. Connect device via USB
2. Enable developer mode on device
3. Run: `./scripts/run_dev.sh`

## Troubleshooting

### "Supabase not configured" warning

This is normal if you haven't set up `.env` yet. The app will run in demo mode.

### Build errors

```bash
flutter clean
flutter pub get
flutter run
```

### iOS build issues

```bash
cd ios
pod install --repo-update
cd ..
flutter run
```

### Android build issues

```bash
cd android
./gradlew clean
cd ..
flutter run
```
