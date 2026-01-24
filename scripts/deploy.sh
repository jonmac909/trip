#!/bin/bash
# Quick deploy to Cloudflare Pages

set -e

echo "Building Flutter web..."
flutter build web --release

echo "Deploying to Cloudflare Pages..."
npx wrangler pages deploy build/web --project-name=trippified --commit-dirty=true

echo "Done! Check https://trippified-26j.pages.dev"
