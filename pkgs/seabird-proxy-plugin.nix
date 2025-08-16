{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:
rustPlatform.buildRustPackage rec {
  pname = "seabird-proxy-plugin";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-0iAf3XBTyl40WFd7U9R8+UNDY2Vk8vofQa9LVbsPey0=";
  };

  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [
    pkgs.protobuf
  ];
}
