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
    hash = lib.fakeHash;
  };

  vendorHash = lib.fakeHash;

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
