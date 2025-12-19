{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

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
      nixpkgs-unstable,
      ...
    }:
    let
      lib = import ./lib.nix inputs;
    in
    {
      formatter = lib.forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        pkgs.treefmt.withConfig {
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
        }
      );

      packages = lib.forAllSystems (
        system:
        nixpkgs.lib.packagesFromDirectoryRecursive {
          callPackage = nixpkgs.legacyPackages.${system}.callPackage;
          directory = ./pkgs;
        }
      );

      overlays = import ./overlays.nix inputs;

      nixosModules.default = import ./nixos/modules;

      nixosConfigurations = {
        "vivi" = lib.mkNixosSystem {
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
          sshOpts = [ "-p" "11237" ];
          profiles.system = lib.mkNixosDeploy self.nixosConfigurations."vivi";
        };
      };

      devShells = lib.forAllSystems (
        system:
        let
          pkgs = nixpkgs-unstable.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              deploy-rs
            ];
          };
        }
      );
    };
}
