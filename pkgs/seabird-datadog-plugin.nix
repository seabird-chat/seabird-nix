{
  seabirdBuildGoModule,
  fetchFromGitHub,
}:

seabirdBuildGoModule rec {
  pname = "seabird-datadog-plugin";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-3n/FdnjMqeCnXC7jU/bmUIOf2F5BHCquivjuakLyof4=";
  };

  vendorHash = "sha256-pV7b0wNflcDTZe1Qcnf7Zu1ATDegoytIkdmcu4K5pms=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
