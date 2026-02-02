{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "seabird-plugin-bundle";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-gEnG7jUKW+FAlYHKYJKohpM3qWZPBmbwUOyXTVVAs+w=";
    leaveDotGit = true;
  };

  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [
    pkgs.git
    pkgs.protobuf
  ];
}
