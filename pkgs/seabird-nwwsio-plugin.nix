{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "seabird-nwwsio-plugin";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-bEU7JQ3PHE5lzMEHFIDvCbAACWeK9yup47tKXtVJ/oM=";
  };

  vendorHash = "sha256-/0G3EDjpfXCb6SNME3sMfO7oRH+bsbXKzwqDvOr2zVc=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
