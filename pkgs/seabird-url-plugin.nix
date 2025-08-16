{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "seabird-url-plugin";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-H7CWs1HmQ0RCIrgDfPowAWGW+uzn/5v+LZ4Ctb5bQvY=";
  };

  vendorHash = "sha256-chseg0rLYi1j4AA9i4uqbMmvL+n3xTotQPPN5fr/2bc=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
