{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-core;
in
{
  options = {
    seabird.services.seabird-core = {
      enable = lib.mkEnableOption "seabird-core";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-core;
      };
      hosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-core = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        DATABASE_URL = "sqlite:///var/lib/seabird-core/seabird-core.db";
        SEABIRD_BIND_HOST = "0.0.0.0:8080";
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${cfg.package}/bin/seabird-core";
        StateDirectory = "seabird-core";
      };
    };

    seabird.caddy.virtualHosts.seabird-core = {
      inherit (cfg) hosts;

      backend = "h2c://localhost:8080"; # TODO: this is hard coded
    };
  };
}
