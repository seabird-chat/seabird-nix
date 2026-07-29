{
  seabirdBuildGoModule,
  fetchFromGitHub,
}:

seabirdBuildGoModule rec {
  pname = "seabird-stock-plugin";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-ZbZuW9qeBNBEQ/iX6a0gb71lTmbLbKcwYJbUSwU59cY=";
  };

  vendorHash = "sha256-FyS/NJ7hqBolm4vsJUSME7ryTXqcNW+zN0so1LGicJA=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
