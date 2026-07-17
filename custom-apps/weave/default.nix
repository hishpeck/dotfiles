{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "weave";
  version = "0.3.6";

  src = pkgs.fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "weave";
    rev = "v${version}";
    hash = "sha256-VlJUXAXlWpFGlJgAEhhdeX35AZV/G/IJlXEjU/7SfJg=";
  };

  cargoHash = "sha256-ZPe9l3S88idwYrayT5mmagW/VdA0VlUHTDXVyHoOF1w=";

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    openssl
  ];

  meta = with pkgs.lib; {
    description = "Entity-level semantic merge tool that resolves Git conflicts by understanding code structure";
    homepage = "https://github.com/Ataraxy-Labs/weave";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.all;
  };
}
