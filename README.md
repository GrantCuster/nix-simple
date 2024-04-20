# AWS instance instructions

Nix install single user:

```
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

Clone nix-simple as nix

```
git clone https://github.com/GrantCuster/nix-simple.git
```

Increase swap file size to make install work (probably only necessary on micro)

```
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo chmod 600 /var/swap.1
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1
```

Temp install home-manager to run home-manager

```
nix-shell -p home-manager
```

Run home-manager flake

```
cd nix/home
home-manager --flake . --extra-experimental-features "nix-command flakes" switch
```

Enable swap by default after reboot, add this line to /etc/fstab:
```
/var/swap.1   swap    swap    defaults        0   0
```
