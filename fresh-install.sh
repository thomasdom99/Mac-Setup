#!/bin/bash

# ===========================================
#   Mac Fresh Install Script
#   Run this after a fresh format to install
#   all your essential apps via Homebrew.
# ===========================================

FAILED_INSTALLS=()

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
    if ! brew install "$formula"; then
      echo "  ⚠️  Failed to install $formula, skipping..."
      FAILED_INSTALLS+=("$formula")
    fi
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
    if ! brew install --cask "$cask"; then
      echo "  ⚠️  Failed to install $cask, skipping..."
      FAILED_INSTALLS+=("$cask")
    fi
  fi
done

echo ""
echo "🧹 Cleaning up..."
brew cleanup

echo ""
if [ ${#FAILED_INSTALLS[@]} -eq 0 ]; then
  echo "✅ All done! Your Mac is set up and ready to go."
else
  echo "✅ Done! However the following apps failed to install and may need to be installed manually:"
  for fail in "${FAILED_INSTALLS[@]}"; do
    echo "   ❌ $fail"
  done
fi

echo ""
echo "⚠️  The following apps need to be installed manually:"
echo ""
echo "  📦 App Store:"
echo "     - Microsoft Word"
echo "     - Microsoft Excel"
echo "     - Microsoft PowerPoint"
echo "     - Microsoft Outlook"
echo "     - Microsoft OneNote"
echo "     - Amphetamine"
echo "     - Ente Auth"
echo "     - Xcode"
echo ""
echo "  🌐 Website:"
echo "     - Cisco Packet Tracer → https://www.netacad.com"
