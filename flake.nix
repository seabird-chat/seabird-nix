{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    let
      myLib = import ./lib.nix inputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      flake = {
        overlays = import ./overlays.nix inputs;

        nixosModules.default = import ./nixos/modules;

        nixosConfigurations = {
          "vivi" = myLib.mkNixosSystem {
            system = "x86_64-linux";
            modules = [
              ./nixos/hosts/vivi
              ./nixos/users/belak
              ./nixos/users/ghavil
            ];
          };
        };

        deploy.nodes = {
          "vivi" = {
            hostname = "homelab.elwert.dev";
            sshOpts = [
              "-p"
              "11237"
            ];
            profiles.system = myLib.mkNixosDeploy self.nixosConfigurations."vivi";
          };
        };
      };

      perSystem =
        {
          pkgs,
          system,
          lib,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.go ];
            config = { };
          };

          formatter = pkgs.treefmt.withConfig {
            runtimeInputs = [ pkgs.nixfmt-rfc-style ];

            settings = {
              # Log level for files treefmt won't format
              on-unmatched = "info";

              # Configure nixfmt for .nix files
              formatter.nixfmt = {
                command = "nixfmt";
                includes = [ "*.nix" ];
              };
            };
          };

          packages = lib.packagesFromDirectoryRecursive {
            inherit (pkgs) callPackage;
            directory = ./pkgs;
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.deploy-rs
            ];
          };
        };
    };
}
