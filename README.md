# Dotfiles

This repository contains my current dev setup. I plan on documenting the way I use it and the resources that helped me along the way.

# Installation

1. To install the dotfiles you can use this shell script based on the awesome guide about [storing dotfiles by Atlassian](https://www.atlassian.com/git/tutorials/dotfiles). Of course make sure to review it's contents first 😁

```shell
curl -Lks https://raw.githubusercontent.com/hishpeck/dotfiles/refs/heads/master/install.sh | /bin/bash
```

2. Next, in order to install the commonly used binaries, use Nix with Home Manager

Install Nix using this command

```shell
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Install Home Manager

```shell
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
```

Run Home Manager with the command that fits your current operating system

```shell
home-manager switch --flake path/to/your/flake.nix#ac-x86_64-linux
```

```shell
home-manager switch --flake path/to/your/flake.nix#ac-aarch64-linux
```
