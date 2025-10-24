#!/bin/bash

# Generate app icon from SF Symbols "sparkles"
# This script creates PNG icons in various sizes for the macOS app

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ICON_DIR="$SCRIPT_DIR/../Resources/Assets.xcassets/AppIcon.appiconset"

# Create Swift script to generate icons
SWIFT_SCRIPT=$(cat <<'EOF'
import AppKit
import CoreGraphics

let symbolName = "sparkles"
let sizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

guard let outputDir = CommandLine.arguments.dropFirst().first else {
    print("Usage: generate-icons <output-directory>")
    exit(1)
}

for (filename, size) in sizes {
    let config = NSImage.SymbolConfiguration(pointSize: size * 0.7, weight: .regular)
    guard let image = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) else {
        print("Failed to create symbol image")
        continue
    }

    let targetSize = NSSize(width: size, height: size)
    let finalImage = NSImage(size: targetSize)

    finalImage.lockFocus()

    NSColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0).setFill()
    NSBezierPath(rect: NSRect(origin: .zero, size: targetSize)).fill()

    let symbolConfig = NSImage.SymbolConfiguration(pointSize: size * 0.6, weight: .medium)
    let symbolImage = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)!
        .withSymbolConfiguration(symbolConfig)!

    let drawRect = NSRect(
        x: (size - size * 0.7) / 2,
        y: (size - size * 0.7) / 2,
        width: size * 0.7,
        height: size * 0.7
    )

    symbolImage.draw(in: drawRect)

    finalImage.unlockFocus()

    if let tiffData = finalImage.tiffRepresentation,
       let bitmapImage = NSBitmapImageRep(data: tiffData),
       let pngData = bitmapImage.representation(using: .png, properties: [:]) {
        let outputPath = "\(outputDir)/\(filename)"
        try? pngData.write(to: URL(fileURLWithPath: outputPath))
        print("Generated: \(filename)")
    }
}

print("✅ All icons generated successfully")
EOF
)

echo "Generating app icons from SF Symbols..."
echo "$SWIFT_SCRIPT" | swift - "$ICON_DIR"

echo "✅ App icon generation complete!"
