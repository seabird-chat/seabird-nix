{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "seabird-stock-plugin";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-CPM0jVwrJd2HywBcTepR2O2HI6uhBe6g34fYNjKcglw=";
  };

  vendorHash = "sha256-JFRa8HHKhPGcSkL3S+00TTO4fBwYqq33N57XL8WaS68=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
