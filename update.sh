#!/bin/bash

# ===========================================
#   Mac Update Script
#   Run this every now and then to keep
#   all your apps up to date via Homebrew.
#   Also installs any missing apps.
# ===========================================

FAILED_INSTALLS=()

echo "🧹 Cleaning up apps that need to be managed by Homebrew..."
APPS_TO_CLEAN=(
  "/Applications/BBEdit.app"
  "/Applications/Bitwarden.app"
)

for app in "${APPS_TO_CLEAN[@]}"; do
  if [ -e "$app" ]; then
    echo "  🗑️  Removing $app..."
    sudo rm -rf "$app"
  fi
done

echo ""
brew update

echo ""
echo "📦 Checking formulae (CLI tools)..."
FORMULAE=(
  python@3.14
  git
)

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
CASKS=(
  spotify
  google-chrome
  brave-browser
  firefox@developer-edition
  discord
  microsoft-teams
  visual-studio-code
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
  windows-app
  wireshark
)

for cask in "${CASKS[@]}"; do
  if brew list --cask | grep -q "^${cask}\$"; then
    echo "  ✅ $cask already installed, skipping."
  else
    echo "  ⬇️  Installing missing app: $cask..."
    if ! brew install --cask --force "$cask"; then
      echo "  ⚠️  Failed to install $cask, skipping..."
      FAILED_INSTALLS+=("$cask")
    fi
  fi
done

echo ""
echo "⬆️  Upgrading formulae..."
brew upgrade

echo ""
echo "⬆️  Upgrading casks..."
brew upgrade --cask --greedy $(brew list --cask | grep -v "^alt-tab$" | tr '\n' ' ')

echo ""
echo "🧹 Cleaning up old versions..."
brew cleanup

echo ""
if [ ${#FAILED_INSTALLS[@]} -eq 0 ]; then
  echo "✅ Everything is up to date and nothing is missing!"
else
  echo "✅ Done! However the following apps failed to install and may need to be installed manually:"
  for fail in "${FAILED_INSTALLS[@]}"; do
    echo "   ❌ $fail"
  done
fi
