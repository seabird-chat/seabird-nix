{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "seabird-adventofcode-plugin";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-o8aPwjiji49ZkWXCP0XMTP2yNP5TU/dQz/qZ1M0Ujqo=";
  };

  vendorHash = "sha256-fPWrFzqQizc1206vL3UcQWxIvlUKPzpmq1Kc1V/+cDg=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
