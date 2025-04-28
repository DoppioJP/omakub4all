#!/usr/bin/env bash

# macOS Dock configuration script
# This script configures the macOS Dock with commonly used applications using dockutil

echo "Configuring macOS Dock..."

# Install dockutil if it's not already installed
if ! command -v dockutil &> /dev/null; then
  echo "Installing dockutil..."
  brew install dockutil
fi

# Find the Applications directory on the same disk as the home folder
find_applications_dir() {
  # Get the disk device for the home directory
  local home_disk=$(df "$HOME" | grep -v Filesystem | awk '{print $1}')

  # Find all mounted volumes
  local volumes=$(df | grep -v Filesystem | awk '{print $1 " " $9}')

  # Look for Applications directories on mounted volumes
  local app_dirs=()
  while read -r disk mount; do
    if [ "$disk" = "$home_disk" ] && [ -d "$mount/Applications" ]; then
      app_dirs+=("$mount/Applications")
    fi
  done <<< "$volumes"

  # If we found Applications directories on the same disk, return the first one
  if [ ${#app_dirs[@]} -gt 0 ]; then
    echo "${app_dirs[0]}"
    return 0
  fi

  # Fallback to standard Applications directory
  echo "/Applications"
  return 1
}

# Get the Applications directory on the same disk as home
APP_DIR=$(find_applications_dir)
UTIL_DIR="$APP_DIR/Utilities"

echo "Using Applications directory: $APP_DIR"
echo "Using Utilities directory: $UTIL_DIR"

# First, remove all apps from the Dock
echo "Removing all apps from Dock..."
dockutil --remove all --no-restart

# Function to add an app to the Dock if it exists
add_app_to_dock() {
  local app_path="$1"

  # Expand the path if it contains a tilde
  app_path="${app_path/#\~/$HOME}"

  # Check if the app exists
  if [ -d "$app_path" ]; then
    echo "Adding $(basename "$app_path") to Dock"
    dockutil --add "$app_path" --no-restart
    return 0
  else
    # Quietly fail if app not found
    return 1
  fi
}

# Function to add a system app to the Dock using bundle ID instead of path
# This works better for system apps like Safari that might have symlink issues
add_system_app_to_dock() {
  local bundle_id="$1"
  local app_name="$2"

  echo "Adding $app_name to Dock using bundle ID"

  dockutil --add "$bundle_id" --no-restart
  return 0
}

# List of applications to add to the Dock
# Using the macOS versions of the applications you've installed

# System applications
add_app_to_dock "/System/Applications/Finder.app"
add_app_to_dock "/System/Applications/System Settings.app" || add_app_to_dock "/System/Applications/System Preferences.app"

# Browsers
add_app_to_dock "/Applications/Safari.app"
add_app_to_dock "$UTIL_DIR/Chromium.app" || add_app_to_dock "$APP_DIR/Chromium.app" || add_app_to_dock "/Applications/Google Chrome.app"
add_app_to_dock "$UTIL_DIR/Brave Browser.app" || add_app_to_dock "$APP_DIR/Brave Browser.app" || add_app_to_dock "/Applications/Brave Browser.app"

# Terminal and development tools
add_app_to_dock "$HOME/Applications/Neovim.app" || add_app_to_dock "$APP_DIR/Neovim.app"
add_app_to_dock "$UTIL_DIR/Visual Studio Code.app" || add_app_to_dock "$APP_DIR/Visual Studio Code.app"
add_app_to_dock "$UTIL_DIR/Docker.app" || add_app_to_dock "$APP_DIR/Docker.app"

# Communication apps
add_app_to_dock "$UTIL_DIR/WhatsApp.app" || add_app_to_dock "$APP_DIR/WhatsApp.app"
add_app_to_dock "$UTIL_DIR/Signal.app" || add_app_to_dock "$APP_DIR/Signal.app"
add_app_to_dock "$UTIL_DIR/Zoom.app" || add_app_to_dock "$APP_DIR/zoom.us.app" || add_app_to_dock "$APP_DIR/Zoom.app"

# Media and productivity
add_app_to_dock "$UTIL_DIR/Spotify.app" || add_app_to_dock "$APP_DIR/Spotify.app"
add_app_to_dock "$UTIL_DIR/Steam.app" || add_app_to_dock "$APP_DIR/Steam.app"
add_app_to_dock "$UTIL_DIR/Krita.app" || add_app_to_dock "$APP_DIR/Krita.app" # Using Krita instead of Pinta as per your changes
add_app_to_dock "$UTIL_DIR/Obsidian.app" || add_app_to_dock "$APP_DIR/Obsidian.app"
add_app_to_dock "$UTIL_DIR/1Password.app" || add_app_to_dock "$APP_DIR/1Password.app"

# Utilities
add_app_to_dock "$UTIL_DIR/LocalSend.app" || add_app_to_dock "$APP_DIR/LocalSend.app"

# Restart the Dock to apply changes
echo "Restarting Dock to apply changes..."
killall Dock

echo "macOS Dock configuration complete!"
