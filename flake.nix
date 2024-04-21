{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, rust-overlay, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        rust = pkgs.rust-bin.stable.latest.default;
      in
      with pkgs;
      {
        defaultPackage = nixpkgs.rustPlatform.buildRustPackage {
          name = "gitui";
          src = self;
          cargoSha256 = "sha256-Gr4yOJOrIbvnHW4My3vtdt++Tet7lwrOQZ247ixR9gM=";
          buildInputs = [ openssl ];
          nativeBuildInputs = [ pkg-config ];
          OPENSSL_NO_VENDOR = 1;
          checkFlags = [
            "--skip=keys::key_config::tests::test_symbolic_links"
          ];
        };
        devShell = mkShell {
          buildInputs = [
            openssl
            pkg-config
            rust
          ];
        };
      }
    );
}
