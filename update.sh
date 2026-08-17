#!/bin/bash

# ===========================================
#   Mac Update Script
# ===========================================

FAILED_INSTALLS=()

FORMULAE=(
  python@3.14
  git
  mas
)

CASKS=(
  1password
  bbedit
  brave-browser
  chatgpt
  claude
  discord
  docker
  drawio
  ente-auth
  github
  google-chrome
  google-drive
  handbrake
  microsoft-teams
  notion
  postman
  spotify
  tailscale
  visual-studio-code
  vlc
  windows-app
  wireshark
  zoom
)

MAS_APPS=(
  "937984704:Amphetamine"
  "497799835:Xcode"
  "472226235:LanScan"
  "441258766:Magnet"
  "1200234471:Wake Me Up"
)

echo "🍺 Updating Homebrew..."
brew update

echo ""
echo "📦 Checking formulae (CLI tools)..."
for formula in "${FORMULAE[@]}"; do
  if brew list --formula | grep -q "^${formula}\$"; then
    echo "  ✅ $formula Installed already, skipping."
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
    echo "  ✅ $cask Installed already, skipping."
  else
    echo "  ⬇️  Installing missing app: $cask..."
    if ! brew install --cask --force "$cask"; then
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
    echo "  ✅ $name Installed already, skipping."
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
