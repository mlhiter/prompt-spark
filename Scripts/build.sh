#!/bin/bash
set -e

VERSION=${1:-"1.0.0"}
ARCH=${2:-$(uname -m)}
APP_NAME="PromptSpark"
PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ "$ARCH" = "arm64" ]; then
    XCODE_ARCH="arm64"
    ARCH_NAME="arm64"
elif [ "$ARCH" = "x86_64" ]; then
    XCODE_ARCH="x86_64"
    ARCH_NAME="x86_64"
else
    echo "❌ Unsupported architecture: $ARCH"
    echo "   Supported: arm64, x86_64"
    exit 1
fi

BUILD_ROOT="$PROJECT_DIR/build"
BUILD_DIR="$BUILD_ROOT/$ARCH_NAME"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"

echo "🔨 Building $APP_NAME v$VERSION for $ARCH_NAME..."

echo "📦 Cleaning previous builds..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

echo "🚀 Building with Xcode..."
xcodebuild \
    -project "$PROJECT_DIR/PromptSpark.xcodeproj" \
    -scheme PromptSpark \
    -configuration Release \
    -arch "$XCODE_ARCH" \
    CONFIGURATION_BUILD_DIR="$BUILD_DIR" \
    build

if [ ! -d "$APP_BUNDLE" ]; then
    echo "❌ Build failed: App bundle not found at $APP_BUNDLE"
    exit 1
fi

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
