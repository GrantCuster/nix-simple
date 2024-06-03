{ config, pkgs, ... }:

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
    light
    sway-contrib.grimshot

    (writeShellScriptBin "screenshot" (builtins.readFile ./scripts/screenshot.sh))
  ];

  xdg.configFile.sway = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/sway";
    recursive = true;
  };
  xdg.configFile.foot = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/foot";
    recursive = true;
  };
  xdg.configFile.mako = {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix/home/mako";
    recursive = true;
  };

}
