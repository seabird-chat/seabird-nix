{
  self,
  nixpkgs,
  home-manager,
  agenix,
  ...
}:
{
  forAllSystems = nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  mkNixosSystem =
    { modules, system }:
    nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        self.nixosModules.default
        agenix.nixosModules.default
      ] ++ modules;

      specialArgs = {
        inherit self;
      };
    };

  # mkHome is a convenience function for declaring a home-manager config.
  mkHome =
    {
      modules,
      system,
      nixpkgs ? nixpkgs,
    }:
    home-manager.lib.homeManagerConfiguration {
      extraSpecialArgs = {
        inherit self;
      };

      pkgs = import nixpkgs {
        inherit system;
      };

      modules = [
        #self.homeModules.default
        agenix.homeManagerModules.default
      ] ++ modules;
    };

  # mkNixosDeploy takes a nixosConfig, generated using mkNixosSystem, and
  # generates an opinionated deploy-rs config.
  mkNixosDeploy =
    nixosConfig:
    let
      pkgs = nixosConfig._module.args.pkgs;
    in
    {
      user = "root";
      sshUser = "root";
      path = pkgs.deploy-rs.lib.activate.nixos nixosConfig;
    };

  # mkHomeDeploy takes a homeManagerConfig, generated using mkHome, and
  # generates an opinionated deploy-rs config.
  mkHomeDeploy =
    homeManagerConfig:
    let
      pkgs = homeManagerConfig.pkgs;
    in
    {
      user = homeManagerConfig.config.home.username;
      sshUser = "root";
      path = pkgs.deploy-rs.lib.activate.home-manager homeManagerConfig;
    };
}
