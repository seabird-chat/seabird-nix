{
  lib,
  buildGoModule,
  fetchFromGitHub,
  stdenv,
}:

buildGoModule rec {
  pname = "seabird-irc-backend";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-a+4Z9VnO8PsM8kZdCjVk8D0w0v/DH+Ev+z0kWCBABc4=";
  };

  vendorHash = "sha256-TJAeHtQP9lxrWguGoBQQBEUzTdvG5NJA/JNXVAEGbVw=";

  subPackages = [
    "cmd/seabird-irc-backend"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
