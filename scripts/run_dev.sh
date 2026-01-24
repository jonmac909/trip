#!/bin/bash

# Trippified Development Runner
# This script loads environment variables and runs the Flutter app

set -e

# Load environment variables from .env file if it exists
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check if required variables are set
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "Warning: Supabase not configured. Running in demo mode."
    echo "Create a .env file based on .env.example to enable full functionality."
    echo ""
fi

# Build the dart-define flags
DART_DEFINES=""

if [ -n "$SUPABASE_URL" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_URL=$SUPABASE_URL"
fi
if [ -n "$SUPABASE_ANON_KEY" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
fi
if [ -n "$GOOGLE_PLACES_API_KEY" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=GOOGLE_PLACES_API_KEY=$GOOGLE_PLACES_API_KEY"
fi
if [ -n "$GOOGLE_MAPS_API_KEY" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=GOOGLE_MAPS_API_KEY=$GOOGLE_MAPS_API_KEY"
fi
if [ -n "$AMADEUS_API_KEY" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=AMADEUS_API_KEY=$AMADEUS_API_KEY"
fi
if [ -n "$AMADEUS_API_SECRET" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=AMADEUS_API_SECRET=$AMADEUS_API_SECRET"
fi
if [ -n "$CLAUDE_API_KEY" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=CLAUDE_API_KEY=$CLAUDE_API_KEY"
fi
if [ -n "$ENABLE_ANALYTICS" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_ANALYTICS=$ENABLE_ANALYTICS"
fi
if [ -n "$ENABLE_CRASH_REPORTING" ]; then
    DART_DEFINES="$DART_DEFINES --dart-define=ENABLE_CRASH_REPORTING=$ENABLE_CRASH_REPORTING"
fi

echo "Starting Trippified..."
flutter run $DART_DEFINES "$@"
