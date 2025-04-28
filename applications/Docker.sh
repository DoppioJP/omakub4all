# Create the necessary directory structure for Docker.app
mkdir -p ~/Applications/Docker.app/Contents/Resources
mkdir -p ~/Applications/Docker.app/Contents/MacOS

# Create Info.plist
cat <<EOF >~/Applications/Docker.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleName</key>
        <string>Docker</string>
        <key>CFBundleExecutable</key>
        <string>Docker</string>
        <key>CFBundleIdentifier</key>
        <string>org.omakub.Docker</string>
        <key>CFBundleIconFile</key>
        <string>docker.icns</string>
        <key>NSPrincipalClass</key>
        <string>NSApplication</string>
    </dict>
</plist>
EOF

# Create the executable script
cat <<'EOF' >~/Applications/Docker.app/Contents/MacOS/Docker
#!/bin/bash

# Set up error logging
exec 2>>/tmp/docker-app-error.log

# Add common paths to PATH to ensure executables can be found
export PATH="$PATH:/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Load user's shell environment if possible
if [ -f "$HOME/.zshrc" ]; then
  source "$HOME/.zshrc" >/dev/null 2>&1 || true
elif [ -f "$HOME/.bash_profile" ]; then
  source "$HOME/.bash_profile" >/dev/null 2>&1 || true
elif [ -f "$HOME/.profile" ]; then
  source "$HOME/.profile" >/dev/null 2>&1 || true
fi

# Log environment for debugging
echo "PATH: $PATH" >> /tmp/docker-app-error.log
echo "USER: $USER" >> /tmp/docker-app-error.log

# Make sure we have the full path to lazydocker
LAZYDOCKER_PATH=$(which lazydocker 2>/dev/null)
if [ -z "$LAZYDOCKER_PATH" ]; then
  # Try common locations if which fails
  for path in /usr/local/bin/lazydocker /opt/homebrew/bin/lazydocker /usr/bin/lazydocker "$HOME/.local/bin/lazydocker"; do
    if [ -x "$path" ]; then
      LAZYDOCKER_PATH="$path"
      break
    fi
  done

  # If still not found, show an error dialog
  if [ -z "$LAZYDOCKER_PATH" ]; then
    osascript -e 'display dialog "lazydocker executable not found. Please make sure lazydocker is installed." buttons {"OK"} default button "OK" with icon stop with title "Docker Error"'
    exit 1
  fi
fi

# Check for Alacritty in multiple ways
ALACRITTY_PATH=$(which alacritty 2>/dev/null)

# If not found via which, try common locations
if [ -z "$ALACRITTY_PATH" ]; then
  for path in /usr/local/bin/alacritty /opt/homebrew/bin/alacritty /Applications/Alacritty.app/Contents/MacOS/alacritty; do
    if [ -x "$path" ]; then
      ALACRITTY_PATH="$path"
      break
    fi
  done
fi

# Log what we found
echo "Found LAZYDOCKER_PATH: $LAZYDOCKER_PATH" >> /tmp/docker-app-error.log
echo "Found ALACRITTY_PATH: $ALACRITTY_PATH" >> /tmp/docker-app-error.log

if [ -n "$ALACRITTY_PATH" ]; then
  # Check if pane.toml config file exists
  if [ -f "$HOME/.config/alacritty/pane.toml" ]; then
    echo "Using Alacritty with pane.toml config" >> /tmp/docker-app-error.log
    "$ALACRITTY_PATH" --config-file "$HOME/.config/alacritty/pane.toml" --class=Docker --title=Docker -e "$LAZYDOCKER_PATH" &
  else
    echo "Using Alacritty without config" >> /tmp/docker-app-error.log
    "$ALACRITTY_PATH" --class=Docker --title=Docker -e "$LAZYDOCKER_PATH" &
  fi
else
  # Try to use iTerm2 if Alacritty is not available
  if osascript -e 'tell application "System Events" to return exists application process "iTerm2"' 2>/dev/null | grep -q "true"; then
    echo "Falling back to iTerm2" >> /tmp/docker-app-error.log
    osascript <<APPLESCRIPT
      tell application "iTerm2"
        create window with default profile
        tell current session of current window
          write text "$LAZYDOCKER_PATH"
        end tell
      end tell
APPLESCRIPT
  else
    # Fallback to Terminal.app
    echo "Falling back to Terminal.app" >> /tmp/docker-app-error.log
    osascript <<APPLESCRIPT
      tell application "Terminal"
        do script "$LAZYDOCKER_PATH"
        activate
      end tell
APPLESCRIPT
  fi
fi
EOF

# Make the script executable
chmod +x ~/Applications/Docker.app/Contents/MacOS/Docker

# Copy the Docker icon from the omakub icons directory
echo "Using Docker icon from omakub..."
mkdir -p /tmp/docker.iconset

# Convert PNG to ICNS using sips and iconutil
if command -v sips &> /dev/null && command -v iconutil &> /dev/null; then
    # Create different sizes for the iconset
    sips -z 16 16 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_16x16.png
    sips -z 32 32 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_16x16@2x.png
    sips -z 32 32 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_32x32.png
    sips -z 64 64 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_32x32@2x.png
    sips -z 128 128 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_128x128.png
    sips -z 256 256 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_128x128@2x.png
    sips -z 256 256 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_256x256.png
    sips -z 512 512 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_256x256@2x.png
    sips -z 512 512 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_512x512.png
    sips -z 1024 1024 ~/.local/share/omakub/applications/icons/Docker.png --out /tmp/docker.iconset/icon_512x512@2x.png
    
    # Convert the iconset to icns
    iconutil -c icns /tmp/docker.iconset -o ~/Applications/Docker.app/Contents/Resources/docker.icns
    rm -rf /tmp/docker.iconset
else
    # Fallback to just copying the PNG if conversion tools aren't available
    cp ~/.local/share/omakub/applications/icons/Docker.png ~/Applications/Docker.app/Contents/Resources/docker.png
    # Update the plist to use PNG instead of ICNS
    sed -i '' 's/docker.icns/docker.png/g' ~/Applications/Docker.app/Contents/Info.plist
fi

echo "Docker.app created successfully in ~/Applications/"
