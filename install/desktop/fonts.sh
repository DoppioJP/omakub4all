#!/bin/bash

# macOS font directory
FONT_DIR="$HOME/Library/Fonts"
echo "Installing fonts for macOS..."

# Create font directory if it doesn't exist
mkdir -p "$FONT_DIR"

# Change to temporary directory
cd /tmp

# Download and install Cascadia Mono Nerd Font
echo "Downloading Cascadia Mono Nerd Font..."
curl -L -o CascadiaMono.zip https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip

echo "Extracting Cascadia Mono Nerd Font..."
unzip -q CascadiaMono.zip -d CascadiaFont
echo "Installing Cascadia Mono Nerd Font..."
cp CascadiaFont/*.ttf "$FONT_DIR"
rm -rf CascadiaMono.zip CascadiaFont

# Download and install iA Writer Mono font
echo "Downloading iA Writer Mono font..."
curl -L -o iafonts.zip https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.zip

echo "Extracting iA Writer Mono font..."
unzip -q iafonts.zip -d iaFonts
echo "Installing iA Writer Mono font..."
cp iaFonts/iA-Fonts-master/iA\ Writer\ Mono/Static/iAWriterMonoS-*.ttf "$FONT_DIR"
rm -rf iafonts.zip iaFonts

# Return to original directory
cd -

echo "Font installation complete!"
