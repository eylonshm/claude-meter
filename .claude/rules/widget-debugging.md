# Widget Debugging

When widgets are not appearing in the macOS Edit Widgets gallery, follow this checklist in order.

## 1. Check pluginkit registration

```bash
pluginkit -m -p com.apple.widgetkit-extension | grep -i claude
```

- No output → extension not registered at all
- `+` prefix → registered but suppressed/rejected
- No `+` prefix → registered and active ✅

## 2. Check pkd rejection reason

```bash
sudo log show --predicate 'process == "pkd" AND eventMessage CONTAINS "rejecting"' --last 5m 2>/dev/null | grep -v "com.apple"
```

Common errors and fixes:

| Error | Cause | Fix |
|---|---|---|
| `plug-ins must be sandboxed` | Extension not signed with a valid Developer ID cert (ad-hoc/unsigned builds are rejected) | Re-sign with Developer ID — see step 4 |
| `plug-ins must be sandboxed` on Apple's own extensions | macOS beta bug — not our issue | Ignore |
| (no output) | pkd isn't rejecting us; issue is elsewhere | Move to step 3 |

## 3. Verify the extension structure

```bash
WIDGET="/Applications/Claude Meter.app/Contents/PlugIns/ClaudeMeterWidgetExtension.appex"

# Must have NSExtensionPointIdentifier
/usr/libexec/PlistBuddy -c "Print :NSExtension:NSExtensionPointIdentifier" "$WIDGET/Contents/Info.plist"
# Expected: com.apple.widgetkit-extension

# Must have @main entry point — check that WidgetBundle exists in sources
ls ClaudeMeterWidget/Sources/
# Must include ClaudeMeterWidgetBundle.swift with @main struct

# Must have app-sandbox entitlement embedded in signature
codesign -d --entitlements :- "$WIDGET" 2>/dev/null | grep app-sandbox
# Expected: <true/>
```

## 4. Re-sign locally for widget testing

PR builds are unsigned. Use `scripts/install-pr-build.sh` — it auto-signs after download.

For manual re-signing:

```bash
APP="/Applications/Claude Meter.app"
CERT="Developer ID Application: Eylon Shmilovich (9WM2J36V23)"

# Sign leaf → parent order (never --deep on the parent)
find "$APP/Contents/Frameworks/Sparkle.framework" -type f | while read -r f; do
  file "$f" | grep -q "Mach-O" && codesign --force --sign "$CERT" --options runtime --timestamp "$f"
done
find "$APP/Contents/Frameworks/Sparkle.framework" \( -name "*.xpc" -o -name "*.app" \) | \
  sort -r | while read -r b; do codesign --force --sign "$CERT" --options runtime --timestamp "$b"; done
codesign --force --sign "$CERT" --options runtime --timestamp \
  "$APP/Contents/Frameworks/Sparkle.framework"
codesign --force --sign "$CERT" --options runtime --timestamp \
  --entitlements ClaudeMeterWidget/Resources/ClaudeMeterWidget.entitlements \
  "$APP/Contents/PlugIns/ClaudeMeterWidgetExtension.appex"
codesign --force --sign "$CERT" --options runtime --timestamp \
  --entitlements ClaudeMeter/Resources/ClaudeMeter.entitlements \
  "$APP"

codesign --verify --deep --strict "$APP" && echo "✅ OK"
```

## 5. Force pkd rescan

If the extension was previously rejected (e.g., before a fix was applied), pkd may have cached the rejection:

```bash
sudo pkill -f "pkd"   # daemon auto-restarts
sleep 3
pluginkit -m -p com.apple.widgetkit-extension | grep -i claude
```

## Key facts

- **`@main` is required**: Without `@main struct ...: WidgetBundle`, WidgetKit has no entry point. The widget extension compiles fine but never loads.
- **Cannot put `@main` on `Widget` directly** if any top-level free functions exist in the module. Use a separate `WidgetBundle` file.
- **Signing order matters**: Sign all nested components (Sparkle helpers, widget .appex) BEFORE signing the parent app. Never use `--deep` on the parent — it overwrites child entitlements.
- **Production builds are notarized** (via `release.yml`) and work without any manual re-signing.
- **PR/local builds need manual re-sign** with Developer ID — `install-pr-build.sh` handles this automatically.
