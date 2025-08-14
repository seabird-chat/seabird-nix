{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-github-plugin";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-tSYpGj/p7r/m6aEpnGGAzRtr0VyMfn7dzeELBvJoFpQ=";
  };

  vendorHash = "sha256-HEVxf9PcNVMjQDIWL1YdkvlaQ0VT95lEU9J15hRkJqc=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
