{
  buildGoModule,
  fetchFromGitHub,
  go_1_26,
}:

(buildGoModule.override { go = go_1_26; }) rec {
  pname = "seabird-datadog-plugin";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-AUkfHDQJtt2SPyHITG/+e2VJzzQ6AXgH/O4YLMGzSZM=";
  };

  vendorHash = "sha256-8VFxh/htBJzvqklRtK4phGki/tM6sjkPEH0pZmJkmZo=";

  subPackages = [
    "cmd/${pname}"
  ];

  ldflags = [
    "-s"
    "-w"
    #"-X=main.version=${version}"
  ];
}
