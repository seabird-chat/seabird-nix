{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-datadog-plugin";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-TTa8hmvo0MVUaLI0TOoj8103w8dWKR5uY0o9/bK10AQ=";
  };

  vendorHash = "sha256-geBTdcIPwB1SuDv/nwBWikaMjNfmQs/hnYd9LAHC6Z8=";

  subPackages = [
    "cmd/seabird-datadog-plugin"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
