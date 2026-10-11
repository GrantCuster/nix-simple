{ pkgs, ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  services.tailscale.enable = true;

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  users.users.grant = {
    isNormalUser = true;
    description = "Grant Custer";
    extraGroups = [ "networkmanager" "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ7F9xoB+Du16chaBgZ1xVHIyXjiCOZj4o9gxLXW3NrM grantcuster@gmail.com"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    btop
    curl
    git
    jq
    ripgrep
    tmux
    vim
    wget
  ];

  systemd.services.NetworkManager-wait-online.enable = false;
  systemd.coredump.enable = false;

  services.journald.settings.Journal = {
    SystemMaxUse = "500M";
    MaxRetentionSec = "30day";
  };
}
