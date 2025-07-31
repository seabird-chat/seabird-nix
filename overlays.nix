{
  agenix,
  deploy-rs,
  ...
}:
{
  seabird = final: _prev: {
    seabird = final.lib.packagesFromDirectoryRecursive {
      callPackage = final.callPackage;
      directory = ./pkgs;
    };
  };

  agenix = agenix.overlays.default;

  deploy-rs = deploy-rs.overlays.default;
}
