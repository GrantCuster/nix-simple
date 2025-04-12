{ config, pkgs, inputs, lib, ... }:

{
   environment.systemPackages = [
    pkgs.jellyfin
    pkgs.jellyfin-web
    pkgs.jellyfin-ffmpeg
  ];
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };
}
