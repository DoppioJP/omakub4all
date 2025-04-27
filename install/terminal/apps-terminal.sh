brew install fzf ripgrep bat eza zoxide btop fd tlrc

## plocate, using macOS locate instead
# Check if locate database exists and is up-to-date
if ! [ -f "/var/db/locate.database" ] || [ $(find "/var/db/locate.database" -mtime +7 -print 2>/dev/null) ]; then
  echo "Enabling macOS locate database service..."

  sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
  echo "Running updatedb to build locate database..."
  sudo /usr/libexec/locate.updatedb
fi

## apache2-utils
# looks like macOS already has them: htpasswd, ab, htdigest, logresolve, rotatelogs

## fd-find
# installing fd

## tldr
# installing tlrc instead "tldr client, written in Rust", tldr command will still work
