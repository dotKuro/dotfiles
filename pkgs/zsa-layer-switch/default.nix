{ rustPlatform }:

rustPlatform.buildRustPackage {
  pname = "zsa-layer-switch";
  version = "0.1.0";
  src = ./.;
  cargoLock.lockFile = ./Cargo.lock;
}
