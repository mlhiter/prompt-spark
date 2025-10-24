#!/bin/bash
set -e

VERSION=${1:-"1.0.0"}
ARCH=${2:-""}
APP_NAME="PromptSpark"

if [ -z "$ARCH" ]; then
    if [ -d ".build/arm64-apple-macosx/release/$APP_NAME.app" ]; then
        ARCH="arm64"
        BUILD_DIR=".build/arm64-apple-macosx/release"
    elif [ -d ".build/x86_64-apple-macosx/release/$APP_NAME.app" ]; then
        ARCH="x86_64"
        BUILD_DIR=".build/x86_64-apple-macosx/release"
    elif [ -d ".build/release/$APP_NAME.app" ]; then
        ARCH=$(file ".build/release/$APP_NAME" | grep -o "arm64\|x86_64" | head -1)
        BUILD_DIR=".build/release"
    else
        echo "❌ Error: No app bundle found"
        echo "   Run ./Scripts/build.sh first"
        exit 1
    fi
else
    if [ "$ARCH" = "arm64" ]; then
        BUILD_DIR=".build/arm64-apple-macosx/release"
    elif [ "$ARCH" = "x86_64" ]; then
        BUILD_DIR=".build/x86_64-apple-macosx/release"
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

echo "📦 Copying resource bundles to DMG root..."
if [ -d "$BUILD_DIR/KeyboardShortcuts_KeyboardShortcuts.bundle" ]; then
    cp -R "$BUILD_DIR/KeyboardShortcuts_KeyboardShortcuts.bundle" "$DMG_DIR/"
    echo "  ✅ KeyboardShortcuts bundle copied"
fi
if [ -d "$BUILD_DIR/PromptSpark_PromptSpark.bundle" ]; then
    cp -R "$BUILD_DIR/PromptSpark_PromptSpark.bundle" "$DMG_DIR/"
    echo "  ✅ PromptSpark bundle copied"
fi

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
