#!/usr/bin/env bash
# Run on a new machine to set up symlinks and install dependencies.
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$DOTFILES_DIR/$1"
    local dst="$HOME/$1"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "Backing up existing $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    echo "Linked $dst"
}

# tmux
link .tmux.conf

# Install TPM if not present
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    echo "TPM installed. Open tmux and press Ctrl+a + I to install plugins."
fi

echo "Done. Start tmux and press Ctrl+a + I to install plugins."
