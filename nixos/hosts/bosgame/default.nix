{ pkgs, ... }:

{
  imports = [
    ../../bosgame.nix
    ../../jellyfin.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.graphics.enable = true;
  users.users.jellyfin.extraGroups = [ "video" "render" ];

  system.stateVersion = "24.05";
}
