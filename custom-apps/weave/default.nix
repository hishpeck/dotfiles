{ pkgs, ... }:

pkgs.rustPlatform.buildRustPackage rec {
  pname = "weave";
  version = "0.2.6";

  src = pkgs.fetchFromGitHub {
    owner = "Ataraxy-Labs";
    repo = "weave";
    rev = "v${version}";
    hash = "sha256-XlSjdyKG/EQMFX3Ac/8yf7mHlD3Hb19MNMvRqmefg0A=";
  };

  cargoHash = "sha256-NtoRGvF8FWcQkrmNbeut1cU66ob8iNVpl3WJ35avDBk=";

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
