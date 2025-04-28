# Create the necessary directory structure for About.app
mkdir -p ~/Applications/About.app/Contents/Resources

# Create Info.plist
cat <<EOF >~/Applications/About.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleName</key>
        <string>About</string>
        <key>CFBundleExecutable</key>
        <string>About</string>
        <key>CFBundleIdentifier</key>
        <string>org.omakub.About</string>
        <key>CFBundleIconFile</key>
        <string>about.icns</string>
        <key>NSPrincipalClass</key>
        <string>NSApplication</string>
    </dict>
</plist>
EOF

# Create the MacOS directory for the executable
mkdir -p ~/Applications/About.app/Contents/MacOS

# Create the executable script
cat <<'EOF' >~/Applications/About.app/Contents/MacOS/About
#!/bin/bash

# Set up error logging
exec 2>>/tmp/about-app-error.log

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
echo "PATH: $PATH" >> /tmp/about-app-error.log
echo "USER: $USER" >> /tmp/about-app-error.log

# Make sure we have the full path to fastfetch
FASTFETCH_PATH=$(which fastfetch 2>/dev/null)
if [ -z "$FASTFETCH_PATH" ]; then
  # Try common locations if which fails
  for path in /usr/local/bin/fastfetch /opt/homebrew/bin/fastfetch /usr/bin/fastfetch; do
    if [ -x "$path" ]; then
      FASTFETCH_PATH="$path"
      break
    fi
  done

  # If still not found, show an error dialog
  if [ -z "$FASTFETCH_PATH" ]; then
    osascript -e 'display dialog "Fastfetch executable not found. Please make sure Fastfetch is installed." buttons {"OK"} default button "OK" with icon stop with title "About Error"'
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
echo "Found FASTFETCH_PATH: $FASTFETCH_PATH" >> /tmp/about-app-error.log
echo "Found ALACRITTY_PATH: $ALACRITTY_PATH" >> /tmp/about-app-error.log

if [ -n "$ALACRITTY_PATH" ]; then
  # Check if config file exists
  if [ -f "$HOME/.config/alacritty/pane.toml" ]; then
    echo "Using Alacritty with config" >> /tmp/about-app-error.log
    "$ALACRITTY_PATH" --config-file "$HOME/.config/alacritty/pane.toml" --class=About --title=About -e bash -c "$FASTFETCH_PATH; read -n 1 -s" &
  else
    echo "Using Alacritty without config" >> /tmp/about-app-error.log
    "$ALACRITTY_PATH" --class=About --title=About -e bash -c "$FASTFETCH_PATH; read -n 1 -s" &
  fi
else
  # Try to use iTerm2 if Alacritty is not available
  if osascript -e 'tell application "System Events" to return exists application process "iTerm2"' 2>/dev/null | grep -q "true"; then
    echo "Falling back to iTerm2" >> /tmp/about-app-error.log
    osascript <<APPLESCRIPT
      tell application "iTerm2"
        create window with default profile
        tell current session of current window
          write text "$FASTFETCH_PATH; read -n 1 -s"
        end tell
      end tell
APPLESCRIPT
  else
    # Fallback to Terminal.app
    echo "Falling back to Terminal.app" >> /tmp/about-app-error.log
    osascript <<APPLESCRIPT
      tell application "Terminal"
        do script "$FASTFETCH_PATH; read -n 1 -s"
        activate
      end tell
APPLESCRIPT
  fi
fi
EOF

# Make the script executable
chmod +x ~/Applications/About.app/Contents/MacOS/About

