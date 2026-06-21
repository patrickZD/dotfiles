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
# zsh
# ---------------------------------------------------------------------------

echo "==> zsh"

if ! command -v zsh &>/dev/null; then
    echo "  zsh not found; install zsh before using .zshrc"
fi

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "  installing Oh My Zsh..."
    git clone --quiet --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
else
    echo "  Oh My Zsh already present"
fi

ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM_DIR/plugins"

if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
    echo "  installing zsh-autosuggestions..."
    git clone --quiet --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
else
    echo "  zsh-autosuggestions already present"
fi

if [ ! -d "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
    echo "  installing zsh-syntax-highlighting..."
    git clone --quiet --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"
else
    echo "  zsh-syntax-highlighting already present"
fi

if command -v fzf &>/dev/null || [ -x "$HOME/.fzf/bin/fzf" ]; then
    echo "  fzf already present"
elif [ ! -d "$HOME/.fzf" ]; then
    echo "  installing fzf..."
    git clone --quiet --depth=1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --key-bindings --completion --no-update-rc >/dev/null
else
    echo "  fzf directory exists but fzf was not found; run ~/.fzf/install if needed"
fi

link .zshrc

# ---------------------------------------------------------------------------
# tmux
# ---------------------------------------------------------------------------

echo ""
echo "==> tmux"
link .tmux.conf
link .local/bin/tmux-pane-send-lines

if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo "  installing TPM..."
    git clone --quiet https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
~/.tmux/plugins/tpm/bin/install_plugins >/dev/null 2>&1
echo "  tmux plugins installed"

# Reload config in any live sessions and shift window 0 → 1 for sessions
# created before base-index 1 was active.
if tmux info &>/dev/null 2>&1; then
    tmux source-file ~/.tmux.conf 2>/dev/null || true
    tmux list-sessions -F '#{session_name}' 2>/dev/null | while read -r sess; do
        if tmux list-windows -t "$sess" -F '#{window_index}' 2>/dev/null | grep -q '^0$'; then
            last=$(tmux list-windows -t "$sess" -F '#{window_index}' 2>/dev/null | sort -n | tail -1)
            tmp=$(( last + 10 ))
            tmux move-window -s "${sess}:0" -t "${sess}:${tmp}"
            for i in $(tmux list-windows -t "$sess" -F '#{window_index}' 2>/dev/null | grep -v "^${tmp}$" | sort -rn); do
                tmux move-window -s "${sess}:${i}" -t "${sess}:$(( i + 1 ))" 2>/dev/null || true
            done
            tmux move-window -s "${sess}:${tmp}" -t "${sess}:1"
        fi
    done
    echo "  tmux config reloaded"
fi

# ---------------------------------------------------------------------------
# Vim
# ---------------------------------------------------------------------------

echo ""
echo "==> Vim"
link .vimrc

if ! command -v vim &>/dev/null; then
    echo "  vim not found; install vim before running PlugInstall"
else
    mkdir -p "$HOME/.vim/autoload"
    if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
        echo "  installing vim-plug..."
        curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
        echo "  vim-plug installed"
    else
        echo "  vim-plug already present"
    fi

    vim +'PlugInstall --sync' +qa
    echo "  vim plugins installed"
fi

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

# Powerline fonts (required by kitty.conf for tmux status bar separators)
# fonts-powerline (apt) provides PowerlineSymbols.otf (symbols only).
# DejaVu Sans Mono for Powerline must be installed separately.
if ! fc-list | grep -qi "powerline"; then
    echo "  installing Powerline symbols font..."
    sudo apt-get install -y fonts-powerline >/dev/null
fi
if ! fc-list | grep -qi "dejavu sans mono for powerline"; then
    echo "  installing DejaVu Sans Mono for Powerline..."
    mkdir -p "$HOME/.local/share/fonts"
    curl -fL "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20for%20Powerline.ttf" \
        -o "$HOME/.local/share/fonts/DejaVuSansMono-Powerline.ttf"
    curl -fL "https://github.com/powerline/fonts/raw/master/DejaVuSansMono/DejaVu%20Sans%20Mono%20Bold%20for%20Powerline.ttf" \
        -o "$HOME/.local/share/fonts/DejaVuSansMono-Bold-Powerline.ttf"
    fc-cache -f "$HOME/.local/share/fonts"
    echo "  DejaVu Powerline fonts installed"
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
