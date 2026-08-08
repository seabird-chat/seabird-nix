{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # NOTE: we don't explicitly depend on home-manager, but there's a narHash
    # mismatch when we let agenix define it, so we include it here so we can
    # bump and control the version.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
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
          "kupo" = myLib.mkNixosSystem {
            modules = [
              ./nixos/hosts/kupo
              ./nixos/users/belak
              ./nixos/users/ghavil
            ];
          };

          "stiltzkin" = myLib.mkNixosSystem {
            modules = [
              ./nixos/hosts/stiltzkin
              ./nixos/users/belak
              ./nixos/users/ghavil
            ];
          };

          "vivi" = myLib.mkNixosSystem {
            modules = [
              ./nixos/hosts/vivi
              ./nixos/users/belak
              ./nixos/users/ghavil
            ];
          };
        };

        deploy.nodes = {
          "kupo" = {
            hostname = "kupo.infra.seabird.chat";
            sshOpts = [
              "-p"
              "11239"
            ];
            profiles.system = myLib.mkNixosDeploy self.nixosConfigurations."kupo";
          };

          "stiltzkin" = {
            hostname = "stiltzkin.infra.seabird.chat";
            profiles.system = myLib.mkNixosDeploy self.nixosConfigurations."stiltzkin";
          };


          "vivi" = {
            hostname = "vivi.infra.seabird.chat";
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
            overlays = builtins.attrValues self.overlays;
            config = { };
          };

          formatter = pkgs.treefmt.withConfig {
            runtimeInputs = [ pkgs.nixfmt ];

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
              pkgs.agenix
              pkgs.deploy-rs
            ];
          };
        };
    };
}
