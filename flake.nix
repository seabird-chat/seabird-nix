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

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
      nixosHosts = [
        "kupo"
        "stiltzkin"
        "moguo"
        "monty"
        "artemicion"
      ];
    in
    {
      # There are a number of different formatters available: nixfmt, alejandra,
      # and nixfmt-rfc-style. As rfc-style is the "up-and-coming" format, we use
      # that rather than stock nixfmt.
      formatter = lib.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);

      overlays = import ./overlays.nix inputs;

      homeModules.default = import ./home/modules;
      nixosModules.default = import ./nixos/modules;

      nixosConfigurations = builtins.listToAttrs (
        map (f: {
          name = f;
          value = lib.mkNixosSystem {
            system = "aarch64-linux";
            modules = [
              ./nixos/hosts/${f}.nix
              ./nixos/users/belak.nix
            ];
          };
        }) nixosHosts
      );

      deploy.nodes = builtins.listToAttrs (
        map
        (f: {
          name = f;
          value = {
            hostname = "${f}.elwert.dev";
            profiles.system = lib.mkNixosDeploy self.nixosConfigurations.${f};
          };
        })
          nixosHosts
      );
    };
}
