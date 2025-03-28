{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-github-plugin";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-BnD4iaRMmHrNbtC542ZqQcYgYnhC/GVG2YBI4I3yrlE=";
  };

  vendorHash = "sha256-Vc678vAJn6ODi5uZ8yvZldLvqPrPeZrFSolawxlwloU=";

  subPackages = [
    "cmd/seabird-github-plugin"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