# Use macOS logo for the About app
if [ ! -f ~/Applications/About.app/Contents/Resources/about.icns ]; then
  echo "Using macOS logo for About app..."
  
  # Use the system's macOS logo if available
  if [ -f /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.macbookpro-13-silver.icns ]; then
    cp /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.macbookpro-13-silver.icns ~/Applications/About.app/Contents/Resources/about.icns
  elif [ -f /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.macbookpro-13-m1.icns ]; then
    cp /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.macbookpro-13-m1.icns ~/Applications/About.app/Contents/Resources/about.icns
  elif [ -f /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.macbookpro-silver.icns ]; then
    cp /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.macbookpro-silver.icns ~/Applications/About.app/Contents/Resources/about.icns
  elif [ -f /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacSolid.icns ]; then
    cp /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarMacSolid.icns ~/Applications/About.app/Contents/Resources/about.icns
  elif [ -f /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.mac.icns ]; then
    cp /System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/com.apple.mac.icns ~/Applications/About.app/Contents/Resources/about.icns
  elif [ -f /System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns ]; then
    # Fallback to Finder icon if no Mac icons found
    cp /System/Library/CoreServices/Finder.app/Contents/Resources/Finder.icns ~/Applications/About.app/Contents/Resources/about.icns
  else
    # If no system icons are available, use the Apple logo from System Information
    cp /System/Library/CoreServices/Applications/System\ Information.app/Contents/Resources/ProductPageIcon.icns ~/Applications/About.app/Contents/Resources/about.icns 2>/dev/null || true
  fi
  
  # If none of the above worked, try to use the Apple logo from About This Mac
  if [ ! -f ~/Applications/About.app/Contents/Resources/about.icns ]; then
    # Try to extract the Apple logo from the system
    cp /System/Library/PrivateFrameworks/AppleSystemInfo.framework/Versions/A/Resources/ProductPageIcon.icns ~/Applications/About.app/Contents/Resources/about.icns 2>/dev/null || true
  fi
  
  # If we still don't have an icon, create a simple one with text
  if [ ! -f ~/Applications/About.app/Contents/Resources/about.icns ]; then
    echo "No system macOS icons found, creating a simple icon..."
    
    # Create a temporary PNG with text "macOS"
    if command -v convert &> /dev/null; then
      convert -size 512x512 -background white -fill black -gravity center -font Arial label:"macOS" /tmp/about-icon.png
    else
      # If ImageMagick is not available, create a blank PNG
      echo "<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"512\" height=\"512\"><rect width=\"512\" height=\"512\" fill=\"white\"/><text x=\"50%\" y=\"50%\" font-family=\"Arial\" font-size=\"72\" text-anchor=\"middle\" fill=\"black\">macOS</text></svg>" > /tmp/about-icon.svg
      
      if command -v rsvg-convert &> /dev/null; then
        rsvg-convert -h 512 /tmp/about-icon.svg > /tmp/about-icon.png
      else
        # Create a blank PNG if no conversion tools are available
        echo "iVBORw0KGgoAAAANSUhEUgAAAgAAAAIAAQMAAADOtka5AAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAADZJREFUeJztwQEBAAAAgiD/r25IQAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAfBuCAAAB0niJ8AAAAABJRU5ErkJggg==" | base64 -d > /tmp/about-icon.png
      fi
    fi
    
    # Convert PNG to ICNS
    if command -v sips &> /dev/null && command -v iconutil &> /dev/null; then
      mkdir -p /tmp/about.iconset
      sips -z 16 16 /tmp/about-icon.png --out /tmp/about.iconset/icon_16x16.png
      sips -z 32 32 /tmp/about-icon.png --out /tmp/about.iconset/icon_16x16@2x.png
      sips -z 32 32 /tmp/about-icon.png --out /tmp/about.iconset/icon_32x32.png
      sips -z 64 64 /tmp/about-icon.png --out /tmp/about.iconset/icon_32x32@2x.png
      sips -z 128 128 /tmp/about-icon.png --out /tmp/about.iconset/icon_128x128.png
      sips -z 256 256 /tmp/about-icon.png --out /tmp/about.iconset/icon_128x128@2x.png
      sips -z 256 256 /tmp/about-icon.png --out /tmp/about.iconset/icon_256x256.png
      sips -z 512 512 /tmp/about-icon.png --out /tmp/about.iconset/icon_256x256@2x.png
      sips -z 512 512 /tmp/about-icon.png --out /tmp/about.iconset/icon_512x512.png
      sips -z 1024 1024 /tmp/about-icon.png --out /tmp/about.iconset/icon_512x512@2x.png
      iconutil -c icns /tmp/about.iconset -o ~/Applications/About.app/Contents/Resources/about.icns
      rm -rf /tmp/about.iconset
    else
      # Fallback to just copying the PNG if conversion tools aren't available
      cp /tmp/about-icon.png ~/Applications/About.app/Contents/Resources/about.png
      # Update the plist to use PNG instead of ICNS
      sed -i '' 's/about.icns/about.png/g' ~/Applications/About.app/Contents/Info.plist
    fi
    
    # Clean up temporary files
    rm -f /tmp/about-icon.svg /tmp/about-icon.png
  fi
fi

echo "About.app created successfully in ~/Applications/"
