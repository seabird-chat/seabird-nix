{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-datadog-plugin";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-cTqP//FhCvYUQaThyiTYDumXUWef/Jdt7qkydAgobJI=";
  };

  vendorHash = "sha256-Ja8qvJH5oWpWiJMsB0WTjK3z3k60jOmslJ0iwFsiwBc=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
