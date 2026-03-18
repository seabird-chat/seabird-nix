{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "seabird-webhook-receiver";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-VZRl/ehNnY/uuCw1FAJCL8+6eE9cmOtG73jhT9OHpF8=";
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
