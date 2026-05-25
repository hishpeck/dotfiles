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

This automatically adds it to `nixosConfigurations`.

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
