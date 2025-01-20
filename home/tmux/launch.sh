if [[ $(uname) == "Darwin" ]]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  clear
fi

# Remove unattached unnamed tmux sessions
tmux list-sessions 2>/dev/null | grep -v attached | grep -E '^([0-9]+):' | awk -F: '{print $1}' | xargs -r -I{} tmux kill-session -t {}

session_count=$(tmux list-sessions 2>/dev/null | wc -l)

# old console default
# tmux has-session -t console 2>/dev/null || tmux new-session -s console 'cd; nvim -c "terminal neofetch --source ~/nix/home/extra/sloth.txt && zsh"';

if [ "$session_count" -eq 0 ]; then
  tmux new-session -s launch 'cd; nvim -c "terminal fastfetch --file ~/nix/home/extra/sloth.txt --logo-color-1 white && zsh"';
else
  tmux new-session 'nvim -c :term';
fi

