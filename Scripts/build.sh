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

echo "✅ Build complete: $APP_BUNDLE"
echo "📏 App size: $(du -sh "$APP_BUNDLE" | cut -f1)"
