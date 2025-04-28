# Create the necessary directory structure for Basecamp.app
mkdir -p ~/Applications/Basecamp.app/Contents/Resources
mkdir -p ~/Applications/Basecamp.app/Contents/MacOS

# Create Info.plist
cat <<EOF >~/Applications/Basecamp.app/Contents/Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>CFBundleName</key>
        <string>Basecamp</string>
        <key>CFBundleExecutable</key>
        <string>Basecamp</string>
        <key>CFBundleIdentifier</key>
        <string>org.omakub.Basecamp</string>
        <key>CFBundleIconFile</key>
        <string>basecamp.icns</string>
        <key>NSPrincipalClass</key>
        <string>NSApplication</string>
        <key>CFBundleURLTypes</key>
        <array>
            <dict>
                <key>CFBundleURLName</key>
                <string>Basecamp URL</string>
                <key>CFBundleURLSchemes</key>
                <array>
                    <string>https</string>
                </array>
            </dict>
        </array>
    </dict>
</plist>
EOF

# Create the executable script
cat <<'EOF' >~/Applications/Basecamp.app/Contents/MacOS/Basecamp
#!/bin/bash

# Set up error logging
exec 2>>/tmp/basecamp-app-error.log

# URL for Basecamp
BASECAMP_URL="https://launchpad.37signals.com"

# Log the launch
echo "Launching Basecamp at $(date)" >> /tmp/basecamp-app-error.log

# Try to open with Safari in web app mode
if [ -x "/Applications/Safari.app/Contents/MacOS/Safari" ]; then
    echo "Opening with Safari in web app mode" >> /tmp/basecamp-app-error.log
    
    # Create a temporary AppleScript to launch Safari in web app mode
    TEMP_SCRIPT="/tmp/basecamp_launcher_$$.scpt"
    cat > "$TEMP_SCRIPT" << APPLESCRIPT
    tell application "Safari"
        # Make sure Safari is running
        if not running then
            launch
            delay 1
        end if
        
        # Create a new document (window)
        make new document
        set the URL of document 1 to "$BASECAMP_URL"
        
        # Configure the window to look more like a web app
        tell application "System Events"
            tell process "Safari"
                # Wait for the window to load
                delay 1
                
                # Hide the bookmarks bar if possible
                try
                    if menu item "Hide Bookmarks Bar" of menu "View" of menu bar 1 exists then
                        click menu item "Hide Bookmarks Bar" of menu "View" of menu bar 1
                    end if
                end try
                
                # Hide the tab bar if possible
                try
                    if menu item "Hide Tab Bar" of menu "View" of menu bar 1 exists then
                        click menu item "Hide Tab Bar" of menu "View" of menu bar 1
                    end if
                end try
                
                # Enter full screen mode for a more app-like experience
                try
                    if menu item "Enter Full Screen" of menu "View" of menu bar 1 exists then
                        click menu item "Enter Full Screen" of menu "View" of menu bar 1
                    end if
                end try
            end tell
        end tell
        
        # Activate Safari to bring it to the front
        activate
    end tell
APPLESCRIPT
    
    # Run the AppleScript
    osascript "$TEMP_SCRIPT"
    
    # Clean up
    rm -f "$TEMP_SCRIPT"
else
    # Fallback to default browser
    echo "Safari not found, using default browser" >> /tmp/basecamp-app-error.log
    open "$BASECAMP_URL"
fi
EOF

# Make the script executable
chmod +x ~/Applications/Basecamp.app/Contents/MacOS/Basecamp

# Copy the Basecamp icon from the omakub icons directory
echo "Using Basecamp icon from omakub..."
mkdir -p /tmp/basecamp.iconset

# Convert PNG to ICNS using sips and iconutil
if command -v sips &> /dev/null && command -v iconutil &> /dev/null; then
    # Create different sizes for the iconset
    sips -z 16 16 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_16x16.png
    sips -z 32 32 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_16x16@2x.png
    sips -z 32 32 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_32x32.png
    sips -z 64 64 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_32x32@2x.png
    sips -z 128 128 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_128x128.png
    sips -z 256 256 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_128x128@2x.png
    sips -z 256 256 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_256x256.png
    sips -z 512 512 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_256x256@2x.png
    sips -z 512 512 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_512x512.png
    sips -z 1024 1024 ~/.local/share/omakub/applications/icons/Basecamp.png --out /tmp/basecamp.iconset/icon_512x512@2x.png
    
    # Convert the iconset to icns
    iconutil -c icns /tmp/basecamp.iconset -o ~/Applications/Basecamp.app/Contents/Resources/basecamp.icns
    rm -rf /tmp/basecamp.iconset
else
    # Fallback to just copying the PNG if conversion tools aren't available
    cp ~/.local/share/omakub/applications/icons/Basecamp.png ~/Applications/Basecamp.app/Contents/Resources/basecamp.png
    # Update the plist to use PNG instead of ICNS
    sed -i '' 's/basecamp.icns/basecamp.png/g' ~/Applications/Basecamp.app/Contents/Info.plist
fi

echo "Basecamp.app created successfully in ~/Applications/"
