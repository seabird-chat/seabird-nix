{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "seabird-adventofcode-plugin";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-73vYeTjvOx66+PK+TMiLxcSqL49SshxR6xDgfGiQHWo=";
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
