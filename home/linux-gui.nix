{ config, pkgs, lib, codex, ... }:

{
  home.packages = with pkgs; [
    codex
    # sway
    autotiling
    grim
    slurp
    wf-recorder
    mako
    libnotify
    gifsicle
    wl-clipboard
    clipse
    brightnessctl
    sway-contrib.grimshot
    newsboat
    waybar
    spotify-player

    # ttyimage attempt
    go

    obsidian

    xournalpp

    kdePackages.kdenlive

    mpv
    mkvtoolnix

    groff

    zoom-us

    slack

    swaybg

    # for gleam
    erlang
    watchexec

    google-cloud-sdk

    docker

    cliphist

    lsof

    google-chrome

    yt-dlp
    deno

    railway
    postgresql_18

    inotify-tools

    qt6.qtbase
    qt6.qtwayland
    qt6.qtwebengine
    xdg-utils # Optional, improves Qt behavior

    # not actually gui but putting rust here for now
    # rustup

    ghostty

    espeak

    (writeShellScriptBin "screenshot" (builtins.readFile ./scripts/screenshot.sh))
    (writeShellScriptBin "gif" (builtins.readFile ./scripts/gif.sh))
  ];

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.comixcursors;
    name = "comixcursors";
  };


  xdg.configFile.sway = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/sway";
    recursive = true;
  };
  xdg.configFile.foot = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/foot";
    recursive = true;
  };
  xdg.configFile.fontconfig = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/fontconfig";
    recursive = true;
  };
  xdg.configFile.mako = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/mako";
    recursive = true;
  };
  xdg.configFile.waybar = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/waybar";
    recursive = true;
  };
 xdg.configFile.niri = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/niri";
    recursive = true;
  };
  xdg.configFile.gammastep = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/gammastep";
    recursive = true;
  };
}
