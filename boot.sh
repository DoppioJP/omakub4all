set -e

ascii_art='________                  __        ___.         _  _           _ _
\_____  \   _____ _____  |  | ____ _\_ |__      | || |        | | |
 /   |   \ /     \\__   \ |  |/ /  |  \ __ \     | || |_ _ __ | | |
/    |    \  Y Y  \/ __ \|    <|  |  / \_\ \    |__   _| \_ \| | |
\_______  /__|_|  (____  /__|_ \____/|___  /       |_| |___/ |_|_|
        \/      \/     \/     \/         \/
'

echo -e "$ascii_art"
echo "=> Omakub4all - extension of Omakub to setup your development environment on 3 missing platforms:
- Linux on ARM - perfect to run in a VirtualBox on macOS with Apple Silicon
- macOS on ARM
- macOS on x86_64"
echo -e "\nBegin installation (or abort with ctrl+c)..."

OS=$(uname -s)
ARCH=$(uname -m)

if [[ "$OS" == "Linux" ]]; then
  IS_LINUX_X86=$([[ "$ARCH" == "x86_64" ]] && echo true || echo false)
  IS_LINUX_ARM=$([[ "$ARCH" == arm* || "$ARCH" == "aarch64" ]] && echo true || echo false)
elif [[ "$OS" == "Darwin" ]]; then
  IS_MACOS=true
  IS_MACOS_X86=$([[ "$ARCH" == "x86_64" ]] && echo true || echo false)
  IS_MACOS_ARM=$([[ "$ARCH" == "arm64" ]] && echo true || echo false)
fi

# Check if running on macOS
if [[ "$IS_MACOS_ARM" = true ]]; then
  PLATFORM="macos"
  echo "macOS on ARM detected, proceeding with installation."
elif [[ "$IS_MACOS_X86" = true ]]; then
  PLATFORM="macos"
  echo "macOS on x86_64 detected, proceeding with installation."
elif [[ "$IS_LINUX_ARM" = true ]]; then
  PLATFORM="linux-arm"
  echo "Ubuntu on ARM detected, proceeding with installation."
elif [[ "$IS_LINUX_X86" = true ]]; then
  echo "Looks like you are running on Ubuntu on x86_64. Use original Omakub without this extension"
  exit 1
else
  echo "You are running it on something else, which probably doesn't work."
  exit 1
fi

# Update package manager and install git
if [[ "$IS_MACOS" = true ]]; then
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH based on architecture
    if [[ "$IS_MACOS_ARM" = true ]]; then
      # For Apple Silicon Macs
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      # For Intel Macs
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
      eval "$(/usr/local/bin/brew shellenv)"
    fi
  else
    echo "Homebrew already installed, updating..."
    brew update
  fi
  brew install git >/dev/null
else
  sudo apt-get update >/dev/null
  sudo apt-get install -y git >/dev/null
fi

echo "Cloning Omakub..."
rm -rf ~/.local/share/omakub
git clone https://github.com/DoppioJP/omakub4all.git ~/.local/share/omakub >/dev/null
OMAKUB_REF="$PLATFORM"
if [[ $OMAKUB_REF != "master" ]]; then
	cd ~/.local/share/omakub
	git fetch origin "${OMAKUB_REF:-stable}" && git checkout "${OMAKUB_REF:-stable}"
	cd -
fi

echo "Starting Omakub for $PLATFORM installation..."
# bash ~/.local/share/omakub/$PLATFORM/install.sh
