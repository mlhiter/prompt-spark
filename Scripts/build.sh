#!/bin/bash
set -e

VERSION=${1:-"1.0.0"}
ARCH=${2:-$(uname -m)}
APP_NAME="PromptSpark"

if [ "$ARCH" = "arm64" ]; then
    SWIFT_ARCH="arm64-apple-macosx"
    ARCH_NAME="arm64"
elif [ "$ARCH" = "x86_64" ]; then
    SWIFT_ARCH="x86_64-apple-macosx"
    ARCH_NAME="x86_64"
else
    echo "❌ Unsupported architecture: $ARCH"
    echo "   Supported: arm64, x86_64"
    exit 1
fi

BUILD_DIR=".build/$SWIFT_ARCH/release"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "🔨 Building $APP_NAME v$VERSION for $ARCH_NAME..."

echo "📦 Cleaning previous builds..."
rm -rf "$APP_BUNDLE"

echo "🚀 Building with Swift..."
swift build -c release --arch $ARCH

echo "📁 Creating app bundle structure..."
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

echo "📋 Copying executable..."
cp "$BUILD_DIR/$APP_NAME" "$MACOS_DIR/"

echo "📄 Copying Info.plist..."
cp "Info.plist" "$CONTENTS_DIR/"

echo "📦 Copying resource bundles to app root..."
if [ -d "$BUILD_DIR/KeyboardShortcuts_KeyboardShortcuts.bundle" ]; then
    cp -R "$BUILD_DIR/KeyboardShortcuts_KeyboardShortcuts.bundle" "$APP_BUNDLE/"
    echo "  ✅ KeyboardShortcuts bundle copied to app root"
fi

if [ -d "$BUILD_DIR/PromptSpark_PromptSpark.bundle" ]; then
    cp -R "$BUILD_DIR/PromptSpark_PromptSpark.bundle" "$APP_BUNDLE/"
    echo "  ✅ PromptSpark bundle copied to app root"
fi

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

echo "✍️  Signing bundles individually..."
for bundle in "$APP_BUNDLE"/*.bundle; do
    if [ -d "$bundle" ]; then
        codesign --force --sign - "$bundle" 2>/dev/null && echo "  ✅ Signed $(basename "$bundle")"
    fi
done

echo "✍️  Signing app bundle..."
codesign --force --deep --sign - --preserve-metadata=identifier,entitlements,flags,runtime "$APP_BUNDLE" 2>&1 | grep -v "replacing existing signature" || true
if codesign -v "$APP_BUNDLE" 2>/dev/null; then
    echo "  ✅ App signed successfully"
    codesign -dv "$APP_BUNDLE" 2>&1 | grep -E "(Identifier|Signature)" | head -2
else
    echo "  ⚠️  Signature validation failed, but app may still work"
fi

echo "✅ Build complete: $APP_BUNDLE"
echo "📏 App size: $(du -sh "$APP_BUNDLE" | cut -f1)"
