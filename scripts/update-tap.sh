#!/usr/bin/env bash
set -euo pipefail

VERSION="$1"
SHA256="$2"
TAP_TOKEN="$3"

CASK=$(cat <<'EOF'
cask "claude-meter" do
  version "VERSION_PLACEHOLDER"
  sha256 "SHA256_PLACEHOLDER"

  url "https://github.com/eylonshm/claude-meter/releases/download/v#{version}/ClaudeMeter-#{version}.dmg"
  name "Claude Meter Widget"
  desc "macOS menu bar app and desktop widgets for monitoring Claude Code usage and quota"
  homepage "https://github.com/eylonshm/claude-meter"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on macos: ">= :sonoma"

  app "Claude Meter.app"

  postflight do
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/Claude Meter.app"],
                   sudo: false
  end

  zap trash: [
    "~/Library/Preferences/com.claudemeter.app.plist",
    "~/Library/Application Support/Claude Meter",
    "~/Library/Caches/com.claudemeter.app",
  ]
end
EOF
)

CASK="${CASK/VERSION_PLACEHOLDER/$VERSION}"
CASK="${CASK/SHA256_PLACEHOLDER/$SHA256}"

ENCODED=$(printf '%s' "$CASK" | base64)
CURRENT_SHA=$(curl -sf -H "Authorization: token $TAP_TOKEN" \
  "https://api.github.com/repos/eylonshm/homebrew-tap/contents/Casks/claude-meter.rb" \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['sha'])")

jq -n \
  --arg message "chore: bump claude-meter to v${VERSION}" \
  --arg sha "$CURRENT_SHA" \
  --arg content "$ENCODED" \
  '{message: $message, sha: $sha, content: $content}' \
| curl -sf -X PUT \
  -H "Authorization: token $TAP_TOKEN" \
  -H "Content-Type: application/json" \
  "https://api.github.com/repos/eylonshm/homebrew-tap/contents/Casks/claude-meter.rb" \
  -d @-

echo "Tap updated to v${VERSION}"
