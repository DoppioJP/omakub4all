# Create the necessary directory structure
mkdir -p ~/Applications/Neovim.app/Contents/Resources

# Create Info.plist
cat <<EOF >~/Applications/Neovim.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleName</key>
        <string>Neovim</string>
        <key>CFBundleExecutable</key>
        <string>Neovim</string>
        <key>CFBundleIdentifier</key>
        <string>com.neovim.Neovim</string>
        <key>CFBundleIconFile</key>
        <string>neovim.icns</string>
        <key>NSPrincipalClass</key>
        <string>NSApplication</string>
        <key>UTExportedTypeDeclarations</key>
        <array>
            <dict>
                <key>UTTypeConformsTo</key>
                <array>
                    <string>public.text</string>
                </array>
                <key>UTTypeDescription</key>
                <string>Text File</string>
                <key>UTTypeIdentifier</key>
                <string>public.text</string>
                <key>UTTypeTagSpecification</key>
                <dict>
                    <key>public.filename-extension</key>
                    <array>
                        <string>txt</string>
                    </array>
                    <key>public.mime-type</key>
                    <string>text/plain</string>
                </dict>
            </dict>
        </array>
        <key>UTImportedTypeDeclarations</key>
        <array/>
        <key>UTTypeReference</key>
        <dict>
            <key>UTTypeIdentifier</key>
            <string>public.text</string>
        </dict>
    </dict>
</plist>
EOF

# Create the MacOS directory for the executable
mkdir -p ~/Applications/Neovim.app/Contents/MacOS

# Create the executable script directly in the MacOS directory
cat <<'EOF' >~/Applications/Neovim.app/Contents/MacOS/Neovim
#!/bin/bash

# Set up error logging
exec 2>>/tmp/neovim-app-error.log

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
echo "PATH: $PATH" >> /tmp/neovim-app-error.log
echo "USER: $USER" >> /tmp/neovim-app-error.log

# Make sure we have the full path to nvim
NVIM_PATH=$(which nvim 2>/dev/null)
if [ -z "$NVIM_PATH" ]; then
  # Try common locations if which fails
  for path in /usr/local/bin/nvim /opt/homebrew/bin/nvim /usr/bin/nvim; do
    if [ -x "$path" ]; then
      NVIM_PATH="$path"
      break
    fi
  done

  # If still not found, show an error dialog
  if [ -z "$NVIM_PATH" ]; then
    osascript -e 'display dialog "Neovim executable not found. Please make sure Neovim is installed." buttons {"OK"} default button "OK" with icon stop with title "Neovim Error"'
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
echo "Found NVIM_PATH: $NVIM_PATH" >> /tmp/neovim-app-error.log
echo "Found ALACRITTY_PATH: $ALACRITTY_PATH" >> /tmp/neovim-app-error.log

if [ -n "$ALACRITTY_PATH" ]; then
  # Check if config file exists
  if [ -f "$HOME/.config/alacritty/pane.toml" ]; then
    echo "Using Alacritty with config" >> /tmp/neovim-app-error.log
    "$ALACRITTY_PATH" --config-file "$HOME/.config/alacritty/pane.toml" --class=Neovim --title=Neovim -e "$NVIM_PATH" "$@" &
  else
    echo "Using Alacritty without config" >> /tmp/neovim-app-error.log
    "$ALACRITTY_PATH" --class=Neovim --title=Neovim -e "$NVIM_PATH" "$@" &
  fi
else
  # Try to use iTerm2 if Alacritty is not available
  if osascript -e 'tell application "System Events" to return exists application process "iTerm2"' 2>/dev/null | grep -q "true"; then
    echo "Falling back to iTerm2" >> /tmp/neovim-app-error.log
    osascript <<APPLESCRIPT
      tell application "iTerm2"
        create window with default profile
        tell current session of current window
          write text "$NVIM_PATH $*"
        end tell
      end tell
APPLESCRIPT
  else
    # Fallback to Terminal.app
    echo "Falling back to Terminal.app" >> /tmp/neovim-app-error.log
    osascript <<APPLESCRIPT
      tell application "Terminal"
        do script "$NVIM_PATH $*"
        activate
      end tell
APPLESCRIPT
  fi
fi
EOF

# Make the script executable
chmod +x ~/Applications/Neovim.app/Contents/MacOS/Neovim

# Download Neovim icon if it doesn't exist
if [ ! -f ~/Applications/Neovim.app/Contents/Resources/neovim.icns ]; then
  echo "Downloading Neovim icon..."
  curl -s -L "https://raw.githubusercontent.com/neovim/neovim.github.io/master/logos/neovim-mark.png" -o /tmp/neovim-mark.png

  # Convert PNG to ICNS (requires png2icns or sips)
  if command -v sips &> /dev/null && command -v iconutil &> /dev/null; then
    mkdir -p /tmp/neovim.iconset
    sips -z 16 16 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_16x16.png
    sips -z 32 32 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_16x16@2x.png
    sips -z 32 32 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_32x32.png
    sips -z 64 64 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_32x32@2x.png
    sips -z 128 128 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_128x128.png
    sips -z 256 256 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_128x128@2x.png
    sips -z 256 256 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_256x256.png
    sips -z 512 512 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_256x256@2x.png
    sips -z 512 512 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_512x512.png
    sips -z 1024 1024 /tmp/neovim-mark.png --out /tmp/neovim.iconset/icon_512x512@2x.png
    iconutil -c icns /tmp/neovim.iconset -o ~/Applications/Neovim.app/Contents/Resources/neovim.icns
    rm -rf /tmp/neovim.iconset
  else
    # Fallback to just copying the PNG if conversion tools aren't available
    cp /tmp/neovim-mark.png ~/Applications/Neovim.app/Contents/Resources/neovim.png
    # Update the plist to use PNG instead of ICNS
    sed -i '' 's/neovim.icns/neovim.png/g' ~/Applications/Neovim.app/Contents/Info.plist
  fi

  rm -f /tmp/neovim-mark.png
fi

echo "Neovim.app created successfully in ~/Applications/"
