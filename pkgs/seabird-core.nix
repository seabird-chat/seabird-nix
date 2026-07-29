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

  cargoHash = "sha256-M/jncfud4U4n4UBnXGcW1uMBgxBMG9WZefSFEsDSKso=";

  nativeBuildInputs = [
    pkgs.protobuf
  ];
}
