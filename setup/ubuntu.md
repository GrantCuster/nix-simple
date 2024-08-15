## Sway autologin

```
sudo apt install greetd
sudo systemctl enable greetd
sudo /home/grant/.nix-profile/bin/nvim /etc/greetd/config.toml
```

add

```
[initial_session]
command = "sway"
user = "grant"
```

You can put it above the default session section

look at archwiki greetdd if any issues

## Bluetooth

apt install
- bluez
- blueman

enable bluetooth auto start with

```
sudo systemctl enable bluetooth
```

## Audio

apt install
- alsa
- pulseudio
- pavucontrol

## Wifi

Install network-manager

```
sudo apt install network-manager
```

In `/etc/netplan` make file `01-er-netplan-fix.yaml`

In file put:

```
network:
    version: 2
    renderer: NetworkManager
```

To stop from waiting for network to boot:

```
systemctl disable systemd-networkd-wait-online.service
```

## Timezone

sudo timedatectl set-timezone America/New_York

## Additional programs

sudo apt install mpv
(should try with nix sometime but i know ubuntu install works)

## Archive (deprecated instructions might be useful for something)

probably setup on install but in case of problems

auto connecting to wifi will look something like this
in /etc/netplan/50-cloud-init.yaml
```
# This file is generated from information provided by the datasource.  Changes
# to it will not persist across an instance reboot.  To disable cloud-init's
# network configuration capabilities, write a file
# /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg with the following:
# network: {config: disabled}
network:
    version: 2
    renderer: NetworkManager
    wifis:
        wlp0s20f3:
            access-points:
                Verizon_3XLKSS:
                    password: isle7-dit-coil
            dhcp4: true
```

Install network-manager
```
sudo apt install network-manager
```
and add renderer `NetworkManager` to the above to switch to network manager

Then to connect you probably want to use `nmtui`




