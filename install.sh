#!/usr/bin/env bash
# Run on a new machine to set up symlinks and install dependencies.
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

link() {
    local src="$DOTFILES_DIR/$1"
    local dst="$HOME/$1"
    mkdir -p "$(dirname "$dst")"
    # Remove existing symlink or back up real file/dir
    if [ -L "$dst" ]; then
        rm "$dst"
    elif [ -e "$dst" ]; then
        echo "  backing up $dst -> ${dst}.bak"
        mv "$dst" "${dst}.bak"
    fi
    ln -sf "$src" "$dst"
    echo "  linked $dst"
}

# ---------------------------------------------------------------------------
# tmux
# ---------------------------------------------------------------------------

echo "==> tmux"
link .tmux.conf

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "  installing TPM..."
    git clone --quiet https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
~/.tmux/plugins/tpm/bin/install_plugins >/dev/null 2>&1
echo "  tmux plugins installed"

# ---------------------------------------------------------------------------
# kitty
# ---------------------------------------------------------------------------

echo ""
echo "==> kitty"

if ! command -v kitty &>/dev/null; then
    echo "  installing kitty..."
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin launch=n
    # Add kitty to PATH
    mkdir -p "$HOME/.local/bin"
    ln -sf "$HOME/.local/kitty.app/bin/kitty" "$HOME/.local/bin/kitty"
    echo "  kitty installed"
else
    echo "  kitty already installed: $(kitty --version)"
fi

# Powerline font (required by kitty.conf for tmux status bar separators)
if ! fc-list | grep -qi "powerline"; then
    echo "  installing Powerline fonts..."
    sudo apt-get install -y fonts-powerline >/dev/null
    echo "  Powerline fonts installed"
else
    echo "  Powerline fonts already present"
fi

link .config/kitty/kitty.conf

# Set kitty as the default terminal
KITTY_BIN="$HOME/.local/kitty.app/bin/kitty"
if [ ! -f "$KITTY_BIN" ]; then
    KITTY_BIN="$(command -v kitty)"
fi
if sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$KITTY_BIN" 50 2>/dev/null; then
    sudo update-alternatives --set x-terminal-emulator "$KITTY_BIN"
    echo "  kitty set as default terminal (update-alternatives)"
fi
# GNOME fallback
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.default-applications.terminal exec "$KITTY_BIN"
    gsettings set org.gnome.desktop.default-applications.terminal exec-arg ''
    echo "  kitty set as default terminal (gsettings)"
fi

# ---------------------------------------------------------------------------
# Claude Code
# ---------------------------------------------------------------------------

echo ""
echo "==> Claude Code"
mkdir -p "$CLAUDE_DIR/skills" "$CLAUDE_DIR/plugins"

# CLAUDE.md
link .claude/CLAUDE.md

# settings.json — substitute the node binary path at install time
NODE_PATH="$(command -v node 2>/dev/null || true)"
if [ -z "$NODE_PATH" ] && [ -s "$HOME/.nvm/nvm.sh" ]; then
    # shellcheck disable=SC1091
    source "$HOME/.nvm/nvm.sh" --no-use
    NODE_PATH="$(nvm which current 2>/dev/null || true)"
fi
NODE_PATH="${NODE_PATH:-node}"

sed "s|NODE_PATH_PLACEHOLDER|$NODE_PATH|g" \
    "$DOTFILES_DIR/.claude/settings.json" > "$CLAUDE_DIR/settings.json"
echo "  written $CLAUDE_DIR/settings.json (node: $NODE_PATH)"

# Plugin registry — tell Claude which marketplaces and plugins to use
cp "$DOTFILES_DIR/.claude/plugins/installed_plugins.json" "$CLAUDE_DIR/plugins/installed_plugins.json"
cp "$DOTFILES_DIR/.claude/plugins/known_marketplaces.json" "$CLAUDE_DIR/plugins/known_marketplaces.json"
echo "  plugin registry copied"

# lark skills
for skill_src in "$DOTFILES_DIR/.claude/skills"/lark-*; do
    skill_name="$(basename "$skill_src")"
    link ".claude/skills/$skill_name"
done
echo "  lark skills linked"

# gstack — standalone git repo, not a submodule
GSTACK_DIR="$CLAUDE_DIR/skills/gstack"
if [ ! -d "$GSTACK_DIR/.git" ]; then
    echo "  cloning gstack..."
    git clone --quiet https://github.com/garrytan/gstack.git "$GSTACK_DIR"
else
    echo "  gstack already present, pulling..."
    git -C "$GSTACK_DIR" pull --ff-only --quiet
fi

# ---------------------------------------------------------------------------
# Claude plugins (superpowers + claude-hud)
# Claude's plugin system doesn't expose a CLI installer; the installed_plugins.json
# above tells Claude which plugins to load, but the cache must be populated first.
# On first `claude` launch after install, run these two commands inside Claude:
#   /plugins install claude-hud
#   /plugins install superpowers
# Then run /claude-hud:configure to rebuild the statusLine for this machine.
# ---------------------------------------------------------------------------

echo ""
echo "Done."
echo ""
echo "Next steps inside Claude Code:"
echo "  1. Run: /plugins install claude-hud"
echo "  2. Run: /plugins install superpowers"
echo "  3. Run: /claude-hud:configure"
