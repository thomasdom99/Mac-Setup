#!/bin/bash

# ===========================================
#   Mac Fresh Install Script
#   Run this after a fresh format to install
#   all your essential apps via Homebrew.
# ===========================================

# Pre-flight checklist
echo ""
echo "🍺 Mac Fresh Install Script"
echo "==========================================="
echo ""
echo "⚠️  Before we begin, please confirm the following:"
echo ""
echo "  1. You are connected to WiFi"
echo "  2. You are signed into iCloud (System Settings → Apple ID)"
echo "  3. You are signed into the App Store"
echo ""
read -p "Have you completed all of the above? (y/n): " confirm
echo ""

if [[ "$confirm" =~ ^[Yy]([Ee][Ss]|[Ee][Pp])?$ ]]; then
  echo "✅ Great! Starting installation..."
  echo ""
else
  echo "❌ Please complete the checklist above before running this script."
  echo ""
  echo "  → Sign into iCloud: System Settings → Apple ID"
  echo "  → Sign into App Store: Open App Store → Sign In"
  echo ""
  exit 1
fi

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
echo "🛍️  Installing App Store apps..."
for entry in "${MAS_APPS[@]}"; do
  id="${entry%%:*}"
  name="${entry##*:}"
  if mas list | grep -q "^${id}"; then
    echo "  ✅ $name already installed, skipping."
  else
    echo "  ⬇️  Installing $name..."
    if ! mas install "$id"; then
      echo "  ⚠️  Failed to install $name, skipping..."
      FAILED_INSTALLS+=("$name")
    fi
  fi
done

echo ""
echo "🧹 Cleaning up..."
brew cleanup

echo ""
echo "🌐 Installing apps via direct download..."

# Detect architecture
ARCH=$(uname -m)

