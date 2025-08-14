{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-webhook-receiver";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-93RTNFWiMQ7fKv31HTP6cNPdX1DeN7vPFh1MxM+O9JE=";
  };

  vendorHash = "sha256-ZSX2CD6fLlYsi9IS5i6+A8WlefafXt6zcg6yZQ8oA7Q=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
