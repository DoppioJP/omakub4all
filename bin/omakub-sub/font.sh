#!/bin/bash

set_font() {
	local font_name=$1
	local url=$2
	local file_type=$3
	local file_name="${font_name/ Nerd Font/}"
	local font_dir="$HOME/Library/Fonts"
	local vscode_settings="$HOME/Library/Application Support/Code/User/settings.json"

	# Check if font is already installed by looking for any matching font files
	if ! ls "$font_dir/$file_name"*."$file_type" &>/dev/null; then
		echo "Installing $font_name..."

		# Create a temporary directory for downloads
		local temp_dir=$(mktemp -d)
		cd "$temp_dir"

		echo "Downloading $font_name..."
		if ! curl -L --progress-bar -o "$file_name.zip" "$url"; then
			echo "Error: Failed to download $font_name"
			cd - > /dev/null
			rm -rf "$temp_dir"
			return 1
		fi

		echo "Extracting $font_name..."
		if ! unzip -q "$file_name.zip" -d "$file_name"; then
			echo "Error: Failed to extract $file_name.zip"
			cd - > /dev/null
			rm -rf "$temp_dir"
			return 1
		fi

		echo "Installing $font_name to $font_dir..."
		cp "$file_name"/*."$file_type" "$font_dir"

		# Clean up
		cd - > /dev/null
		rm -rf "$temp_dir"

		echo "$font_name installed successfully!"
		clear
		source $OMAKUB_PATH/ascii.sh
	else
		echo "$font_name is already installed."
	fi

	# Update VS Code settings if the file exists
	if [ -f "$vscode_settings" ]; then
		echo "Updating VS Code settings to use $font_name..."
		sed -i '' "s/\"editor.fontFamily\": \".*\"/\"editor.fontFamily\": \"$font_name\"/g" "$vscode_settings"
	else
		echo "VS Code settings file not found at $vscode_settings"
	fi

	# Update Alacritty font configuration
	echo "Updating Alacritty configuration..."

	# Create a custom Alacritty font configuration with the correct font name
	cat > ~/.config/alacritty/font.toml << EOF
[font]
normal = { family = "$font_name", style = "Regular" }
bold = { family = "$font_name", style = "Bold" }
italic = { family = "$font_name", style = "Italic" }
EOF

	echo "Font set to $font_name"
}

if [ "$#" -gt 1 ]; then
	choice=${!#}
else
	choice=$(gum choose "Cascadia Mono" "Fira Mono" "JetBrains Mono" "Meslo" "> Change size" "<< Back" --height 8 --header "Choose your programming font")
fi

case $choice in
"Cascadia Mono")
	set_font "CaskaydiaMono Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip" "ttf"
	;;
"Fira Mono")
	# Using the exact font name as found in the font files
	set_font "FiraMono Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraMono.zip" "otf"
	;;
"JetBrains Mono")
	set_font "JetBrainsMono Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" "ttf"
	;;
"Meslo")
	# Using the exact font name as found in the font files
	set_font "MesloLGS Nerd Font" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip" "ttf"
	;;
"> Change size")
	source $OMAKUB_PATH/bin/omakub-sub/font-size.sh
	exit
	;;
"<< Back")
	# Return to the previous menu
	;;
esac

source $OMAKUB_PATH/bin/omakub-sub/menu.sh
