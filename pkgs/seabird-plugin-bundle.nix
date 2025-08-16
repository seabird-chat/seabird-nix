{
  fetchFromGitHub,
  rustPlatform,
  pkgs,
}:
rustPlatform.buildRustPackage rec {
  pname = "seabird-plugin-bundle";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "seabird-chat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-oI5epLTVV78NdgBAJzPlXaQsoRzHaeuBVIJPJYOCenw=";
    leaveDotGit = true;
  };

  cargoLock.lockFile = src + /Cargo.lock;

  nativeBuildInputs = [
    pkgs.git
    pkgs.protobuf
  ];
}
