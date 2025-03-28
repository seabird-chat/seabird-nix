{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-url-plugin";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-7xly0XN2v3OKB8gXipww0RSn0XOoPlaiUz/W3dIErsg=";
  };

  vendorHash = "sha256-0p2fbo9Bxo153Jf0vlqmMLT/pHysPxt1mA+z4Pim4rI=";

  subPackages = [
    "cmd/seabird-url-plugin"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
