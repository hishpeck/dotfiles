{ config, pkgs, ... }:

{
  programs.zsh.shellAliases = {
    car = "~/projects/carandclassic/carandclassic/bin/car";
  };

  # Work-only vicinae Raycast ports; same rev as the shared ones in
  # desktop/launcher/vicinae.nix — bump both together. search-notion stays
  # store-installed: its old @raycast/api curls a binary at build time,
  # which the nix sandbox blocks.
  programs.vicinae.extensions = map (e: config.lib.vicinae.mkRayCastExtension (e // {
    rev = "b3e7c0d11cb48a3246adf3b386c9d1d15ebe0b52";
  })) [
    { name = "slack"; sha256 = "sha256-8fdpCx6Q7Uf3LcfLY9pnSyCAZVtNImDAvUse2E3kP6M="; }
    { name = "linear"; sha256 = "sha256-VQKoOYdAcGA1qveQ1t3jcFp5dc2p691IQjp8ooLHn9E="; }
    { name = "google-calendar"; sha256 = "sha256-v3GNRF7p0qu8CpxVJzC0dVgYc+6QBkM62DzYn8Zmmdo="; }
  ];

  home.packages = with pkgs; [
    slack
    notion
    claude-code
    awscli2

    font-adobe-100dpi
    font-adobe-75dpi
    font-alias
    font-bh-ttf
  ];
}
