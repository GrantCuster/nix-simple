if [[ $(uname) == "Darwin" ]]; then
  . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  clear
fi
tmux has-session -t console 2>/dev/null || tmux new-session -s console 'cd; nvim -c "terminal neofetch --source ~/nix/home/extra/sloth.txt && zsh"';
tmux attach-session -t console;

