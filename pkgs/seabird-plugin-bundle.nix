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
    hash = "sha256-T1W9Ps7CvBv24inX5C8t0R7kyxewTWbU8OMzauhc+S4=";
    leaveDotGit = true;
  };

  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [
    pkgs.git
    pkgs.protobuf
  ];
}
