{ config, pkgs, zsh-fzf_tab, ... }:
{
 # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.


  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    neovim
    tmux

    git
    lazygit

    wget
    unzip

    bat

    socat

    jq

    ripgrep

    nodejs_22

    fastfetch
    htop

    imagemagick
    ffmpeg

    pandoc

    pokemonsay

    cbonsai

    nom

    bash

    yazi

    fzf

    gh

    # gleam

    llm

    # make sure gnu find
    findutils

    nodePackages_latest.ts-node

    neovim-remote


    nerd-fonts.jetbrains-mono

    chafa
    viu
    ascii-image-converter

    # neovim lsp
    tree-sitter
    lua-language-server
    nodePackages_latest.typescript-language-server
    nixd
    tailwindcss-language-server
    stylua
    nodePackages_latest.prettier
    prettierd
    eslint_d
    pyright
    svelte-language-server
    marksman

    (writeShellScriptBin "smart_nvim" (builtins.readFile ./scripts/smart_nvim.sh))
    (writeShellScriptBin "oblique" (builtins.readFile ./scripts/oblique.sh))
    (writeShellScriptBin "welcome" (builtins.readFile ./scripts/welcome.sh))
    (writeShellScriptBin "pokemon" (builtins.readFile ./scripts/pokemon.sh))
    (writeShellScriptBin "clean_tmux" (builtins.readFile ./scripts/clean_tmux.sh))
    (writeShellScriptBin "tmux_session" (builtins.readFile ./scripts/tmux_session.sh))
    (writeShellScriptBin "pstrat" (builtins.readFile ./scripts/pokemon_strategy.sh))
    (writeShellScriptBin "tmux_notepad" (builtins.readFile ./scripts/tmux_notepad.sh))
    (writeShellScriptBin "git_commit" (builtins.readFile ./scripts/git_commit.sh))
    (writeShellScriptBin "toggle_trackpad" (builtins.readFile ./scripts/toggle_trackpad.sh))
    (writeShellScriptBin "findlastdir" (builtins.readFile ./scripts/findlastdir.sh))
    (writeShellScriptBin "battery_status" (builtins.readFile ./scripts/battery_status.sh))
    (writeShellScriptBin "daily" (builtins.readFile ./scripts/daily.sh))
    (writeShellScriptBin "wakeup" (builtins.readFile ./scripts/wakeup.sh))
    # mac specific
    (writeShellScriptBin "sketch" (builtins.readFile ./scripts/sketch.sh))
    (writeShellScriptBin "refresh_nix_mac" (builtins.readFile ./scripts/refresh_nix_mac.sh))
  ];

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/ubuntu/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Neovim config use lazyvim
  # Out of store symlink keeps it writable for lazyvim
  xdg.configFile.nvim = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/nvim";
    recursive = true;
  };
  # Generally easier to use these symlinks
  xdg.configFile.tmux = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/tmux";
    recursive = true;
  };
  xdg.configFile.ghostty = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/ghostty";
    recursive = true;
  };

  # Mac specific
  xdg.configFile.aerospace = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/aerospace";
    recursive = true;
  };
  xdg.configFile.sketchybar = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/sketchybar";
    recursive = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # autosuggestion.enable = true;
    shellAliases = {
      c = "clear";
      t = "~/.config/tmux/smart_tmux.sh";
      b = "battery_status";
      # n = "smart_nvim";
      n = "nvr .";
      stat = "fastfetch --file ~/nix/home/extra/sloth.txt --logo-color-1 white";
      ts = "tmux_session";
      # git helpers
      ga = "git add .";
      gc = "git_commit";
      gp = "git push origin $(git rev-parse --abbrev-ref HEAD)";
      gP = "git pull origin $(git rev-parse --abbrev-ref HEAD) --rebase";
      gs = "git status";
      # sudo use nix packages
      s = "sudo --preserve-env=PATH env";
      sn = "sudo --preserve-env=PATH env nvim -u ~/.config/nvim/init.lua";
      # reconnect nix on work mac or refresh shell in general
      rn = "refresh_nix_mac";
      rz = ". /nix/var/nix/profiles/default/etc/profile.d/nix.sh";
      # disable touchpad lg gram not worki
      tt = "s toggle_trackpad";
      # dir by last modified
      fd = "findlastdir";
      # better nvim pipe;
      pv = "nvim -c 'read !pbpaste' -c 'setlocal buftype=nofile bufhidden=hide noswapfile'";
      # pipe shell to nvim
      sv = "nvim -c 'setlocal buftype=nofile bufhidden=hide noswapfile' -";
      # open command history in neovim
      vh = "nvim ~/.zsh_history";
      gsync = "git add . && git commit -am 'update' && git pull origin main --rebase && git push origin main";
    };
    plugins = [
      {
        name = "fzf-tab";
        src = zsh-fzf_tab;
      }
    ];
    initContent = ''
      # Add /usr/local/bin to PATH - maybe only needed on mac
      export PATH=/usr/local/bin:$PATH
      export PATH=$HOME/.local/bin:$PATH
      # Add .local/bin to PATH
      export PATH=$HOME/.local/bin:$PATH
      export PATH=$HOME/go/bin:$PATH
      if [[ $(uname) == "Darwin" ]]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
        clear
      fi
  '';
 };

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting
      function gt
          set dir (pwd)
          while test "$dir" != "/"
              if test -d "$dir/.git" -o -d "$dir/.project"
                  cd "$dir"
                  return 0
              end
              set dir (dirname "$dir")
          end
          echo "No parent directory with .git or .project found."
          return 1
      end
      function __sync_nvim_cwd --on-variable PWD --description "Sync Neovim working directory with Fish"
        status --is-command-substitution; and return  # Prevent running in subshells
        nvr -c "cd $PWD"  # Change Neovim's working directory
        set timestamp (date +%s)
        nvr -c "file term://$PWD::$timestamp"  # Change Neovim's terminal name
      end
      set -x PATH $HOME/go/bin $PATH
    '';
    shellAliases = {
      c = "clear";
      t = "~/.config/tmux/smart_tmux.sh";
      b = "battery_status";
      # n = "smart_nvim";
      n = "nvr .";
      name = "niri msg action set-workspace-name";
      done = "niri msg action unset-workspace-name && niri msg action close-window && niri msg action focus-workspace 1";
      stat = "fastfetch --file ~/nix/home/extra/sloth.txt";
      ts = "tmux_session";
      # git helpers
      ga = "git add .";
      gc = "git_commit";
      gp = "git push origin $(git rev-parse --abbrev-ref HEAD)";
      gP = "git pull origin $(git rev-parse --abbrev-ref HEAD) --rebase";
      gs = "git status";
      # sudo use nix packages
      s = "sudo --preserve-env=PATH env";
      sn = "sudo --preserve-env=PATH env nvim -u ~/.config/nvim/init.lua";
      # reconnect nix on work mac or refresh shell in general
      rn = ". /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh";
      rz = ". /nix/var/nix/profiles/default/etc/profile.d/nix.sh";
      # disable touchpad lg gram not worki
      tt = "s toggle_trackpad";
      # dir by last modified
      fd = "findlastdir";
      # better nvim pipe;
      pv = "nvim -c 'read !pbpaste' -c 'setlocal buftype=nofile bufhidden=hide noswapfile'";
      # pipe shell to nvim
      sv = "nvim -c 'setlocal buftype=nofile bufhidden=hide noswapfile' -";
      # open command history in neovim
      vh = "nvim ~/.zsh_history";
      gsync = "git add . && git commit -am 'update' && git pull origin main --rebase && git push origin main";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = pkgs.lib.importTOML ./starship/starship.toml;
  };

  programs.fzf = {
    enable = true;
    defaultOptions = [ "--height 40%" "--reverse" ];
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    userName = "Grant Custer";
    userEmail = "grantcuster@gmail.com";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
