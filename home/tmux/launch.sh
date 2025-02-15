#!/bin/sh

if [[ $(uname) == "Darwin" ]]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  clear
fi

# Remove unattached unnamed tmux sessions
# tmux list-sessions 2>/dev/null | grep -v attached | grep -E '^([0-9]+):' | awk -F: '{print $1}' | xargs -r -I{} tmux kill-session -t {}

# old console default
# tmux has-session -t console 2>/dev/null || tmux new-session -s console 'cd; nvim -c "terminal neofetch --source ~/nix/home/extra/sloth.txt && zsh"';

# tmux new-session 'nvim -c "terminal fish"';
#
if [[ $(uname) == "Darwin" ]]; then
  export PATH="$HOME/go/bin:$PATH"
  cd;
  nvim -c 'terminal fish'
else
  # necessary for neo image neovim image viewer (uses ttyimg from go)
  export PATH="$HOME/go/bin:$PATH"
  ghostty -e "nvim -c 'terminal fish'"
fi
