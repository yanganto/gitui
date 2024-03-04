{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
    dependency-refresh.url = "github:yanganto/dependency-refresh";
  };

  outputs = { self, rust-overlay, nixpkgs, flake-utils, dependency-refresh }:
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
        defaultPackage = pkgs.rustPlatform.buildRustPackage {
          name = "gitui";
          src = self;
          cargoSha256 = "sha256-v4/6slNEa1sCO1rMIEffLLL+uAYeKiVZAcZPUNuLsM4=";
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
