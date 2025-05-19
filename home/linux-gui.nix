{ config, pkgs, lib, ... }:

{
  home.packages = with pkgs; [
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
    light
    sway-contrib.grimshot
    newsboat
    waybar
    spotify-player

    # ttyimage attempt
    go

    mpv

    swaybg

    # for gleam
    erlang
    beamMinimal26Packages.rebar3
    watchexec

    yt-dlp

    xdragon

    inotify-tools

    obs-studio

    # not actually gui but putting rust here for now
    rustup

    ghostty


    espeak

    (writeShellScriptBin "screenshot" (builtins.readFile ./scripts/screenshot.sh))
    (writeShellScriptBin "gif" (builtins.readFile ./scripts/gif.sh))
  ];

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
  xdg.configFile.hypr = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/hypr";
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
  xdg.configFile = {
    "hyprscroller/hyprscroller.conf".text = ''
      plugin = ${lib.getLib pkgs.hyprlandPlugins.hyprscroller}/lib/libhyprscroller.so 
    '';
  };
}
