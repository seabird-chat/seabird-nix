{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-discord-backend";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-O5u883s4vQRqBA0+gVeGlxTQypCZWh1PI6xdUOXnXpc=";
  };

  vendorHash = "sha256-o7a9BAZrziqZfWVtr7hOhqjKGjsCL2cN8mOeRcfXxCI=";

  subPackages = [
    "cmd/seabird-discord-backend"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
