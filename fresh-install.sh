#!/bin/bash

# ===========================================
#   Mac Bootstrap Script
#   Run this after a fresh format to install
#   all your essential apps via Homebrew.
# ===========================================

set -e

echo "🍺 Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  echo "✅ Homebrew already installed. Updating..."
  brew update
fi

echo ""
echo "📦 Installing formulae (CLI tools)..."
FORMULAE=(
  python@3.14
  git
)

for formula in "${FORMULAE[@]}"; do
  if brew list --formula | grep -q "^${formula}\$"; then
    echo "  ✅ $formula already installed, skipping."
  else
    echo "  ⬇️  Installing $formula..."
    brew install "$formula"
  fi
done

echo ""
echo "🖥️  Installing casks (GUI apps)..."
CASKS=(
  spotify
  google-chrome
  brave-browser
  firefox@developer-edition
  discord
  microsoft-teams
  microsoft-365
  visual-studio-code
  adobe-acrobat-reader
  bbedit
  google-drive
  github
  utm
  rectangle
  handbrake
  vlc
  stats
  the-unarchiver
  docker
  postman
  bitwarden
  notion
  steam
  chatgpt
  claude
  drawio
  filezilla
  obs
  speedtest
  windows-app
  wireshark
)

for cask in "${CASKS[@]}"; do
  if brew list --cask | grep -q "^${cask}\$"; then
    echo "  ✅ $cask already installed, skipping."
  else
    echo "  ⬇️  Installing $cask..."
    brew install --cask "$cask"
  fi
done

echo ""
echo "🧹 Cleaning up..."
brew cleanup

echo ""
echo "✅ All done! Your Mac is set up and ready to go."
