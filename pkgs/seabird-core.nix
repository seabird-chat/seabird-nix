{
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "seabird-core";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-y4NJY8xkS5nJhz98xkhrU7j0OOweW4DuXS+nwShHwwg=";
    fetchSubmodules = true;
  };

  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [
    pkgs.protobuf
  ];
}
