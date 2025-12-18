{
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "seabird-adventofcode-plugin";
  version = "0.2.5";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-JOnhpdlLHgTdrS3MegcOS7KHPk/cYGlRP1ZYD5AeCk8=";
  };

  vendorHash = "sha256-JPNuSD9Q6e5c0lDg5WDQ+pbaB8JJVvtuiZ4njH+O2Ko=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
