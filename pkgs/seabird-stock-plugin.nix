{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-stock-plugin";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-+eF6qeZ5AnqbDLTEIYBdFysCt4g9uWoYOmiFLg3AB5k=";
  };

  vendorHash = "sha256-0ih5UrfTrjdqEXlC8PSgskjpLcY/aNYALlI4NHkH85M=";

  subPackages = [
    "cmd/seabird-stock-plugin"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
