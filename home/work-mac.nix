{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "gcuster";
  home.homeDirectory = "/Users/gcuster";

  home.packages = with pkgs; [
    bash
    coreutils
  ];

}


