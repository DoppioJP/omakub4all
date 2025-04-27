# Exit immediately if a command exits with a non-zero status
set -e

# Give people a chance to retry running the installation
trap 'echo "Omakub installation failed! You can retry by running: source ~/.local/share/omakub/install.sh"' ERR

# Check the distribution name and version and abort if incompatible
source ~/.local/share/omakub/install/check-version.sh

# Ask for app choices
echo "Get ready to make a few choices..."
source ~/.local/share/omakub/install/terminal/required/app-gum.sh >/dev/null

# Trick Omakub to allow for desktop software installation
export XDG_CURRENT_DESKTOP=GNOME
source ~/.local/share/omakub/install/first-run-choices.sh

# Desktop software and tweaks will only be installed if we're running Gnome
if [[ "$XDG_CURRENT_DESKTOP" == *"GNOME"* ]]; then
  # Ensure computer doesn't go to sleep or lock while installing
  caffeinate -dimsu &
  CAFFEINATE_PID=$!

  # Prompt user for preferred cask app installation directory (default: ~/Applications)
  read -p "Enter directory to install cask apps [default: ~/../../Applications/Utilities]: " CASK_APPDIR
  CASK_APPDIR="${CASK_APPDIR:-~/../../Applications/Utilities}"

  export HOMEBREW_CASK_OPTS="--appdir=$CASK_APPDIR"
  echo "Cask apps will be installed to: $CASK_APPDIR"

  # Persist HOMEBREW_CASK_OPTS to bash and zsh profiles
  # Ensure files exist
  touch ~/.bash_profile ~/.zshrc

  # Add export if not already present
  for config_file in ~/.bash_profile ~/.zshrc; do
    if ! grep -q "HOMEBREW_CASK_OPTS.*--appdir=$CASK_APPDIR" "$config_file"; then
      echo "export HOMEBREW_CASK_OPTS=\"--appdir=$CASK_APPDIR\"" >> "$config_file"
    fi
  done

  echo "Installing terminal and desktop tools..."

  # Install terminal tools
  source ~/.local/share/omakub/install/terminal.sh

  # Install desktop tools and tweaks
  source ~/.local/share/omakub/install/desktop.sh

  # Revert to normal idle and lock settings
  kill "$CAFFEINATE_PID"
else
  echo "Only installing terminal tools..."
  source ~/.local/share/omakub/install/terminal.sh
fi
