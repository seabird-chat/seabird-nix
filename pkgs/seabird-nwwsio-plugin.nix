{
  buildGoModule,
  fetchFromGitHub,
  go_1_26,
}:

(buildGoModule.override { go = go_1_26; }) rec {
  pname = "seabird-nwwsio-plugin";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-mmvw4qPGfBN6y25JefQvmdfstBQ1nuczTmDj5hCfzRY=";
  };

  vendorHash = "sha256-v2J5MJSC9iDSbEiypWilOmbHBcDo9Q31ofz+uLKLcj0=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
