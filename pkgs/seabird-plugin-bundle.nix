{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "seabird-plugin-bundle";
  version = "0.1.15";

  # TODO: the build is currently broken because of git_version, which doesn't
  # work as expected here.

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-irZ/twuXRHddzuP2nt5SwlbsIhK1YxB2pbEP2BWJYfg=";
  };

  useFetchCargoVendor = true;
  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [
    pkgs.protobuf
  ];
}
