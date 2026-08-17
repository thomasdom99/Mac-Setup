#!/bin/bash

# ===========================================
#   Mac Fresh Install Script
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

# App Store apps — format: "APP_ID:App Name"
MAS_APPS=(
  "937984704:Amphetamine"
  "497799835:Xcode"
  "472226235:LanScan"
  "441258766:Magnet"
  "1200234471:Wake Me Up"
)

# Robust check for GUI applications in /Applications
is_app_installed() {
  local target_cask="$1"
  case "$target_cask" in
    1password)           app_file="1Password.app" ;;
    bbedit)              app_file="BBEdit.app" ;;
    brave-browser)       app_file="Brave Browser.app" ;;
    chatgpt)             app_file="ChatGPT.app" ;;
    claude)              app_file="Claude.app" ;;
    discord)             app_file="Discord.app" ;;
    docker)              app_file="Docker.app" ;;
    drawio)              app_file="draw.io.app" ;;
    ente-auth)           app_file="Ente Auth.app" ;;
    github)              app_file="GitHub Desktop.app" ;;
    google-chrome)       app_file="Google Chrome.app" ;;
    google-drive)        app_file="Google Drive.app" ;;
    handbrake)           app_file="HandBrake.app" ;;
    microsoft-teams)     app_file="Microsoft Teams.app" ;;
    notion)              app_file="Notion.app" ;;
    postman)             app_file="Postman.app" ;;
    spotify)             app_file="Spotify.app" ;;
    tailscale)           app_file="Tailscale.app" ;;
    visual-studio-code)  app_file="Visual Studio Code.app" ;;
    vlc)                 app_file="VLC.app" ;;
    windows-app)         app_file="Windows App.app" ;;
    wireshark)           app_file="Wireshark.app" ;;
    zoom)                app_file="zoom.us.app" ;;
    *)                   app_file="${target_cask}.app" ;;
  esac

  if [ -d "/Applications/${app_file}" ] || [ -d "$HOME/Applications/${app_file}" ]; then
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
  if is_app_installed "$cask"; then
    echo "  ✅ $cask Installed already, skipping."
  else
    echo "  ⬇️  Installing $cask..."
    if ! brew install --cask --force "$cask"; then
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
  if mas list | grep -q "^${id}" || [ -d "/Applications/${name}.app" ]; then
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

echo ""
echo "⚠️  The following apps need to be installed manually:"
echo "     - Adobe Acrobat Reader → https://get.adobe.com/reader"
