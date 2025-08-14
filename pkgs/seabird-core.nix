{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "seabird-core";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-O2gctivrUbrSdfNHuqTA2HsHz8XpdR9Vtq0T/wSO+AY=";
    fetchSubmodules = true;
  };

  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [
    pkgs.protobuf
  ];
}
