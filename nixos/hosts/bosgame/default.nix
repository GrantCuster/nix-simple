{ pkgs, ... }:

let
  startJellyfinKiosk = pkgs.writeShellScript "start-jellyfin-kiosk" ''
    until ${pkgs.curl}/bin/curl --fail --silent --output /dev/null \
      http://127.0.0.1:8096/System/Info/Public; do
      ${pkgs.coreutils}/bin/sleep 1
    done

    exec ${pkgs.jellyfin-media-player}/bin/jellyfin-desktop --tv --fullscreen
  '';
in
{
  imports = [
    ../../bosgame.nix
    ../../jellyfin.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
  users.users.jellyfin.extraGroups = [ "video" "render" ];

  # Keep the removable media disk out of the boot critical path.  Its media
  # directory is bind-mounted at the path already used by Jellyfin.
  fileSystems."/srv/media-drive" = {
    device = "/dev/disk/by-uuid/2f65581b-55b4-4f2f-92a5-c40169b87625";
    fsType = "ext4";
    options = [
      "ro"
      "nofail"
      "x-systemd.automount"
      "x-systemd.device-timeout=5s"
    ];
  };

  fileSystems."/media" = {
    device = "/srv/media-drive/media";
    fsType = "none";
    options = [
      "bind"
      "ro"
      "nofail"
      "x-systemd.requires-mounts-for=/srv/media-drive"
    ];
  };

  # Present the read-only media disk in the hierarchy Jellyfin expects without
  # changing the files themselves.  Each show needs to be one level beneath a
  # shared library root; home videos retain their useful category folders.
  systemd.tmpfiles.rules = [
    "d /var/lib/jellyfin/library-layout 0755 jellyfin jellyfin -"
    "d /var/lib/jellyfin/library-layout/movies 0755 jellyfin jellyfin -"
    "d /var/lib/jellyfin/library-layout/movies/errol-morris 0755 jellyfin jellyfin -"
    "d /var/lib/jellyfin/library-layout/movies/errol-morris/Vernon\\x2c\\x20Florida\\x20(1981) 0755 jellyfin jellyfin -"
    "d /var/lib/jellyfin/library-layout/shows 0755 jellyfin jellyfin -"
    "d /var/lib/jellyfin/library-layout/videos 0755 jellyfin jellyfin -"

    "L+ /var/lib/jellyfin/library-layout/movies/errol-morris/Gates\\x20of\\x20Heaven\\x20(1978) - - - - /media/video/errol-morris-movies/gates-of-heaven-1978"
    "L+ /var/lib/jellyfin/library-layout/movies/errol-morris/Vernon\\x2c\\x20Florida\\x20(1981)/Vernon\\x2c\\x20Florida\\x20(1981).mp4 - - - - /media/video/errol-morris-movies/VernonFloridaErrolMorris1981/Vernon\\x2c\\x20Florida\\x20(Errol\\x20Morris\\x2c\\x201981).mp4"

    "L+ /var/lib/jellyfin/library-layout/shows/Beast\\x20Wars\\x20(1996) - - - - /media/video/beast-wars"
    "L+ /var/lib/jellyfin/library-layout/shows/Cowboy\\x20Bebop\\x20(1998) - - - - /media/video/cowboy-bebop"
    "L+ /var/lib/jellyfin/library-layout/shows/Neon\\x20Genesis\\x20Evangelion\\x20(1995) - - - - /media/video/evangelion"
    "L+ /var/lib/jellyfin/library-layout/shows/Scavengers\\x20Reign\\x20(2023) - - - - /media/video/scavengers-reign"

    "L+ /var/lib/jellyfin/library-layout/videos/Bikes - - - - /media/video/bikes"
    "L+ /var/lib/jellyfin/library-layout/videos/HCI\\x20Demos - - - - /media/video/hci-demos"
    "L+ /var/lib/jellyfin/library-layout/videos/Music\\x20Performances - - - - /media/video/music"
    "L+ /var/lib/jellyfin/library-layout/videos/Primitive\\x20Technology - - - - /media/video/primitive"
  ];

  # A deliberately small local TV session: no desktop environment, just a
  # Wayland kiosk compositor running Jellyfin Desktop.
  users.users.media = {
    isNormalUser = true;
    description = "Jellyfin TV session";
    extraGroups = [ "audio" "video" "render" "input" ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  services.greetd = {
    enable = true;
    settings.default_session = {
      user = "media";
      command = "${pkgs.dbus}/bin/dbus-run-session -- ${pkgs.cage}/bin/cage -d -- ${startJellyfinKiosk}";
    };
  };

  # Starting the service and accepting HTTP connections are separate stages.
  # Order greetd after Jellyfin, then let the wrapper above wait for readiness.
  systemd.services.greetd = {
    after = [ "jellyfin.service" ];
    wants = [ "jellyfin.service" ];
  };

  environment.systemPackages = [ pkgs.jellyfin-media-player ];
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  system.stateVersion = "24.05";
}
