#!/bin/bash

# Use the background image directly from the Omakub themes directory
BACKGROUND_PATH="$HOME/.local/share/omakub/themes/$OMAKUB_THEME_BACKGROUND"

# Switch to dark mode
osascript <<EOF
tell application "System Events"
    tell appearance preferences
        set dark mode to true
    end tell
end tell
EOF

# Set the desktop wallpaper using AppleScript
# FIXME: will change only active space,
#        to apply that background everywhere go to
#        System Settings > Wallpaper and turn on/off the "Show on all Spaces"
osascript <<EOF
tell application "System Events"
    tell every desktop
        set picture to "$BACKGROUND_PATH"
    end tell
end tell
EOF
