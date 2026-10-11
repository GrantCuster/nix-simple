{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  networking.hostName = "beelink";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
