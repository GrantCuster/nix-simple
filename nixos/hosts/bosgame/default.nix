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
      command = "${pkgs.dbus}/bin/dbus-run-session -- ${pkgs.cage}/bin/cage -d -- ${pkgs.jellyfin-media-player}/bin/jellyfin-desktop";
    };
  };

  environment.systemPackages = [ pkgs.jellyfin-media-player ];
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
  };

  system.stateVersion = "24.05";
}
