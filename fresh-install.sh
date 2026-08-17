#!/bin/bash

# ===========================================
#   Mac Fresh Install Script
#   Run this after a fresh format to install
#   all your essential apps via Homebrew.
# ===========================================

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
  1password
  adobe-acrobat-reader
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
  obs
  postman
  spotify
  stats
  tailscale
  the-unarchiver
  visual-studio-code
  vlc
  whatsapp
  windows-app
  wireshark
  zoom
)

# App Store apps — format: "APP_ID:App Name"
MAS_APPS=(
  "937984704:Amphetamine"
  "497799835:Xcode"
  "1153157709:Speedtest by Ookla"
  "472226235:LanScan"
  "897118787:Shazam"
  "441258766:Magnet"
)

# Helper function to check if an app exists in Applications folders
is_app_installed() {
  local app_name="$1"
  if [ -d "/Applications/${app_name}.app" ] || [ -d "$HOME/Applications/${app_name}.app" ]; then
    return 0
  fi
  if mdfind "kMDItemKind == 'Application' && kMDItemDisplayName == '${app_name}'" | grep -q ".app"; then
    return 0
  fi
  return 1
}

echo "🍺 Checking for Homebrew..."
if ! command -v brew &>/devnull; then
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
    echo "  ✅ $formula Installed already, skipping."
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
  # Get expected App name from cask metadata or default to cask token
  app_name=$(brew info --cask "$cask" 2>/devnull | grep -E "\.app" | head -n 1 | sed -E 's/.*: (.*)\.app.*/\1/' | xargs)
  [ -z "$app_name" ] && app_name="$cask"

  if brew list --cask | grep -q "^${cask}\$" || is_app_installed "$app_name"; then
    echo "  ✅ $cask Installed already, skipping."
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
  if mas list | grep -q "^${id}" || is_app_installed "$name"; then
    echo "  ✅ $name Installed already, skipping."
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
if [ ${#FAILED_INSTALLS[@]} -eq 0 ]; then
  echo "✅ All done! Your Mac is set up and ready to go."
else
  echo "⚠️  Done! However the following apps failed and may need to be installed manually:"
  for fail in "${FAILED_INSTALLS[@]}"; do
    echo "   ❌ $fail"
  done
fi
