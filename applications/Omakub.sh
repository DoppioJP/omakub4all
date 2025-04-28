# Create the necessary directory structure for Omakub.app
mkdir -p ~/Applications/Omakub.app/Contents/Resources
mkdir -p ~/Applications/Omakub.app/Contents/MacOS

# Create Info.plist
cat <<EOF >~/Applications/Omakub.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleName</key>
        <string>Omakub</string>
        <key>CFBundleExecutable</key>
        <string>Omakub</string>
        <key>CFBundleIdentifier</key>
        <string>org.omakub.Omakub</string>
        <key>CFBundleIconFile</key>
        <string>omakub.icns</string>
        <key>NSPrincipalClass</key>
        <string>NSApplication</string>
    </dict>
</plist>
EOF

# Create the executable script
cat <<'EOF' >~/Applications/Omakub.app/Contents/MacOS/Omakub
#!/bin/bash

# Set up error logging
exec 2>>/tmp/omakub-app-error.log

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
echo "PATH: $PATH" >> /tmp/omakub-app-error.log
echo "USER: $USER" >> /tmp/omakub-app-error.log

# Make sure we have the full path to omakub
OMAKUB_PATH=$(which omakub 2>/dev/null)
if [ -z "$OMAKUB_PATH" ]; then
  # Try common locations if which fails
  for path in /usr/local/bin/omakub /opt/homebrew/bin/omakub /usr/bin/omakub "$HOME/.local/bin/omakub"; do
    if [ -x "$path" ]; then
      OMAKUB_PATH="$path"
      break
    fi
  done

  # If still not found, show an error dialog
  if [ -z "$OMAKUB_PATH" ]; then
    osascript -e 'display dialog "Omakub executable not found. Please make sure Omakub is installed." buttons {"OK"} default button "OK" with icon stop with title "Omakub Error"'
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
echo "Found OMAKUB_PATH: $OMAKUB_PATH" >> /tmp/omakub-app-error.log
echo "Found ALACRITTY_PATH: $ALACRITTY_PATH" >> /tmp/omakub-app-error.log

if [ -n "$ALACRITTY_PATH" ]; then
  # Check if pane.toml config file exists
  if [ -f "$HOME/.config/alacritty/pane.toml" ]; then
    echo "Using Alacritty with pane.toml config" >> /tmp/omakub-app-error.log
    "$ALACRITTY_PATH" --config-file "$HOME/.config/alacritty/pane.toml" --class=Omakub --title=Omakub -e "$OMAKUB_PATH" &
  else
    echo "Using Alacritty without config" >> /tmp/omakub-app-error.log
    "$ALACRITTY_PATH" --class=Omakub --title=Omakub -e "$OMAKUB_PATH" &
  fi
else
  # Try to use iTerm2 if Alacritty is not available
  if osascript -e 'tell application "System Events" to return exists application process "iTerm2"' 2>/dev/null | grep -q "true"; then
    echo "Falling back to iTerm2" >> /tmp/omakub-app-error.log
    osascript <<APPLESCRIPT
      tell application "iTerm2"
        create window with default profile
        tell current session of current window
          write text "$OMAKUB_PATH"
        end tell
      end tell
APPLESCRIPT
  else
    # Fallback to Terminal.app
    echo "Falling back to Terminal.app" >> /tmp/omakub-app-error.log
    osascript <<APPLESCRIPT
      tell application "Terminal"
        do script "$OMAKUB_PATH"
        activate
      end tell
APPLESCRIPT
  fi
fi
EOF

# Make the script executable
chmod +x ~/Applications/Omakub.app/Contents/MacOS/Omakub

# Copy the Omakub icon from the omakub icons directory
echo "Using Omakub icon from omakub..."
mkdir -p /tmp/omakub.iconset

# Convert PNG to ICNS using sips and iconutil
if command -v sips &> /dev/null && command -v iconutil &> /dev/null; then
    # Create different sizes for the iconset
    sips -z 16 16 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_16x16.png
    sips -z 32 32 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_16x16@2x.png
    sips -z 32 32 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_32x32.png
    sips -z 64 64 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_32x32@2x.png
    sips -z 128 128 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_128x128.png
    sips -z 256 256 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_128x128@2x.png
    sips -z 256 256 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_256x256.png
    sips -z 512 512 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_256x256@2x.png
    sips -z 512 512 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_512x512.png
    sips -z 1024 1024 ~/.local/share/omakub/applications/icons/Omakub.png --out /tmp/omakub.iconset/icon_512x512@2x.png
    
    # Convert the iconset to icns
    iconutil -c icns /tmp/omakub.iconset -o ~/Applications/Omakub.app/Contents/Resources/omakub.icns
    rm -rf /tmp/omakub.iconset
else
    # Fallback to just copying the PNG if conversion tools aren't available
    cp ~/.local/share/omakub/applications/icons/Omakub.png ~/Applications/Omakub.app/Contents/Resources/omakub.png
    # Update the plist to use PNG instead of ICNS
    sed -i '' 's/omakub.icns/omakub.png/g' ~/Applications/Omakub.app/Contents/Info.plist
fi

echo "Omakub.app created successfully in ~/Applications/"
