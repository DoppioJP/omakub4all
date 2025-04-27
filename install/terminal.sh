# Needed for all installers
# brew update
# brew upgrade
# brew install curl git unzip

# Run terminal installers
for installer in ~/.local/share/omakub/install/terminal/*.sh; do source $installer; done
