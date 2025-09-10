# ~/.bash_colors
# ANSI colors and styles for Bash
# Includes prompt-safe and echo-safe truecolor using r,g,b variables

# ----------------------------
# Standard colors (echo-safe)
# ----------------------------
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
RESET="\033[0m"
BOLD="\033[1m"
UNDERLINE="\033[4m"

# Prompt-safe versions
P_RED="\[\033[31m\]"
P_GREEN="\[\033[32m\]"
P_YELLOW="\[\033[33m\]"
P_BLUE="\[\033[34m\]"
P_MAGENTA="\[\033[35m\]"
P_CYAN="\[\033[36m\]"
P_WHITE="\[\033[37m\]"
P_RESET="\[\033[0m\]"
P_BOLD="\[\033[1m\]"
P_UNDERLINE="\[\033[4m\]"

# ----------------------------
# Truecolor helpers for echo
# ----------------------------
# Usage:
# r=255 g=100 b=0; echo_truecolor "Text" $r $g $b
echo_truecolor() {
    local text="$1"
    local r="${2:-255}"
    local g="${3:-255}"
    local b="${4:-255}"
    echo -e "\033[38;2;${r};${g};${b}m${text}${RESET}"
}

echo_bg_truecolor() {
    local text="$1"
    local r="${2:-0}"
    local g="${3:-0}"
    local b="${4:-0}"
    echo -e "\033[48;2;${r};${g};${b}m${text}${RESET}"
}

# ----------------------------
# Truecolor helpers for PS1 (prompt-safe)
# ----------------------------
# Usage: P_TRUECOLOR_FG r g b
P_TRUECOLOR_FG() {
    local r="${1:-255}"
    local g="${2:-255}"
    local b="${3:-255}"
    echo "\[\033[38;2;${r};${g};${b}m\]"
}

P_TRUECOLOR_BG() {
    local r="${1:-0}"
    local g="${2:-0}"
    local b="${3:-0}"
    echo "\[\033[48;2;${r};${g};${b}m\]"
}

# Example usage in PS1:
# r=255 g=100 b=0
# PS1="$(P_TRUECOLOR_FG $r $g $b)\u@\h $(P_RESET)$ "

# ----------------------------
# General echo helper
# ----------------------------
cecho() {
    # Usage: cecho "text" "FG color" "BG color(optional)" "STYLE(optional)"
    local text="$1"
    local fg="${2:-$RESET}"
    local bg="${3:-}"
    local style="${4:-}"
    echo -e "${style}${fg}${bg}${text}${RESET}"
}

# Shortcut functions for standard colors
echo_red()    { cecho "$1" "$RED"; }
echo_green()  { cecho "$1" "$GREEN"; }
echo_yellow() { cecho "$1" "$YELLOW"; }
echo_blue()   { cecho "$1" "$BLUE"; }
echo_magenta(){ cecho "$1" "$MAGENTA"; }
echo_cyan()   { cecho "$1" "$CYAN"; }
echo_white()  { cecho "$1" "$WHITE"; }