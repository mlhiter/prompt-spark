#!/bin/bash
set -e

VERSION=${1:-"1.0.0"}
APP_NAME="PromptSpark"
BUILD_DIR=".build/release"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Building $APP_NAME v$VERSION..."

echo "📦 Cleaning previous builds..."
rm -rf "$APP_BUNDLE"

echo "🚀 Building with Swift..."
swift build -c release

echo "📁 Creating app bundle structure..."
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

echo "📋 Copying executable..."
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

echo "📄 Copying Info.plist..."
cp "Info.plist" "$CONTENTS_DIR/"

echo "📦 Copying resources..."
cp "Resources/DefaultMetaPrompt.txt" "$RESOURCES_DIR/"
cp "Resources/DefaultSummaryPrompt.txt" "$RESOURCES_DIR/"

echo "🎨 Generating app icon..."
ICONSET_DIR="/tmp/AppIcon.iconset"
rm -rf "$ICONSET_DIR"
mkdir -p "$ICONSET_DIR"

cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_16x16.png" "$ICONSET_DIR/icon_16x16.png"
cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_16x16@2x.png" "$ICONSET_DIR/icon_16x16@2x.png"
cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_32x32.png" "$ICONSET_DIR/icon_32x32.png"
cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_32x32@2x.png" "$ICONSET_DIR/icon_32x32@2x.png"
cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128.png" "$ICONSET_DIR/icon_128x128.png"
cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png" "$ICONSET_DIR/icon_128x128@2x.png"
cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256.png" "$ICONSET_DIR/icon_256x256.png"
cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png" "$ICONSET_DIR/icon_256x256@2x.png"
cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" "$ICONSET_DIR/icon_512x512.png"
cp "Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png" "$ICONSET_DIR/icon_512x512@2x.png"

iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/AppIcon.icns"
rm -rf "$ICONSET_DIR"

echo "✅ Build complete: $APP_BUNDLE"
echo "📏 App size: $(du -sh "$APP_BUNDLE" | cut -f1)"
