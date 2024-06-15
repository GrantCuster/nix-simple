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

    jq

    ripgrep

    nodejs_22

    neofetch
    htop

    imagemagick
    ffmpeg
    yt-dlp

    pandoc

    cairo

    pokemonsay

    nodePackages_latest.ts-node

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

    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })

    (writeShellScriptBin "smart_tmux" (builtins.readFile ./scripts/smart_tmux.sh))
    (writeShellScriptBin "smart_nvim" (builtins.readFile ./scripts/smart_nvim.sh))
    (writeShellScriptBin "oblique" (builtins.readFile ./scripts/oblique.sh))
    (writeShellScriptBin "welcome" (builtins.readFile ./scripts/welcome.sh))
    (writeShellScriptBin "pokemon" (builtins.readFile ./scripts/pokemon.sh))
    (writeShellScriptBin "clean_tmux" (builtins.readFile ./scripts/clean_tmux.sh))
    (writeShellScriptBin "tmux_session" (builtins.readFile ./scripts/tmux_session.sh))
    (writeShellScriptBin "pstrat" (builtins.readFile ./scripts/pokemon_strategy.sh))
    (writeShellScriptBin "tmux_notepad" (builtins.readFile ./scripts/tmux_notepad.sh))
    (writeShellScriptBin "git_commit" (builtins.readFile ./scripts/git_commmit.sh))
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
  xdg.configFile.tmux = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/tmux";
    recursive = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    shellAliases = {
      c = "clear";
      t = "smart_tmux";
      n = "smart_nvim";
      neo = "neofetch --source ~/nix/home/extra/sloth.txt";
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
    };
    plugins = [
      {
        name = "fzf-tab";
        src = zsh-fzf_tab;
        }
    ];
 
  };

  programs.fzf = {
    enable = true;
    defaultOptions = [ "--height 40%" "--reverse" ];
    enableZshIntegration = true;
  };

  programs.starship = {
    enable = true;
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
