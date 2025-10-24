#!/bin/bash
# Post-installation fix for PromptSpark
# This script removes quarantine flags and fixes bundle signatures

APP_PATH="/Applications/PromptSpark.app"

echo "🔧 PromptSpark Post-Installation Fix"
echo "===================================="
echo ""

if [ ! -d "$APP_PATH" ]; then
    echo "❌ Error: PromptSpark.app not found in /Applications"
    echo "   Please install the app first"
    exit 1
fi

echo "📦 Removing quarantine flags..."
xattr -cr "$APP_PATH" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ Quarantine removed"
else
    echo "⚠️  Failed (you may need sudo)"
fi

echo ""
echo "✍️  Re-signing app bundle..."
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "✅ App re-signed successfully"
else
    echo "⚠️  Signing failed (this is OK, app will still work)"
fi

echo ""
echo "🚀 Launching PromptSpark..."
"$APP_PATH/Contents/MacOS/PromptSpark" &

echo ""
echo "✅ Done! PromptSpark should now be running."
echo "   If you don't see the menubar icon, check System Settings"
echo "   → Privacy & Security → Accessibility"
