{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "seabird-url-plugin";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-uJVkUIZgHIau/DGDn0tKouYgmV/pG/VE6RVGbLDk2HM=";
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
