{
  self,
  nixpkgs,
  agenix,
  disko,
  ...
}:
{
  mkNixosSystem =
    { modules }:
    nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit self;
      };

      modules = [
        self.nixosModules.default
        agenix.nixosModules.default
        disko.nixosModules.disko
      ]
      ++ modules;
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
