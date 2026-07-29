{
  lib,
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:

rustPlatform.buildRustPackage rec {
  pname = "seabird-plugin-bundle";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-T1W9Ps7CvBv24inX5C8t0R7kyxewTWbU8OMzauhc+S4=";
    leaveDotGit = true;
  };

  cargoHash = "sha256-+MBsQ1UH0/Wi0N7eQNV1F+3gyDtS4LFkMRE28ZiZ0ZY=";

  nativeBuildInputs = [
    pkgs.git
    pkgs.protobuf
  ];
}
