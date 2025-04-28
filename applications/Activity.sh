# Create the necessary directory structure for Activity.app
mkdir -p ~/Applications/Activity.app/Contents/Resources

# Create Info.plist
cat <<EOF >~/Applications/Activity.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleName</key>
        <string>Activity</string>
        <key>CFBundleExecutable</key>
        <string>Activity</string>
        <key>CFBundleIdentifier</key>
        <string>org.omakub.Activity</string>
        <key>CFBundleIconFile</key>
        <string>activity.icns</string>
        <key>NSPrincipalClass</key>
        <string>NSApplication</string>
    </dict>
</plist>
EOF

# Create the MacOS directory for the executable
mkdir -p ~/Applications/Activity.app/Contents/MacOS

# Create the executable script
cat <<'EOF' >~/Applications/Activity.app/Contents/MacOS/Activity
#!/bin/bash

# Set up error logging
exec 2>>/tmp/activity-app-error.log

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
echo "PATH: $PATH" >> /tmp/activity-app-error.log
echo "USER: $USER" >> /tmp/activity-app-error.log

# Make sure we have the full path to btop
BTOP_PATH=$(which btop 2>/dev/null)
if [ -z "$BTOP_PATH" ]; then
  # Try common locations if which fails
  for path in /usr/local/bin/btop /opt/homebrew/bin/btop /usr/bin/btop; do
    if [ -x "$path" ]; then
      BTOP_PATH="$path"
      break
    fi
  done

  # If still not found, show an error dialog
  if [ -z "$BTOP_PATH" ]; then
    osascript -e 'display dialog "btop executable not found. Please make sure btop is installed." buttons {"OK"} default button "OK" with icon stop with title "Activity Error"'
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
echo "Found BTOP_PATH: $BTOP_PATH" >> /tmp/activity-app-error.log
echo "Found ALACRITTY_PATH: $ALACRITTY_PATH" >> /tmp/activity-app-error.log

if [ -n "$ALACRITTY_PATH" ]; then
  # Check if btop config file exists
  if [ -f "$HOME/.config/alacritty/btop.toml" ]; then
    echo "Using Alacritty with btop config" >> /tmp/activity-app-error.log
    "$ALACRITTY_PATH" --config-file "$HOME/.config/alacritty/btop.toml" --class=Activity --title=Activity -e "$BTOP_PATH" &
  # Check if pane config file exists as fallback
  elif [ -f "$HOME/.config/alacritty/pane.toml" ]; then
    echo "Using Alacritty with pane config" >> /tmp/activity-app-error.log
    "$ALACRITTY_PATH" --config-file "$HOME/.config/alacritty/pane.toml" --class=Activity --title=Activity -e "$BTOP_PATH" &
  else
    echo "Using Alacritty without config" >> /tmp/activity-app-error.log
    "$ALACRITTY_PATH" --class=Activity --title=Activity -e "$BTOP_PATH" &
  fi
else
  # Try to use iTerm2 if Alacritty is not available
  if osascript -e 'tell application "System Events" to return exists application process "iTerm2"' 2>/dev/null | grep -q "true"; then
    echo "Falling back to iTerm2" >> /tmp/activity-app-error.log
    osascript <<APPLESCRIPT
      tell application "iTerm2"
        create window with default profile
        tell current session of current window
          write text "$BTOP_PATH"
        end tell
      end tell
APPLESCRIPT
  else
    # Fallback to Terminal.app
    echo "Falling back to Terminal.app" >> /tmp/activity-app-error.log
    osascript <<APPLESCRIPT
      tell application "Terminal"
        do script "$BTOP_PATH"
        activate
      end tell
APPLESCRIPT
  fi
fi
EOF

# Make the script executable
chmod +x ~/Applications/Activity.app/Contents/MacOS/Activity

# Copy the Activity icon from the omakub icons directory
if [ -f ~/.local/share/omakub/applications/icons/Activity.png ]; then
  echo "Using existing Activity icon from omakub..."
  mkdir -p /tmp/activity.iconset
  
  # Convert PNG to ICNS using sips and iconutil
  if command -v sips &> /dev/null && command -v iconutil &> /dev/null; then
    # Create different sizes for the iconset
    sips -z 16 16 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_16x16.png
    sips -z 32 32 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_16x16@2x.png
    sips -z 32 32 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_32x32.png
    sips -z 64 64 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_32x32@2x.png
    sips -z 128 128 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_128x128.png
    sips -z 256 256 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_128x128@2x.png
    sips -z 256 256 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_256x256.png
    sips -z 512 512 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_256x256@2x.png
    sips -z 512 512 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_512x512.png
    sips -z 1024 1024 ~/.local/share/omakub/applications/icons/Activity.png --out /tmp/activity.iconset/icon_512x512@2x.png
    
    # Convert the iconset to icns
    iconutil -c icns /tmp/activity.iconset -o ~/Applications/Activity.app/Contents/Resources/activity.icns
    rm -rf /tmp/activity.iconset
  else
    # Fallback to just copying the PNG if conversion tools aren't available
    cp ~/.local/share/omakub/applications/icons/Activity.png ~/Applications/Activity.app/Contents/Resources/activity.png
    # Update the plist to use PNG instead of ICNS
    sed -i '' 's/activity.icns/activity.png/g' ~/Applications/Activity.app/Contents/Info.plist
  fi
else
  echo "Activity icon not found in omakub, using system icon..."
  # Use a system icon as fallback
  cp /System/Library/CoreServices/Activity\ Monitor.app/Contents/Resources/ActivityMonitor.icns ~/Applications/Activity.app/Contents/Resources/activity.icns 2>/dev/null || true
fi

echo "Activity.app created successfully in ~/Applications/"
