{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "grant";
  home.homeDirectory = "/home/grant";

  home.packages = [
    pkgs.exiftool
    (pkgs.writeShellScriptBin "icloud-photos-sync"
      (builtins.readFile ./scripts/icloud-photos-sync.sh))
  ];

  systemd.user.services.icloud-photos-sync = {
    Unit = {
      Description = "Download recent iCloud Photos";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      Type = "oneshot";
      ExecStart = "${config.home.profileDirectory}/bin/icloud-photos-sync";
    };
  };

  systemd.user.timers.icloud-photos-sync = {
    Unit.Description = "Download recent iCloud Photos daily";
    Timer = {
      OnCalendar = "daily";
      Persistent = true;
      RandomizedDelaySec = "30m";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
