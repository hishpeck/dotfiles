# Dotfiles

This repository contains my current dev setup. I plan on documenting the way I use it and the resources that helped me along the way.

It is a hybrid setup based on Nix:

- Configurations using NixOS are used for setting up the whole operating system, from the CLI to the desktop.
- Configurations using Home Manager are used for setting up the environment in the CLI of any Linux-based distro.

## NixOS

### Installation

0. Launch the NixOS installation USB
1. Create two partitions on your disk

- 512 MiB, FAT32, boot, boot, esp
- Rest, ext-4, nixos

2. Mount the nixos and boot partitions

```bash
sudo -i
mount /dev/disk/by-label/nixos /mnt
mkdir -p /mnt/boot
mount /dev/disk/by-label/BOOT /mnt/boot
```

3. Clone the dotfiles

```bash
mkdir -p /mnt/etc
cd /mnt/etc
git clone git@github.com:hishpeck/dotfiles.git nixos
cd nixos
```

4. Create the directory for the new host and generate hardware for the device. Set the NEW_HOSTNAME to whatever you want

```bash
cp ./hosts/ac-zenbook-2025 ./hosts/NEW_HOSTNAME
rm ./hosts/NEW_HOSTNAME/hardware-configuration.nix
nixos-generate-config --root /mnt --show-hardware-config > ./hosts/NEW_HOSTNAME/hardware-configuration.nix
```

5. Remember to add the new host to the `nixosHosts` list in `flake.nix`:

```nix
      nixosHosts = [
        ...
        { name = "NEW_HOSTNAME"; system = "x86_64-linux"; }
      ];
```

This automatically adds it to both `nixosConfigurations` and `homeConfigurations`.

6. Run the install, after which you'll be prompted to set a root password

```bash
nixos-install --flake .#NEW_HOSTNAME
```

7. Enter the newly installed NixOS and set the user password

```bash
nixos-enter --root '/mnt'
passwd ac
```

8. Move the dotfiles to home

```bash
cp -r /etc/nixos /home/ac/dotfiles
chown ac:users -R /home/ac/dotfiles
```

## Home Manager

TODO

---

# OLD

1. To install the dotfiles you can use this shell script based on the awesome guide about [storing dotfiles by Atlassian](https://www.atlassian.com/git/tutorials/dotfiles). Of course make sure to review it's contents first 😁

```bash
curl -Lks https://raw.githubusercontent.com/hishpeck/dotfiles/refs/heads/master/install.sh | /bin/bash
```

2. Next, in order to install the commonly used binaries, use Nix with Home Manager

Install Nix using this command

```bash
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Install Home Manager

```bash
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

Run Home Manager with the command that fits your current operating system

```bash
home-manager switch --flake ~/.config/home-manager/flake.nix#ac-x86_64-linux
```

```bash
home-manager switch --flake ~/.config/home-manager/flake.nix#ac-aarch64-linux
```
