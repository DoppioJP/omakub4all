# Check if Docker is already installed via Homebrew
if brew list --cask docker &>/dev/null; then
  echo "Docker is installed via Homebrew. Checking for updates..."
  brew upgrade --cask docker
else
  # Check if Docker.app exists anywhere (could be in a custom location)
  # First try to find it using mdfind (macOS Spotlight)
  if mdfind "kMDItemCFBundleIdentifier == 'com.docker.docker'" | grep -q ".app"; then
    echo "Docker.app found, but not managed by Homebrew."
    echo "Please use Docker Desktop's built-in update mechanism instead."
  else
    echo "Installing Docker..."
    brew install --cask docker
  fi
fi

# Ensure Docker CLI is available
if ! command -v docker &> /dev/null; then
  echo "Docker CLI not found. Please make sure Docker Desktop is properly installed and running."
else
  # Display current Docker version
  echo "Docker installation verified:"
  docker --version
fi
