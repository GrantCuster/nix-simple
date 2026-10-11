{ config, inputs, pkgs, ... }:

{
  home.username = "grant";
  home.homeDirectory = "/home/grant";
  home.stateVersion = "25.11";

  # Keep this useful as a small everyday desktop without reproducing the full
  # workstation's development and media-production environment.
  home.packages = with pkgs; [
    brightnessctl
    fish
    ghostty
    google-chrome
    grim
    jq
    libnotify
    mako
    pavucontrol
    playerctl
    slurp
    swaybg
    waybar
    wf-recorder
    wl-clipboard
    inputs.whisrs.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  programs.fish.enable = true;

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.comixcursors;
    name = "comixcursors";
  };

  # Use the same live configuration as the primary workstation. Changes made
  # in this flake become visible after syncing the checkout to the Beelink.
  xdg.configFile.niri = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix/home/niri";
    recursive = true;
    force = true;
  };

  xdg.configFile.waybar = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix/home/waybar";
    recursive = true;
    force = true;
  };

  xdg.configFile.mako = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix/home/mako";
    recursive = true;
    force = true;
  };

  xdg.configFile.foot = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/nix/home/foot";
    recursive = true;
    force = true;
  };

}
