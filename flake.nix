{

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
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
        defaultPackage = pkgs.rustPlatform.buildRustPackage {
          name = "gitui";
          src = self;
          cargoHash = "sha256-G22fqvc7xa7zp09C8vKh8DhlhPJgAbkyuBh5k1EDmY0=";
          buildInputs = [ openssl ];
          nativeBuildInputs = [ pkg-config cmake];
          OPENSSL_NO_VENDOR = 1;
          checkFlags = [
            "--skip=keys::key_config::tests::test_symbolic_links"
          ];
          BUILD_GIT_COMMIT_ID = "master*";
        };
        devShell = mkShell {
          buildInputs = [
            openssl
            pkg-config
            rust
            cmake
          ];
        };
      }
    );
}
