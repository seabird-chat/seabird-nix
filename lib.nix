{
  self,
  nixpkgs,
  agenix,
  ...
}:
{
  mkNixosSystem =
    { modules, system }:
    nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        self.nixosModules.default
        agenix.nixosModules.default
      ]
      ++ modules;

      specialArgs = {
        inherit self;
      };
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
}
