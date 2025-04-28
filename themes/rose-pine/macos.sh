OMAKUB_THEME_COLOR="red"
OMAKUB_THEME_BACKGROUND="rose-pine/background.jpg"
source $OMAKUB_PATH/themes/set-macos-theme.sh

# Switch to light mode
osascript <<EOF
tell application "System Events"
    tell appearance preferences
        set dark mode to false
    end tell
end tell
EOF
