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

  # Set XDG_SCREENSHOT_DIR to the directory where screenshots are saved 
  environment.sessionVariables = {
    XDG_SCREENSHOT_DIR = "${config.home.homeDirectory}/Screenshots";
  };
}
