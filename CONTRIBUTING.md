# Contributing to Claude Meter

Thanks for your interest in contributing!

## Requirements

- macOS 14 (Sonoma) or later
- Xcode 15+
- [xcodegen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- [Claude Code CLI](https://claude.ai/code) installed (for testing data fetching)

## Local Development

```bash
git clone https://github.com/eylonshm/claude-meter.git
cd claude-meter
xcodegen generate
open ClaudeMeter.xcodeproj
```

Build and run with `Cmd+R`.

## Build & Install Locally

After making changes, build and install to test:

```bash
xcodegen generate

xcodebuild \
  -project ClaudeMeter.xcodeproj \
  -scheme ClaudeMeter \
  -configuration Release \
  build \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_ALLOWED=NO \
  CONFIGURATION_BUILD_DIR="$(pwd)/build"

mkdir -p "build/Claude Meter.app/Contents/PlugIns"
cp -R "build/ClaudeMeterWidgetExtension.appex" "build/Claude Meter.app/Contents/PlugIns/"
mkdir -p "build/Claude Meter.app/Contents/Resources"
cp ClaudeMeter/Resources/fetch-quota.sh "build/Claude Meter.app/Contents/Resources/"
chmod +x "build/Claude Meter.app/Contents/Resources/fetch-quota.sh"

pkill -x "Claude Meter" 2>/dev/null || true
sleep 2
rm -rf "/Applications/Claude Meter.app"
cp -R "build/Claude Meter.app" "/Applications/Claude Meter.app"
open "/Applications/Claude Meter.app"
```

## Testing Widgets

Widget extensions require a properly signed build to appear in the macOS widget gallery. Local unsigned builds won't show up there.

To test widget changes:
1. Push your branch and open a PR
2. Run `scripts/install-pr-build.sh` — it waits for CI to finish, downloads the signed DMG, and installs it

## Submitting a PR

1. Fork the repo and create a branch from `main`
2. Make your changes
3. Test locally (and via PR build for widget changes)
4. Open a pull request — the CI will build a signed preview DMG automatically

## Versioning

Releases are created automatically when a PR merges to `main`. The default is a patch bump. Add the `release:minor` or `release:major` label if your change warrants it.
