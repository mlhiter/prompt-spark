# Release Guide

## Automated Release (Recommended)

The project uses GitHub Actions to automatically build and release DMG files.

### Creating a New Release

1. Update version in `Resources/Info.plist` if needed
2. Commit all changes
3. Create and push a version tag:

```bash
git tag v1.0.0
git push origin v1.0.0
```

4. GitHub Actions will automatically:
   - Build the app
   - Create DMG
   - Create a GitHub Release
   - Upload the DMG file

5. Check the [Actions](https://github.com/yourusername/prompt-spark/actions) tab to monitor progress

### Version Format

Use semantic versioning: `vMAJOR.MINOR.PATCH`

Examples:
- `v1.0.0` - Initial release
- `v1.0.1` - Bug fix
- `v1.1.0` - New feature
- `v2.0.0` - Breaking change

## Manual Release

If you need to build locally:

```bash
# Build app and create DMG
./Scripts/build.sh 1.0.0
./Scripts/create-dmg.sh 1.0.0

# DMG will be at: .build/release/PromptSpark-1.0.0.dmg
```

Then manually create a release on GitHub and upload the DMG.

## Testing Before Release

```bash
# Build locally
./Scripts/build.sh

# Test the app
open .build/release/PromptSpark.app

# Create DMG for testing
./Scripts/create-dmg.sh

# Test DMG installation
open .build/release/PromptSpark-1.0.0.dmg
```
