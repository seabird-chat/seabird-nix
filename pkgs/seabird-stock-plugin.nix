{
  seabirdBuildGoModule,
  fetchFromGitHub,
}:

seabirdBuildGoModule rec {
  pname = "seabird-stock-plugin";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-BkXm2fciJr+SrgEQqP58bZ+JfCUZvRgvxnIhFIw6AmM=";
  };

  vendorHash = "sha256-0L6NrMkLPRuRDo+thRUYHNp4yGWC2+S48ttTsHJqwYE=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
