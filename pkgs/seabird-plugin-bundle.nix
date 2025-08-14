{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "seabird-plugin-bundle";
  version = "0.1.15";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-KO6IDwVw2zKMOWypMu+SUs6Bdv4C9p6LLNzlzFITXYs=";
    leaveDotGit = true;
  };

  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [
    pkgs.git
    pkgs.protobuf
  ];
}
