{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "seabird-core";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-67XlC/W9CHUcfA1jpqXgsYh4xMf7wag/riAouZ48drE=";
    fetchSubmodules = true;
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-M/jncfud4U4n4UBnXGcW1uMBgxBMG9WZefSFEsDSKso=";

  nativeBuildInputs = [
    pkgs.protobuf
  ];
}
