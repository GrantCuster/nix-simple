# AWS instance instructions

Determinate nix install. Pinning older version until they fix mkoutofstoresymlink

```
VERSION="v0.12.0"
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix/tag/${VERSION} | sh -s -- install
```

Resource shell

```
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Clone nix-simple as nix

```
git clone https://github.com/GrantCuster/nix-simple.git nix
```

Increase swap file size to make install work (probably only necessary on micro)

```
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=2048
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

Switch shell to zsh.

First set ubuntu password.

```
sudo su -
passwd ubuntu
```

Add shell

```
command -v zsh | sudo tee -a /etc/shells
```

Exit and set shell

```
chsh -s $(which zsh)
```

Exit and reconnect
