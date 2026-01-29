#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🚀 Trippified TestFlight Deployment${NC}"
echo "=================================="

cd "$(dirname "$0")/.."
PROJECT_ROOT=$(pwd)

# 1. Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}⚠️  You have uncommitted changes. Commit them first? (y/n)${NC}"
    read -r response
    if [[ "$response" == "y" ]]; then
        echo "Enter commit message:"
        read -r commit_msg
        git add .
        git commit -m "$commit_msg"
        git push origin main
        echo -e "${GREEN}✓ Changes committed and pushed${NC}"
    else
        echo -e "${RED}Aborting. Commit your changes first.${NC}"
        exit 1
    fi
fi

# 2. Bump build number
echo -e "\n${YELLOW}📦 Bumping build number...${NC}"
cd ios
agvtool next-version -all
NEW_BUILD=$(agvtool what-version -terse)
echo -e "${GREEN}✓ Build number: $NEW_BUILD${NC}"

# 3. Flutter clean & build
echo -e "\n${YELLOW}🔨 Building Flutter iOS release...${NC}"
cd "$PROJECT_ROOT"
flutter clean
flutter pub get
flutter build ios --release --no-codesign

# 4. Create archive
echo -e "\n${YELLOW}📁 Creating Xcode archive...${NC}"
cd ios
rm -rf build/Runner.xcarchive
xcodebuild -workspace Runner.xcworkspace \
    -scheme Runner \
    -configuration Release \
    -destination 'generic/platform=iOS' \
    -archivePath build/Runner.xcarchive \
    archive \
    -allowProvisioningUpdates \
    -quiet

echo -e "${GREEN}✓ Archive created${NC}"

# 5. Export & Upload to App Store Connect
echo -e "\n${YELLOW}☁️  Uploading to App Store Connect...${NC}"

# Create export options if not exists
cat > /tmp/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>upload</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>teamID</key>
    <string>9TULZPRHM2</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath build/Runner.xcarchive \
    -exportOptionsPlist /tmp/ExportOptions.plist \
    -exportPath build/export \
    -allowProvisioningUpdates

echo -e "\n${GREEN}✅ Upload complete!${NC}"
echo "=================================="
echo -e "${GREEN}Build $NEW_BUILD uploaded to TestFlight${NC}"
echo ""
echo "Next steps:"
echo "  1. Wait 15-30 min for processing"
echo "  2. Check App Store Connect → TestFlight"
echo "  3. Testers will be notified automatically"
echo ""
