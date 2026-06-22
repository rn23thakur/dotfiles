# ==========================================
# 1. ZINIT SETUP
# ==========================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# ==========================================
# 2. STARSHIP PROMPT
# ==========================================
eval "$(starship init zsh)"

# Fix: prevent recursive zle-keymap-select calls with Starship + vi mode
function zle-keymap-select() {
  if typeset -f starship_zle-keymap-select > /dev/null; then
    starship_zle-keymap-select
  fi
}
zle -N zle-keymap-select

# ==========================================
# 3. HISTORY
# ==========================================
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# ==========================================
# 4. VI MODE & KEYBINDINGS
# ==========================================
bindkey -v
export KEYTIMEOUT=1
bindkey '^?' backward-delete-char
bindkey '^R' history-incremental-search-backward

# ==========================================
# 5. FZF (Machine Agnostic Lookup)
# ==========================================
export FZF_DEFAULT_OPTS="--smart-case"
# 1. Check Personal Laptop path
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
# 2. Check Company Mac path (Homebrew standard location)
elif [ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    source /opt/homebrew/opt/fzf/shell/completion.zsh
fi

bindkey -M viins '^F' fzf-cd-widget

# ==========================================
# 6. ZINIT PLUGINS
# ==========================================
zinit wait"0" lucid blockf for \
    zsh-users/zsh-completions

zinit wait"0" lucid atload"bindkey -M viins '^Y' autosuggest-accept" for \
    light-mode \
    zsh-users/zsh-autosuggestions

zinit wait"0" lucid for \
    light-mode \
    Aloxaf/fzf-tab

# Syntax highlighting
zinit wait"1" lucid for \
    zdharma-continuum/fast-syntax-highlighting
