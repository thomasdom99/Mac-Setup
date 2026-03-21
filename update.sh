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
  brave-browser
  discord
  microsoft-teams
  visual-studio-code
  bbedit
  google-drive
  github
  utm
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
  obs
  windows-app
  wireshark
  ente-auth
)

# App Store apps — format: "APP_ID:App Name"
MAS_APPS=(
  "937984704:Amphetamine"
  "497799835:Xcode"
  "1153157709:Speedtest by Ookla"
  "472226235:LanScan"
  "897118787:Shazam"
  "310633997:WhatsApp"
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
echo "⬆️  Upgrading formulae..."
brew upgrade

echo ""
echo "⬆️  Upgrading casks..."
brew upgrade --cask --greedy $(brew list --cask | grep -v -E "^(alt-tab|firefox@developer-edition)$" | tr '\n' ' ')

echo ""
echo "⬆️  Upgrading App Store apps..."
mas upgrade

echo ""
echo "🧹 Cleaning up old versions..."
brew cleanup

echo ""
echo "🌐 Checking directly downloaded apps..."

ARCH=$(uname -m)

# --- Firefox Developer Edition ---
if [ ! -d "/Applications/Firefox Developer Edition.app" ]; then
  echo "  🔍 Fetching latest Firefox Developer Edition URL..."
  FIREFOX_URL="https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=osx&lang=en-US"
  echo "  ⬇️  Downloading Firefox Developer Edition..."
  curl -L "$FIREFOX_URL" -o /tmp/FirefoxDevEdition.dmg --progress-bar
  hdiutil attach /tmp/FirefoxDevEdition.dmg -quiet
  cp -R "/Volumes/Firefox Developer Edition/Firefox Developer Edition.app" /Applications/ 2>/dev/null || true
  hdiutil detach "/Volumes/Firefox Developer Edition" -quiet 2>/dev/null || true
  rm -f /tmp/FirefoxDevEdition.dmg
  echo "  ✅ Firefox Developer Edition installed."
else
  echo "  ✅ Firefox Developer Edition already installed, skipping."
fi

# --- Adobe Acrobat Reader ---
if [ ! -d "/Applications/Adobe Acrobat Reader DC.app" ]; then
  echo "  🔍 Fetching latest Adobe Acrobat Reader version..."
  ADOBE_VERSION=$(curl -sL "https://ardownload2.adobe.com/pub/adobe/reader/mac/AcrobatDC/" \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    | grep -oE '[0-9]{10}' | sort -n | tail -1)
  if [ -z "$ADOBE_VERSION" ]; then
    ADOBE_VERSION="2500121288"
    echo "  📌 Using fallback version: $ADOBE_VERSION"
  else
    echo "  📌 Latest version: $ADOBE_VERSION"
  fi
  ADOBE_URL="https://ardownload2.adobe.com/pub/adobe/reader/mac/AcrobatDC/${ADOBE_VERSION}/AcroRdrDC_${ADOBE_VERSION}_MUI.pkg"
  curl -L "$ADOBE_URL" -o /tmp/AdobeReader.pkg --progress-bar
  sudo installer -pkg /tmp/AdobeReader.pkg -target /
  rm -f /tmp/AdobeReader.pkg
  if [ -d "/Applications/Adobe Acrobat Reader DC.app" ]; then
    echo "  ✅ Adobe Acrobat Reader installed."
  else
    echo "  ⚠️  Failed to install Adobe Acrobat Reader, skipping..."
    FAILED_INSTALLS+=("Adobe Acrobat Reader")
  fi
else
  echo "  ✅ Adobe Acrobat Reader already installed, skipping."
fi

# --- FileZilla ---
if [ ! -d "/Applications/FileZilla.app" ]; then
  echo "  🔍 Fetching latest FileZilla version..."
  FILEZILLA_VERSION=$(curl -s "https://filezilla-project.org/versions.php" | grep -oE '"version":"[^"]*"' | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  if [ -n "$FILEZILLA_VERSION" ]; then
    if [ "$ARCH" = "arm64" ]; then
      FILEZILLA_URL="https://dl3.cdn.filezilla-project.org/client/FileZilla_${FILEZILLA_VERSION}_macosx-arm64.app.tar.bz2"
    else
      FILEZILLA_URL="https://dl3.cdn.filezilla-project.org/client/FileZilla_${FILEZILLA_VERSION}_macosx-x86_64.app.tar.bz2"
    fi
    echo "  📌 Latest version: $FILEZILLA_VERSION"
    curl -L "$FILEZILLA_URL" -o /tmp/FileZilla.app.tar.bz2 --progress-bar
    tar -xjf /tmp/FileZilla.app.tar.bz2 -C /Applications/ 2>/dev/null
    rm -f /tmp/FileZilla.app.tar.bz2
    echo "  ✅ FileZilla installed."
  else
    echo "  ⚠️  Could not determine latest FileZilla version, skipping..."
    FAILED_INSTALLS+=("FileZilla")
  fi
else
  echo "  ✅ FileZilla already installed, skipping."
fi

# --- XAMPP ---
if [ ! -d "/Applications/XAMPP" ]; then
  echo "  🔍 Fetching latest XAMPP version..."
  XAMPP_VERSION=$(curl -s "https://sourceforge.net/projects/xampp/files/XAMPP%20Mac%20OS%20X/" \
    -H "User-Agent: Mozilla/5.0" | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
  if [ -z "$XAMPP_VERSION" ]; then
    XAMPP_VERSION="8.2.12"
  fi
  XAMPP_MAJOR=$(echo "$XAMPP_VERSION" | cut -d. -f1-2)
  XAMPP_URL="https://sourceforge.net/projects/xampp/files/XAMPP%20Mac%20OS%20X/${XAMPP_MAJOR}/xampp-osx-${XAMPP_VERSION}-0-installer.dmg/download"
  echo "  📌 Latest version: $XAMPP_VERSION"
  curl -L "$XAMPP_URL" -o /tmp/XAMPP.dmg --progress-bar
  sudo hdiutil attach /tmp/XAMPP.dmg -quiet
  sudo /Volumes/XAMPP/xampp-osx-${XAMPP_VERSION}-0-installer.app/Contents/MacOS/xampp-osx-${XAMPP_VERSION}-0-installer --unattendedmodeui none --mode unattended 2>/dev/null || true
  hdiutil detach /Volumes/XAMPP -quiet 2>/dev/null || true
  rm -f /tmp/XAMPP.dmg
  echo "  ✅ XAMPP installed."
else
  echo "  ✅ XAMPP already installed, skipping."
fi

echo ""
if [ ${#FAILED_INSTALLS[@]} -eq 0 ]; then
  echo "✅ Everything is up to date and nothing is missing!"
else
  echo "⚠️  Done! However the following apps failed and may need to be installed manually:"
  for fail in "${FAILED_INSTALLS[@]}"; do
    echo "   ❌ $fail"
  done
fi
