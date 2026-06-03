{ ... }: {
  networking.networkmanager = {
    enable = true;
  };
  networking.extraHosts = ''
  '';
}
