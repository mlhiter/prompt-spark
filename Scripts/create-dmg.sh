#!/bin/bash
set -e

VERSION=${1:-"1.0.0"}
ARCH=${2:-""}
APP_NAME="PromptSpark"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_ROOT="$PROJECT_DIR/build"

if [ -z "$ARCH" ]; then
    if [ -d "$BUILD_ROOT/arm64/$APP_NAME.app" ]; then
        ARCH="arm64"
        BUILD_DIR="$BUILD_ROOT/arm64"
    elif [ -d "$BUILD_ROOT/x86_64/$APP_NAME.app" ]; then
        ARCH="x86_64"
        BUILD_DIR="$BUILD_ROOT/x86_64"
    else
        echo "❌ Error: No app bundle found"
        echo "   Run ./Scripts/build.sh first"
        exit 1
    fi
else
    if [ "$ARCH" = "arm64" ]; then
        BUILD_DIR="$BUILD_ROOT/arm64"
    elif [ "$ARCH" = "x86_64" ]; then
        BUILD_DIR="$BUILD_ROOT/x86_64"
    else
        echo "❌ Unsupported architecture: $ARCH"
        exit 1
    fi
fi

APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
DMG_NAME="$APP_NAME-$VERSION-$ARCH.dmg"
DMG_DIR="$BUILD_DIR/dmg"
OUTPUT_DMG="$BUILD_DIR/$DMG_NAME"

echo "💿 Creating DMG for $APP_NAME v$VERSION ($ARCH)..."

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ Error: App bundle not found at $APP_BUNDLE"
    echo "   Run ./Scripts/build.sh $VERSION $ARCH first"
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
