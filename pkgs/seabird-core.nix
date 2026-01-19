{
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "seabird-core";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+EUjCPHNPHJxk/d6Nx17Y2yYk8QfiPZPTM1lfs8G/MI=";
    fetchSubmodules = true;
  };

  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [
    pkgs.protobuf
  ];
}
