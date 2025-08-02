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
      ...
    }:
    let
      lib = import ./lib.nix inputs;
    in
    {
      formatter = lib.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      overlays = import ./overlays.nix inputs;

      nixosModules.default = import ./nixos/modules;

      nixosConfigurations = {
        # ThinkPad X13s Gen 1
        "vivi" = lib.mkNixosSystem {
          system = "aarch64-linux";
          modules = [
            ./nixos/hosts/vivi
            ./nixos/users/belak
          ];
        };
      };

      deploy.nodes = {
        "vivi" = {
          hostname = "vivi.elwert.dev";
          profiles.system = lib.mkNixosDeploy self.nixosConfigurations."vivi";
        };
      };
    };
}
