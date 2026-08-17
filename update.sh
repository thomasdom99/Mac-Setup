#!/bin/bash

# ===========================================
#   Mac Update Script
#   Run this every now and then to keep
#   all your apps up to date via Homebrew.
#   Also installs any missing apps.
#
#   NOTE: Make sure you are signed into the
#   App Store before running this script.
# ===========================================

FAILED_INSTALLS=()

FORMULAE=(
  python@3.14
  git
  mas
)

CASKS=(
  spotify
  google-chrome
  discord
  microsoft-teams
  visual-studio-code
  bbedit
  google-drive
  github
  handbrake
  vlc
  docker
  notion
  chatgpt
  claude
  drawio
  windows-app
  ente-auth
  1password
  tailscale
  brave-browser
  postman
  wireshark
  zoom
)

# App Store apps — format: "APP_ID:App Name"
MAS_APPS=(
  "937984704:Amphetamine"
  "497799835:Xcode"
  "472226235:LanScan"
  "441258766:Magnet"
)

echo "🍺 Updating Homebrew..."
brew update

echo ""
echo "📦 Checking formulae (CLI tools)..."
for formula in "${FORMULAE[@]}"; do
  if brew list --formula | grep -q "^${formula}\$"; then
    echo "  ✅ $formula already installed, skipping."
  else
    echo "  ⬇️  Installing missing formula: $formula..."
    if ! brew install "$formula"; then
      echo "  ⚠️  Failed to install $formula, skipping..."
      FAILED_INSTALLS+=("$formula")
    fi
  fi
done

echo ""
echo "🖥️  Checking casks (GUI apps)..."
for cask in "${CASKS[@]}"; do
  if brew list --cask | grep -q "^${cask}\$"; then
    echo "  ✅ $cask already installed, skipping."
  else
    echo "  ⬇️  Installing missing app: $cask..."
    if ! brew install --cask "$cask"; then
      echo "  ⚠️  Failed to install $cask, skipping..."
      FAILED_INSTALLS+=("$cask")
    fi
  fi
done

echo ""
echo "🛍️  Checking App Store apps..."
for entry in "${MAS_APPS[@]}"; do
  id="${entry%%:*}"
  name="${entry##*:}"
  if mas list | grep -q "^${id}"; then
    echo "  ✅ $name already installed, skipping."
  else
    echo "  ⬇️  Installing missing app: $name..."
    if ! mas install "$id"; then
      echo "  ⚠️  Failed to install $name, skipping..."
      FAILED_INSTALLS+=("$name")
    fi
  fi
done

echo ""
echo "⬆️  Upgrading formulae and casks..."
# A bare 'brew upgrade' already upgrades all outdated formulae AND casks in
# one pass. It correctly skips casks marked auto_updates:true (Chrome, Discord,
# Notion, Spotify, VS Code, Docker, Teams, Steam, OBS, ChatGPT, Claude, etc.)
# since those manage their own updates. Looping back and calling
# `brew upgrade --cask <token>` on each one individually bypasses that skip
# logic and forces a full reinstall even when the app is already current —
# that's what was making updates look like fresh installs. If you ever want
# Homebrew to force-check those self-updating apps too, run:
#   brew upgrade --greedy
brew upgrade

echo ""
echo "⬆️  Upgrading App Store apps..."
mas upgrade

echo ""
echo "🧹 Cleaning up old versions..."
brew cleanup

echo ""
if [ ${#FAILED_INSTALLS[@]} -eq 0 ]; then
  echo "✅ Everything is up to date and nothing is missing!"
else
  echo "⚠️  Done! However the following apps failed and may need to be installed manually:"
  for fail in "${FAILED_INSTALLS[@]}"; do
    echo "   ❌ $fail"
  done
fi