# Helper — install a DMG from a URL
install_dmg() {
  local name=$1
  local url=$2
  local app_name=$3
  if [ -d "/Applications/$app_name" ]; then
    echo "  ✅ $name already installed, skipping."
    return
  fi
  echo "  ⬇️  Downloading $name..."
  curl -L "$url" -o /tmp/${name// /_}.dmg --progress-bar
  echo "  📦 Installing $name..."
  hdiutil attach /tmp/${name// /_}.dmg -quiet
  local volume=$(ls /Volumes | grep -i "${name%% *}" | head -1)
  if [ -n "$volume" ]; then
    cp -R "/Volumes/$volume/$app_name" /Applications/ 2>/dev/null || true
    hdiutil detach "/Volumes/$volume" -quiet 2>/dev/null || true
  fi
  rm -f /tmp/${name// /_}.dmg
  if [ -d "/Applications/$app_name" ]; then
    echo "  ✅ $name installed successfully."
  else
    echo "  ⚠️  Failed to install $name, skipping..."
    FAILED_INSTALLS+=("$name")
  fi
}

# Helper — install a PKG from a URL
install_pkg() {
  local name=$1
  local url=$2
  local app_name=$3
  if [ -d "/Applications/$app_name" ]; then
    echo "  ✅ $name already installed, skipping."
    return
  fi
  echo "  ⬇️  Downloading $name..."
  curl -L "$url" -o /tmp/${name// /_}.pkg --progress-bar
  echo "  📦 Installing $name..."
  sudo installer -pkg /tmp/${name// /_}.pkg -target /
  rm -f /tmp/${name// /_}.pkg
  if [ -d "/Applications/$app_name" ]; then
    echo "  ✅ $name installed successfully."
  else
    echo "  ⚠️  Failed to install $name, skipping..."
    FAILED_INSTALLS+=("$name")
  fi
}

# --- Firefox Developer Edition ---
# Mozilla provides a permanent latest redirect URL — always points to newest version
if [ ! -d "/Applications/Firefox Developer Edition.app" ]; then
  echo "  🔍 Fetching latest Firefox Developer Edition URL..."
  FIREFOX_URL="https://download.mozilla.org/?product=firefox-devedition-latest-ssl&os=osx&lang=en-US"
  install_dmg "Firefox Developer Edition" "$FIREFOX_URL" "Firefox Developer Edition.app"
else
  echo "  ✅ Firefox Developer Edition already installed, skipping."
fi

# --- Adobe Acrobat Reader ---
# Try to fetch latest version dynamically, fallback to known working version
if [ ! -d "/Applications/Adobe Acrobat Reader DC.app" ]; then
  echo "  🔍 Fetching latest Adobe Acrobat Reader version..."
  ADOBE_VERSION=$(curl -sL "https://ardownload2.adobe.com/pub/adobe/reader/mac/AcrobatDC/" \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
    | grep -oE '[0-9]{10}' | sort -n | tail -1)
  # Fallback to known latest version if scraping fails
  if [ -z "$ADOBE_VERSION" ]; then
    ADOBE_VERSION="2500121288"
    echo "  📌 Using fallback version: $ADOBE_VERSION"
  else
    echo "  📌 Latest version: $ADOBE_VERSION"
  fi
  ADOBE_URL="https://ardownload2.adobe.com/pub/adobe/reader/mac/AcrobatDC/${ADOBE_VERSION}/AcroRdrDC_${ADOBE_VERSION}_MUI.pkg"
  install_pkg "Adobe Acrobat Reader" "$ADOBE_URL" "Adobe Acrobat Reader DC.app"
else
  echo "  ✅ Adobe Acrobat Reader already installed, skipping."
fi

# --- FileZilla ---
# Dynamically fetch latest version from FileZilla's JSON version API
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
    echo "  ⬇️  Downloading FileZilla..."
    curl -L "$FILEZILLA_URL" -o /tmp/FileZilla.app.tar.bz2 --progress-bar
    tar -xjf /tmp/FileZilla.app.tar.bz2 -C /Applications/ 2>/dev/null
    rm -f /tmp/FileZilla.app.tar.bz2
    if [ -d "/Applications/FileZilla.app" ]; then
      echo "  ✅ FileZilla installed successfully."
    else
      echo "  ⚠️  Failed to install FileZilla, skipping..."
      FAILED_INSTALLS+=("FileZilla")
    fi
  else
    echo "  ⚠️  Could not determine latest FileZilla version, skipping..."
    FAILED_INSTALLS+=("FileZilla")
  fi
else
  echo "  ✅ FileZilla already installed, skipping."
fi

# --- XAMPP ---
# Query SourceForge API for latest Mac version
if [ ! -d "/Applications/XAMPP" ]; then
  echo "  🔍 Fetching latest XAMPP version..."
  XAMPP_VERSION=$(curl -s "https://sourceforge.net/projects/xampp/files/XAMPP%20Mac%20OS%20X/" \
    -H "User-Agent: Mozilla/5.0" | grep -oE '"[0-9]+\.[0-9]+\.[0-9]+"' | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -V | tail -1)
  # Fallback to known stable version
  if [ -z "$XAMPP_VERSION" ]; then
    XAMPP_VERSION="8.2.12"
  fi
  XAMPP_MAJOR=$(echo "$XAMPP_VERSION" | cut -d. -f1-2)
  XAMPP_URL="https://sourceforge.net/projects/xampp/files/XAMPP%20Mac%20OS%20X/${XAMPP_MAJOR}/xampp-osx-${XAMPP_VERSION}-0-installer.dmg/download"
  echo "  📌 Latest version: $XAMPP_VERSION"
  echo "  ⬇️  Downloading XAMPP..."
  curl -L "$XAMPP_URL" -o /tmp/XAMPP.dmg --progress-bar
  echo "  📦 Installing XAMPP..."
  sudo hdiutil attach /tmp/XAMPP.dmg -quiet
  sudo /Volumes/XAMPP/xampp-osx-${XAMPP_VERSION}-0-installer.app/Contents/MacOS/xampp-osx-${XAMPP_VERSION}-0-installer --unattendedmodeui none --mode unattended 2>/dev/null || true
  hdiutil detach /Volumes/XAMPP -quiet 2>/dev/null || true
  rm -f /tmp/XAMPP.dmg
  if [ -d "/Applications/XAMPP" ]; then
    echo "  ✅ XAMPP installed successfully."
  else
    echo "  ⚠️  Failed to install XAMPP, skipping..."
    FAILED_INSTALLS+=("XAMPP")
  fi
else
  echo "  ✅ XAMPP already installed, skipping."
fi

echo ""
if [ ${#FAILED_INSTALLS[@]} -eq 0 ]; then
  echo "✅ All done! Your Mac is set up and ready to go."
else
  echo "⚠️  Done! However the following apps failed and may need to be installed manually:"
  for fail in "${FAILED_INSTALLS[@]}"; do
    echo "   ❌ $fail"
  done
fi

echo ""
echo "⚠️  The following apps need to be installed manually:"
echo ""
echo "  🌐 Website:"
echo "     - Cisco Packet Tracer → https://www.netacad.com"
echo "     - Microsoft 365 (Word/Excel/PowerPoint/Outlook/OneNote) → https://www.microsoft.com/microsoft-365"
