#!/bin/bash
set -e

VERSION=${1:-"1.0.0"}
APP_NAME="PromptSpark"
BUILD_DIR=".build/release"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION.dmg"
DMG_DIR="$BUILD_DIR/dmg"
OUTPUT_DMG="$BUILD_DIR/$DMG_NAME"

echo "💿 Creating DMG for $APP_NAME v$VERSION..."

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ Error: App bundle not found at $APP_BUNDLE"
    echo "   Run ./Scripts/build.sh first"
    exit 1
fi

echo "📁 Preparing DMG directory..."
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

echo "📦 Copying app bundle..."
cp -R "$APP_BUNDLE" "$DMG_DIR/"

echo "🔗 Creating Applications symlink..."
ln -s /Applications "$DMG_DIR/Applications"

echo "🎨 Creating DMG..."
rm -f "$OUTPUT_DMG"
hdiutil create -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov -format UDZO \
    "$OUTPUT_DMG"

echo "🧹 Cleaning up..."
rm -rf "$DMG_DIR"

echo "✅ DMG created: $OUTPUT_DMG"
echo "📏 DMG size: $(du -sh "$OUTPUT_DMG" | cut -f1)"
