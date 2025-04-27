brew install gnupg

# Ensure GPG_TTY is set in shell config files
for config_file in ~/.zshrc ~/.bash_profile; do
  if ! grep -q "export GPG_TTY=" "$config_file" 2>/dev/null; then
    echo "export GPG_TTY=\$(tty)" >> "$config_file"
  fi
done

# Create .gnupg directory if it doesn't exist
mkdir -p ~/.gnupg
chmod 700 ~/.gnupg

# Add or update cache settings in gpg-agent.conf
if [ -f ~/.gnupg/gpg-agent.conf ]; then
  # Update existing settings if present, otherwise append
  grep -q "^default-cache-ttl" ~/.gnupg/gpg-agent.conf && \
    sed -i '' 's/^default-cache-ttl.*/default-cache-ttl 86400/' ~/.gnupg/gpg-agent.conf || \
    echo "default-cache-ttl 86400" >> ~/.gnupg/gpg-agent.conf

  grep -q "^max-cache-ttl" ~/.gnupg/gpg-agent.conf && \
    sed -i '' 's/^max-cache-ttl.*/max-cache-ttl 86400/' ~/.gnupg/gpg-agent.conf || \
    echo "max-cache-ttl 86400" >> ~/.gnupg/gpg-agent.conf
else
  # Create new config file with settings
  echo "default-cache-ttl 86400" >> ~/.gnupg/gpg-agent.conf
  echo "max-cache-ttl 86400" >> ~/.gnupg/gpg-agent.conf
fi

# Restart gpg-agent to apply changes
killall gpg-agent 2>/dev/null || true
gpgconf --launch gpg-agent
