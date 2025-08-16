{
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "seabird-discord-backend";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-5OwH7/J3g3nqdlaMrQ6i2fWcnkS0MFkUSGqaVaMXx30=";
  };

  vendorHash = "sha256-o7a9BAZrziqZfWVtr7hOhqjKGjsCL2cN8mOeRcfXxCI=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
