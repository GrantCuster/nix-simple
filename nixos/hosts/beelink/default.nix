{ lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "beelink";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  nixpkgs.config.allowUnfreePredicate = package:
    builtins.elem (lib.getName package) [ "google-chrome" ];

  hardware.graphics.enable = true;

  # Lightweight local desktop: Niri starts automatically, while the machine
  # remains fully manageable over SSH and Tailscale.
  programs.niri.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "grant";
      command = "${pkgs.niri}/bin/niri-session";
    };
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;
  services.gnome.gnome-keyring.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  networking.firewall.allowedTCPPorts = [ 22 80 ];

  services.caddy = {
    enable = true;
    virtualHosts."http://beelink" = {
      extraConfig = ''
        root * /var/www
        file_server
      '';
    };
  };

  systemd.services.time-blocks = {
    description = "Time blocks server";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 /home/grant/time-blocks/server.py";
      Restart = "on-failure";
      RestartSec = "5s";
      User = "grant";
      WorkingDirectory = "/home/grant/time-blocks";
    };
  };

  system.stateVersion = "25.11";
}
