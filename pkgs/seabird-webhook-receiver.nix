{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-webhook-receiver";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-v91/JuFIhWoGvUMzgi9bmyqC6hy7pB+SQmoS/iDbmcs=";
  };

  vendorHash = "sha256-hCGNv1XldN2RwSB+n18ngmQyRPKv62SvI5mRdTdmHEQ=";

  subPackages = [
    "cmd/seabird-webhook-receiver"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
