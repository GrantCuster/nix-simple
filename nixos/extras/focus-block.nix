{ ... }: {
  networking.networkmanager = {
    enable = true;
  };
  networking.extraHosts = ''
      127.0.1.1 x.com
      ::1 x.com
      127.0.1.1 www.x.com
      ::1 www.x.com
      127.0.1.1 youtube.com
      ::1 youtube.com
      127.0.1.1 www.youtube.com
      ::1 www.youtube.com
      127.0.1.1 reddit.com
      ::1 reddit.com
      127.0.1.1 www.reddit.com
      ::1 www.reddit.com
      127.0.1.1 vibecheck.local
      ::1 vibecheck.local
      127.0.1.1 cosine.local
      ::1 cosine.local
  '';
}
