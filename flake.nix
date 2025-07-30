{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    let
      lib = import ./lib.nix inputs;
    in
    {
      # There are a number of different formatters available: nixfmt, alejandra,
      # and nixfmt-rfc-style. As rfc-style is the "up-and-coming" format, we use
      # that rather than stock nixfmt.
      formatter = lib.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      overlays.default = final: _prev: {
        seabird = final.lib.packagesFromDirectoryRecursive {
          callPackage = final.callPackage;
          directory = ./pkgs;
        };
      };

      packages = lib.forAllSystems (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        nixpkgs.lib.packagesFromDirectoryRecursive {
          callPackage = pkgs.callPackage;
          directory = ./pkgs;
        }
      );

    };
}
