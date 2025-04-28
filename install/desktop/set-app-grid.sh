# Remove Btop entry for one that runs in alacritty
# sudo rm -rf /usr/share/applications/btop.desktop

# App doesn't do anything when started from the app grid
# sudo rm -rf /usr/share/applications/org.flameshot.Flameshot.desktop

# Remove the ImageMagick icon
# sudo rm -rf /usr/share/applications/display-im6.q16.desktop

# Replacing this with btop
# sudo rm -rf /usr/share/applications/org.gnome.SystemMonitor.desktop

# We added our own meant for Alacritty
# sudo rm -rf /usr/local/share/applications/nvim.desktop
# sudo rm -rf /usr/local/share/applications/vim.desktop

# The following commands are specific to GNOME desktop on Linux and have no equivalent on macOS
# They organize applications into folders in the GNOME application grid/launcher
# macOS uses a different system for organizing applications (Launchpad and Applications folder)

# On Linux, these commands would:
# - Create application folders in the GNOME app grid
# - Group system utilities and update tools into organized categories
# - Make the application launcher cleaner and more organized

echo "App grid organization is not applicable on macOS - Launchpad has its own organization system."
